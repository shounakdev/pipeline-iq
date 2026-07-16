from __future__ import annotations

from collections.abc import Sequence
from datetime import datetime
from typing import Any
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models import (
    AuditEvent,
    Incident,
    IncidentAlertLink,
    IncidentAssignment,
    IncidentComment,
    IncidentMetric,
    IncidentSeverity,
    IncidentStatus,
    IncidentTimelineEvent,
    ReliabilityAlert,
)


# ---------------------------------------------------------------------------
# Incident read functions
# ---------------------------------------------------------------------------


def get_incident_by_id(
    db: Session,
    incident_id: UUID,
) -> Incident | None:
    """
    Return one incident by its UUID.
    """

    statement = select(Incident).where(
        Incident.id == incident_id,
    )

    return db.execute(statement).scalar_one_or_none()


def get_incident_by_number(
    db: Session,
    incident_number: str,
) -> Incident | None:
    """
    Return one incident by its human-readable incident number.
    """

    statement = select(Incident).where(
        Incident.incident_number == incident_number,
    )

    return db.execute(statement).scalar_one_or_none()

def get_incident_alert_link_by_alert_id(
    db: Session,
    reliability_alert_id: str,
) -> IncidentAlertLink | None:
    """
    Return the incident link for a reliability alert.

    A reliability alert must only be processed by the incident
    workflow once, even when its event is delivered repeatedly.
    """

    statement = (
        select(IncidentAlertLink)
        .where(
            IncidentAlertLink.reliability_alert_id
            == reliability_alert_id,
        )
        .order_by(
            IncidentAlertLink.linked_at.asc(),
        )
        .limit(1)
    )

    return db.execute(statement).scalar_one_or_none()


def list_incidents(
    db: Session,
    *,
    statuses: Sequence[IncidentStatus | str] | None = None,
    severities: Sequence[IncidentSeverity | str] | None = None,
    service_id: str | None = None,
    environment: str | None = None,
    assigned_to_user_id: str | None = None,
    offset: int = 0,
    limit: int = 100,
) -> list[Incident]:
    """
    Return incidents matching the supplied filters.

    Pagination and filter validation belong to the service or router layer.
    """

    statement = select(Incident)

    if statuses:
        statement = statement.where(
            Incident.status.in_(statuses),
        )

    if severities:
        statement = statement.where(
            Incident.severity.in_(severities),
        )

    if service_id is not None:
        statement = statement.where(
            Incident.primary_service_id == service_id,
        )

    if environment is not None:
        statement = statement.where(
            Incident.environment == environment,
        )

    if assigned_to_user_id is not None:
        statement = statement.where(
            Incident.current_assignee_id == assigned_to_user_id,
        )

    statement = (
        statement
        .order_by(
            Incident.detected_at.desc(),
            Incident.created_at.desc(),
        )
        .offset(offset)
        .limit(limit)
    )

    return list(
        db.execute(statement).scalars().all(),
    )


def acquire_incident_deduplication_lock(
    db: Session,
    *,
    lock_id: int,
) -> None:
    """
    Serialize incident correlation for one deduplication key.

    PostgreSQL automatically releases this transaction-level advisory
    lock when the surrounding transaction commits or rolls back.
    """

    db.execute(
        select(
            func.pg_advisory_xact_lock(lock_id),
        )
    ).scalar_one()


def find_open_incident_by_deduplication_key(
    db: Session,
    deduplication_key: str,
    *,
    correlation_cutoff: datetime,
) -> Incident | None:
    """
    Find a matching non-terminal incident inside the correlation window.

    Correlation uses the latest linked alert when one exists, falling
    back to the original incident detection timestamp.
    """

    terminal_statuses = (
        IncidentStatus.RESOLVED,
        IncidentStatus.FAILED_RECOVERY,
    )

    latest_alert_at = (
        select(func.max(ReliabilityAlert.created_at))
        .join(
            IncidentAlertLink,
            (
                IncidentAlertLink.reliability_alert_id
                == ReliabilityAlert.id
            ),
        )
        .where(
            IncidentAlertLink.incident_id == Incident.id,
        )
        .correlate(Incident)
        .scalar_subquery()
    )

    latest_correlation_activity = func.coalesce(
        latest_alert_at,
        Incident.detected_at,
    )

    statement = (
        select(Incident)
        .where(
            Incident.deduplication_key == deduplication_key,
            Incident.status.notin_(terminal_statuses),
            Incident.resolved_at.is_(None),
            latest_correlation_activity >= correlation_cutoff,
        )
        .order_by(
            latest_correlation_activity.desc(),
            Incident.detected_at.desc(),
            Incident.created_at.desc(),
        )
        .limit(1)
    )

    return db.execute(statement).scalar_one_or_none()


def get_incident_alerts(
    db: Session,
    incident_id: UUID,
) -> list[ReliabilityAlert]:
    """
    Return all reliability alerts linked to an incident.

    Triggering alerts are returned before non-triggering alerts.
    """

    statement = (
        select(ReliabilityAlert)
        .join(
            IncidentAlertLink,
            (
                IncidentAlertLink.reliability_alert_id
                == ReliabilityAlert.id
            ),
        )
        .where(
            IncidentAlertLink.incident_id == incident_id,
        )
        .order_by(
            IncidentAlertLink.is_triggering_alert.desc(),
            IncidentAlertLink.linked_at.asc(),
        )
    )

    return list(
        db.execute(statement).scalars().all(),
    )


def get_latest_active_assignment(
    db: Session,
    incident_id: UUID,
) -> IncidentAssignment | None:
    """
    Return the latest active assignment for an incident.
    """

    statement = (
        select(IncidentAssignment)
        .where(
            IncidentAssignment.incident_id == incident_id,
            IncidentAssignment.is_active.is_(True),
        )
        .order_by(
            IncidentAssignment.assigned_at.desc(),
            IncidentAssignment.id.desc(),
        )
        .limit(1)
    )

    return db.execute(statement).scalar_one_or_none()


def get_incident_assignments(
    db: Session,
    incident_id: UUID,
) -> list[IncidentAssignment]:
    """
    Return complete assignment history, newest first.
    """

    statement = (
        select(IncidentAssignment)
        .where(
            IncidentAssignment.incident_id == incident_id,
        )
        .order_by(
            IncidentAssignment.assigned_at.desc(),
            IncidentAssignment.id.desc(),
        )
    )

    return list(
        db.execute(statement).scalars().all(),
    )


def get_incident_comments(
    db: Session,
    incident_id: UUID,
) -> list[IncidentComment]:
    """
    Return incident comments in chronological order.
    """

    statement = (
        select(IncidentComment)
        .where(
            IncidentComment.incident_id == incident_id,
        )
        .order_by(
            IncidentComment.created_at.asc(),
            IncidentComment.id.asc(),
        )
    )

    return list(
        db.execute(statement).scalars().all(),
    )


def get_incident_metrics(
    db: Session,
    incident_id: UUID,
) -> list[IncidentMetric]:
    """
    Return captured metric snapshots, newest first.
    """

    statement = (
        select(IncidentMetric)
        .where(
            IncidentMetric.incident_id == incident_id,
        )
        .order_by(
            IncidentMetric.captured_at.desc(),
            IncidentMetric.created_at.desc(),
        )
    )

    return list(
        db.execute(statement).scalars().all(),
    )


def get_incident_timeline(
    db: Session,
    incident_id: UUID,
) -> list[IncidentTimelineEvent]:
    """
    Return the incident timeline in chronological order.
    """

    statement = (
        select(IncidentTimelineEvent)
        .where(
            IncidentTimelineEvent.incident_id == incident_id,
        )
        .order_by(
            IncidentTimelineEvent.occurred_at.asc(),
            IncidentTimelineEvent.created_at.asc(),
        )
    )

    return list(
        db.execute(statement).scalars().all(),
    )


# ---------------------------------------------------------------------------
# Incident write functions
# ---------------------------------------------------------------------------


def create_incident(
    db: Session,
    **incident_values: Any,
) -> Incident:
    """
    Create and flush an incident.

    The service layer is responsible for supplying validated values and
    committing or rolling back the transaction.
    """

    incident = Incident(**incident_values)

    db.add(incident)
    db.flush()

    return incident


def update_incident_status(
    db: Session,
    incident: Incident,
    *,
    status: IncidentStatus,
    **field_updates: Any,
) -> Incident:
    """
    Persist a status update and any service-calculated timestamps or summaries.

    This function deliberately does not validate lifecycle transitions.
    """

    incident.status = status

    for field_name, field_value in field_updates.items():
        setattr(
            incident,
            field_name,
            field_value,
        )

    db.add(incident)
    db.flush()

    return incident


def update_incident(
    db: Session,
    incident: Incident,
    **field_updates,
) -> Incident:
    """Update general incident fields without committing the transaction."""
    protected_fields = {
        "id",
        "incident_number",
        "created_at",
    }

    for field_name, value in field_updates.items():
        if field_name in protected_fields:
            raise ValueError(
                f"Incident field cannot be updated: {field_name}"
            )

        if not hasattr(incident, field_name):
            raise ValueError(
                f"Unknown Incident field: {field_name}"
            )

        setattr(incident, field_name, value)

    db.add(incident)
    db.flush()

    return incident

def update_incident_severity(
    db: Session,
    incident: Incident,
    *,
    severity: IncidentSeverity,
) -> Incident:
    """
    Persist a new incident severity.
    """

    incident.severity = severity

    db.add(incident)
    db.flush()

    return incident


def link_alert_to_incident(
    db: Session,
    *,
    incident_id: UUID,
    reliability_alert_id: str,
    is_triggering_alert: bool = False,
) -> IncidentAlertLink:
    """
    Create an incident-to-alert link.

    Repeated calls return the existing link instead of violating the unique
    incident and reliability-alert constraint.
    """

    existing_statement = select(IncidentAlertLink).where(
        IncidentAlertLink.incident_id == incident_id,
        (
            IncidentAlertLink.reliability_alert_id
            == reliability_alert_id
        ),
    )

    existing_link = db.execute(
        existing_statement,
    ).scalar_one_or_none()

    if existing_link is not None:
        if (
            is_triggering_alert
            and not existing_link.is_triggering_alert
        ):
            existing_link.is_triggering_alert = True
            db.add(existing_link)
            db.flush()

        return existing_link

    alert_link = IncidentAlertLink(
        incident_id=incident_id,
        reliability_alert_id=reliability_alert_id,
        is_triggering_alert=is_triggering_alert,
    )

    db.add(alert_link)
    db.flush()

    return alert_link


def create_assignment(
    db: Session,
    *,
    incident_id: UUID,
    assigned_to_user_id: str,
    assigned_by_user_id: str | None = None,
    assignment_note: str | None = None,
    assigned_at: datetime | None = None,
) -> IncidentAssignment:
    """
    Create an active incident assignment.
    """

    values: dict[str, Any] = {
        "incident_id": incident_id,
        "assigned_to_user_id": assigned_to_user_id,
        "assigned_by_user_id": assigned_by_user_id,
        "assignment_note": assignment_note,
        "is_active": True,
    }

    if assigned_at is not None:
        values["assigned_at"] = assigned_at

    assignment = IncidentAssignment(**values)

    db.add(assignment)
    db.flush()

    return assignment


def close_active_assignment(
    db: Session,
    *,
    incident_id: UUID,
    unassigned_at: datetime,
) -> IncidentAssignment | None:
    """
    Close the latest active assignment for an incident.
    """

    assignment = get_latest_active_assignment(
        db,
        incident_id,
    )

    if assignment is None:
        return None

    assignment.is_active = False
    assignment.unassigned_at = unassigned_at

    db.add(assignment)
    db.flush()

    return assignment


def create_comment(
    db: Session,
    *,
    incident_id: UUID,
    comment: str,
    author_user_id: str | None = None,
) -> IncidentComment:
    """
    Create an incident comment.
    """

    incident_comment = IncidentComment(
        incident_id=incident_id,
        author_user_id=author_user_id,
        comment=comment,
    )

    db.add(incident_comment)
    db.flush()

    return incident_comment


def create_timeline_event(
    db: Session,
    *,
    incident_id: UUID,
    event_type: str,
    source: str,
    message: str | None = None,
    from_status: IncidentStatus | None = None,
    to_status: IncidentStatus | None = None,
    actor_user_id: str | None = None,
    alert_id: str | None = None,
    deployment_id: UUID | None = None,
    metadata_json: dict[str, Any] | None = None,
    occurred_at: datetime | None = None,
) -> IncidentTimelineEvent:
    """
    Create an incident timeline event.
    """

    values: dict[str, Any] = {
        "incident_id": incident_id,
        "event_type": event_type,
        "source": source,
        "message": message,
        "from_status": from_status,
        "to_status": to_status,
        "actor_user_id": actor_user_id,
        "alert_id": alert_id,
        "deployment_id": deployment_id,
        "metadata_json": metadata_json,
    }

    if occurred_at is not None:
        values["occurred_at"] = occurred_at

    timeline_event = IncidentTimelineEvent(**values)

    db.add(timeline_event)
    db.flush()

    return timeline_event


def create_metric_snapshot(
    db: Session,
    *,
    incident_id: UUID,
    metric_type: str,
    metric_name: str,
    value: float,
    source: str,
    unit: str | None = None,
    captured_at: datetime | None = None,
    metadata_json: dict[str, Any] | None = None,
) -> IncidentMetric:
    """
    Create one incident metric snapshot.
    """

    values: dict[str, Any] = {
        "incident_id": incident_id,
        "metric_type": metric_type,
        "metric_name": metric_name,
        "value": value,
        "unit": unit,
        "source": source,
        "metadata_json": metadata_json,
    }

    if captured_at is not None:
        values["captured_at"] = captured_at

    metric = IncidentMetric(**values)

    db.add(metric)
    db.flush()

    return metric


def create_audit_event(
    db: Session,
    *,
    action: str,
    entity_type: str,
    entity_id: str,
    actor_id: str | None = None,
    details: str | None = None,
) -> AuditEvent:
    """
    Create an audit event.

    AuditEvent.details is currently a text column. The service layer should
    serialize structured dictionaries before calling this function.
    """

    audit_event = AuditEvent(
        actor_id=actor_id,
        action=action,
        entity_type=entity_type,
        entity_id=entity_id,
        details=details,
    )

    db.add(audit_event)
    db.flush()

    return audit_event