"""Incident application service.

Coordinates incident repositories, pure business rules, timeline creation,
audit logging, and transaction boundaries.
"""

from __future__ import annotations

import json
from datetime import datetime, timedelta, timezone
from enum import Enum
from typing import Any
from uuid import UUID

from sqlalchemy.orm import Session

from app.incidents import repository
from app.incidents.metrics import calculate_incident_metrics
from app.incidents.rules import (
    build_deduplication_key,
    calculate_incident_severity,
)
from app.incidents.schemas import (
    DeploymentSummaryResponse,
    IncidentAcknowledgeRequest,
    IncidentAssignmentRequest,
    IncidentAssignmentResponse,
    IncidentCalculatedMetricsResponse,
    IncidentCommentCreateRequest,
    IncidentCommentResponse,
    IncidentDetailResponse,
    IncidentListResponse,
    IncidentMetricResponse,
    IncidentStatusUpdateRequest,
    IncidentTimelineEventResponse,
    IncidentTimelineResponse,
    OperatorSummaryResponse,
    ReliabilityAlertSummaryResponse,
    ServiceSummaryResponse,
)
from app.incidents.timeline import get_timeline_event_type
from app.incidents.transitions import validate_status_transition
from app.models import (
    Incident,
    IncidentAssignment,
    IncidentComment,
    IncidentMetric,
    IncidentSeverity,
    IncidentStatus,
    IncidentTimelineEvent,
    ReliabilityAlert,
)


_SEVERITY_RANK = {
    IncidentSeverity.SEV_3: 1,
    IncidentSeverity.SEV_2: 2,
    IncidentSeverity.SEV_1: 3,
}


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _enum_value(value: Any) -> Any:
    if isinstance(value, Enum):
        return value.value
    return value


def _json_details(**values: Any) -> str:
    return json.dumps(
        values,
        default=str,
        sort_keys=True,
    )


def _duration_seconds(value: timedelta | None) -> float | None:
    if value is None:
        return None
    return max(value.total_seconds(), 0.0)


def _operator_response(user: Any) -> OperatorSummaryResponse | None:
    if user is None:
        return None

    return OperatorSummaryResponse(
        id=str(user.id),
        email=user.email,
        full_name=user.full_name,
    )


def _service_response(service: Any) -> ServiceSummaryResponse:
    if service is None:
        raise ValueError(
            "Incident primary service could not be loaded"
        )

    return ServiceSummaryResponse(
        id=str(service.id),
        name=service.name,
        service_type=service.service_type,
        owner=service.owner,
    )


def _alert_response(
    alert: ReliabilityAlert | None,
) -> ReliabilityAlertSummaryResponse | None:
    if alert is None:
        return None

    return ReliabilityAlertSummaryResponse(
        id=str(alert.id),
        service_id=str(alert.service_id),
        slo_definition_id=str(alert.slo_definition_id),
        alert_type=_enum_value(alert.alert_type),
        severity=_enum_value(alert.severity),
        triggered_value=float(alert.triggered_value),
        threshold_value=float(alert.threshold_value),
        deployment_id=alert.deployment_id,
        status=_enum_value(alert.status),
        created_at=alert.created_at,
        resolved_at=alert.resolved_at,
    )


def _deployment_response(
    deployment: Any,
) -> DeploymentSummaryResponse | None:
    if deployment is None:
        return None

    return DeploymentSummaryResponse(
        id=deployment.id,
        service_id=str(deployment.service_id),
        service_name=deployment.service_name,
        environment_id=deployment.environment_id,
        image_tag=deployment.image_tag,
        deployment_version=deployment.deployment_version,
        commit_sha=deployment.commit_sha,
        argo_sync_status=deployment.argo_sync_status,
        kubernetes_rollout_status=(
            deployment.kubernetes_rollout_status
        ),
        deployed_at=deployment.deployed_at,
        created_at=deployment.created_at,
    )


def _assignment_response(
    assignment: IncidentAssignment | None,
) -> IncidentAssignmentResponse | None:
    if assignment is None:
        return None

    return IncidentAssignmentResponse(
        id=assignment.id,
        incident_id=assignment.incident_id,
        assigned_to_user_id=assignment.assigned_to_user_id,
        assigned_to_user=_operator_response(
            assignment.assigned_to_user
        ),
        assigned_by_user_id=assignment.assigned_by_user_id,
        assigned_by_user=_operator_response(
            assignment.assigned_by_user
        ),
        assignment_note=assignment.assignment_note,
        assigned_at=assignment.assigned_at,
        unassigned_at=assignment.unassigned_at,
        is_active=assignment.is_active,
    )


def _comment_response(
    comment: IncidentComment,
) -> IncidentCommentResponse:
    return IncidentCommentResponse(
        id=comment.id,
        incident_id=comment.incident_id,
        author_user_id=comment.author_user_id,
        author=_operator_response(comment.author),
        comment=comment.comment,
        created_at=comment.created_at,
        updated_at=comment.updated_at,
    )


def _metric_response(
    metric: IncidentMetric,
) -> IncidentMetricResponse:
    return IncidentMetricResponse(
        id=metric.id,
        incident_id=metric.incident_id,
        metric_type=metric.metric_type,
        metric_name=metric.metric_name,
        value=float(metric.value),
        unit=metric.unit,
        source=metric.source,
        captured_at=metric.captured_at,
        metadata_json=metric.metadata_json,
        created_at=metric.created_at,
    )


def _timeline_event_response(
    event: IncidentTimelineEvent,
) -> IncidentTimelineEventResponse:
    return IncidentTimelineEventResponse(
        id=event.id,
        incident_id=event.incident_id,
        event_type=event.event_type,
        source=event.source,
        message=event.message,
        from_status=event.from_status,
        to_status=event.to_status,
        actor_user_id=event.actor_user_id,
        actor=_operator_response(event.actor_user),
        alert_id=event.alert_id,
        alert=_alert_response(event.alert),
        deployment_id=event.deployment_id,
        deployment=_deployment_response(event.deployment),
        metadata_json=event.metadata_json,
        occurred_at=event.occurred_at,
        created_at=event.created_at,
    )


def _calculated_metrics_response(
    incident: Incident,
) -> IncidentCalculatedMetricsResponse:
    durations = calculate_incident_metrics(
        failure_started_at=incident.failure_started_at,
        detected_at=incident.detected_at,
        acknowledged_at=incident.acknowledged_at,
        resolved_at=incident.resolved_at,
    )

    return IncidentCalculatedMetricsResponse(
        incident_id=incident.id,
        failure_started_at=incident.failure_started_at,
        detected_at=incident.detected_at,
        acknowledged_at=incident.acknowledged_at,
        resolved_at=incident.resolved_at,
        mttd_seconds=_duration_seconds(
            getattr(durations, "mttd", None)
        ),
        mtta_seconds=_duration_seconds(
            getattr(durations, "mtta", None)
        ),
        mttr_seconds=_duration_seconds(
            getattr(durations, "mttr", None)
        ),
    )


def _incident_list_response(
    incident: Incident,
) -> IncidentListResponse:
    service_id = (
        incident.primary_service_id
        or incident.service_id
    )

    if not service_id:
        raise ValueError(
            f"Incident {incident.id} has no primary service"
        )

    return IncidentListResponse(
        incident_id=incident.id,
        id=incident.id,
        incident_number=incident.incident_number,
        title=incident.title,
        severity=incident.severity,
        status=incident.status,
        service_id=str(service_id),
        service_name=(
            incident.primary_service.name
            if incident.primary_service is not None
            else None
        ),
        environment=incident.environment,
        assigned_operator=_operator_response(
            incident.current_assignee
        ),
        suspected_deployment_id=(
            incident.suspected_deployment_id
        ),
        detected_at=incident.detected_at,
        acknowledged_at=incident.acknowledged_at,
        resolved_at=incident.resolved_at,
        created_at=incident.created_at,
        updated_at=incident.updated_at,
    )


def _affected_services(
    incident: Incident,
    alerts: list[ReliabilityAlert],
) -> list[ServiceSummaryResponse]:
    services: dict[str, Any] = {}

    if incident.primary_service is not None:
        services[str(incident.primary_service.id)] = (
            incident.primary_service
        )

    for alert in alerts:
        if alert.service is not None:
            services[str(alert.service.id)] = alert.service

    return [
        _service_response(service)
        for service in services.values()
    ]


def list_incidents(
    db: Session,
    *,
    statuses: list[IncidentStatus] | None = None,
    severities: list[IncidentSeverity] | None = None,
    service_id: str | None = None,
    environment: str | None = None,
    assigned_to_user_id: str | None = None,
    offset: int = 0,
    limit: int = 100,
) -> list[IncidentListResponse]:
    incidents = repository.list_incidents(
        db,
        statuses=statuses,
        severities=severities,
        service_id=service_id,
        environment=environment,
        assigned_to_user_id=assigned_to_user_id,
        offset=offset,
        limit=limit,
    )

    return [
        _incident_list_response(incident)
        for incident in incidents
    ]


def get_incident_detail(
    db: Session,
    incident_id: UUID,
) -> IncidentDetailResponse | None:
    incident = repository.get_incident_by_id(
        db,
        incident_id,
    )

    if incident is None:
        return None

    alerts = repository.get_incident_alerts(
        db,
        incident.id,
    )
    current_assignment = (
        repository.get_latest_active_assignment(
            db,
            incident.id,
        )
    )
    assignments = repository.get_incident_assignments(
        db,
        incident.id,
    )
    comments = repository.get_incident_comments(
        db,
        incident.id,
    )
    metrics = repository.get_incident_metrics(
        db,
        incident.id,
    )
    timeline_events = repository.get_incident_timeline(
        db,
        incident.id,
    )

    return IncidentDetailResponse(
        incident=_incident_list_response(incident),
        description=incident.description,
        deduplication_key=(
            incident.deduplication_key or ""
        ),
        primary_service=_service_response(
            incident.primary_service
        ),
        affected_services=_affected_services(
            incident,
            alerts,
        ),
        triggering_alert_id=incident.triggering_alert_id,
        triggering_alert=_alert_response(
            incident.triggering_alert
        ),
        related_alerts=[
            response
            for alert in alerts
            if (response := _alert_response(alert)) is not None
        ],
        suspected_deployment=_deployment_response(
            incident.suspected_deployment
        ),
        failure_started_at=incident.failure_started_at,
        investigation_started_at=(
            incident.investigation_started_at
        ),
        remediation_started_at=(
            incident.remediation_started_at
        ),
        created_by=incident.created_by,
        creator=_operator_response(incident.creator),
        current_assignment=_assignment_response(
            current_assignment
        ),
        assignment_history=[
            response
            for assignment in assignments
            if (
                response := _assignment_response(assignment)
            ) is not None
        ],
        comments=[
            _comment_response(comment)
            for comment in comments
        ],
        metric_snapshot=[
            _metric_response(metric)
            for metric in metrics
        ],
        timeline_summary=[
            _timeline_event_response(event)
            for event in timeline_events
        ],
        resolution_summary=incident.resolution_summary,
        rca_summary=incident.rca_summary,
        remediation_summary=incident.remediation_summary,
        calculated_incident_metrics=(
            _calculated_metrics_response(incident)
        ),
    )


def get_incident_timeline(
    db: Session,
    incident_id: UUID,
) -> IncidentTimelineResponse | None:
    incident = repository.get_incident_by_id(
        db,
        incident_id,
    )

    if incident is None:
        return None

    events = repository.get_incident_timeline(
        db,
        incident.id,
    )

    return IncidentTimelineResponse(
        incident_id=incident.id,
        incident_number=incident.incident_number,
        timeline=[
            _timeline_event_response(event)
            for event in events
        ],
        calculated_incident_metrics=(
            _calculated_metrics_response(incident)
        ),
    )


def _is_more_severe(
    candidate: IncidentSeverity,
    current: IncidentSeverity,
) -> bool:
    return (
        _SEVERITY_RANK[candidate]
        > _SEVERITY_RANK[current]
    )


def create_or_update_incident_from_alert(
    db: Session,
    alert: ReliabilityAlert,
    *,
    environment: str,
    failure_started_at: datetime | None = None,
    affected_service_count: int = 1,
    availability_percent: float | None = None,
    high_severity_alert_count: int = 0,
    actor_user_id: str | None = None,
) -> IncidentDetailResponse:
    """
    Create or update an open incident for a reliability alert.

    ReliabilityAlert has no environment column, so callers must supply
    the environment from the event or telemetry context.
    """
    try:
        normalised_environment = environment.strip()

        if not normalised_environment:
            raise ValueError(
                "Incident environment must not be empty"
            )

        if availability_percent is None:
            alert_type = _enum_value(alert.alert_type)

            if alert_type == "AVAILABILITY_BREACH":
                availability_percent = float(
                    alert.triggered_value
                )

        deduplication_key = build_deduplication_key(
            alert.service_id,
            normalised_environment,
            alert.alert_type,
        )

        severity = calculate_incident_severity(
            alert.severity,
            affected_service_count=affected_service_count,
            availability_percent=availability_percent,
            high_severity_alert_count=(
                high_severity_alert_count
            ),
        )

        incident = (
            repository.find_open_incident_by_deduplication_key(
                db,
                deduplication_key,
            )
        )
        should_capture_alert_metrics = True

        if incident is None:
            service_name = (
                alert.service.name
                if alert.service is not None
                else str(alert.service_id)
            )
            alert_name = str(
                _enum_value(alert.alert_type)
            ).replace("_", " ").title()

            detected_at = alert.created_at or _utcnow()
            failure_time = (
                failure_started_at or detected_at
            )

            incident = repository.create_incident(
                db,
                title=f"{alert_name}: {service_name}",
                description=(
                    "Automatically created from reliability "
                    f"alert {alert.id}."
                ),
                severity=severity,
                status=IncidentStatus.DETECTED,
                primary_service_id=alert.service_id,
                environment=normalised_environment,
                triggering_alert_id=alert.id,
                suspected_deployment_id=alert.deployment_id,
                deduplication_key=deduplication_key,
                failure_started_at=failure_time,
                detected_at=detected_at,
                created_by=actor_user_id,
                service_id=alert.service_id,
                correlation_id=deduplication_key,
                triggered_by_event_id=alert.id,
            )

            repository.link_alert_to_incident(
                db,
                incident_id=incident.id,
                reliability_alert_id=alert.id,
                is_triggering_alert=True,
            )

            repository.create_timeline_event(
                db,
                incident_id=incident.id,
                event_type=get_timeline_event_type(
                    IncidentStatus.DETECTED
                ),
                source="RELIABILITY_ALERT",
                message=(
                    "Incident automatically detected from "
                    f"reliability alert {alert.id}."
                ),
                to_status=IncidentStatus.DETECTED,
                actor_user_id=actor_user_id,
                alert_id=alert.id,
                deployment_id=alert.deployment_id,
                metadata_json={
                    "deduplication_key": deduplication_key,
                    "alert_type": _enum_value(
                        alert.alert_type
                    ),
                    "alert_severity": _enum_value(
                        alert.severity
                    ),
                    "incident_severity": severity.value,
                },
                occurred_at=detected_at,
            )

            repository.create_audit_event(
                db,
                action="INCIDENT_CREATED",
                entity_type="INCIDENT",
                entity_id=str(incident.id),
                actor_id=actor_user_id,
                details=_json_details(
                    alert_id=alert.id,
                    service_id=alert.service_id,
                    environment=normalised_environment,
                    severity=severity.value,
                    deduplication_key=deduplication_key,
                ),
            )
        else:
            linked_alerts = repository.get_incident_alerts(
                db,
                incident.id,
            )
            linked_alert_ids = {
                str(linked_alert.id)
                for linked_alert in linked_alerts
            }
            should_capture_alert_metrics = (
                str(alert.id) not in linked_alert_ids
            )

            if should_capture_alert_metrics:
                repository.link_alert_to_incident(
                    db,
                    incident_id=incident.id,
                    reliability_alert_id=alert.id,
                    is_triggering_alert=False,
                )

                repository.create_timeline_event(
                    db,
                    incident_id=incident.id,
                    event_type="ALERT_LINKED",
                    source="RELIABILITY_ALERT",
                    message=(
                        f"Reliability alert {alert.id} linked "
                        "to the existing incident."
                    ),
                    actor_user_id=actor_user_id,
                    alert_id=alert.id,
                    deployment_id=alert.deployment_id,
                    metadata_json={
                        "alert_type": _enum_value(
                            alert.alert_type
                        ),
                        "alert_severity": _enum_value(
                            alert.severity
                        ),
                    },
                )

                repository.create_audit_event(
                    db,
                    action="INCIDENT_ALERT_LINKED",
                    entity_type="INCIDENT",
                    entity_id=str(incident.id),
                    actor_id=actor_user_id,
                    details=_json_details(
                        alert_id=alert.id,
                    ),
                )

            if _is_more_severe(
                severity,
                incident.severity,
            ):
                previous_severity = incident.severity

                repository.update_incident_severity(
                    db,
                    incident,
                    severity=severity,
                )

                repository.create_timeline_event(
                    db,
                    incident_id=incident.id,
                    event_type="SEVERITY_ESCALATED",
                    source="RELIABILITY_RULE",
                    message=(
                        "Incident severity escalated from "
                        f"{previous_severity.value} to "
                        f"{severity.value}."
                    ),
                    actor_user_id=actor_user_id,
                    alert_id=alert.id,
                    deployment_id=alert.deployment_id,
                    metadata_json={
                        "from_severity": (
                            previous_severity.value
                        ),
                        "to_severity": severity.value,
                    },
                )

                repository.create_audit_event(
                    db,
                    action="INCIDENT_SEVERITY_ESCALATED",
                    entity_type="INCIDENT",
                    entity_id=str(incident.id),
                    actor_id=actor_user_id,
                    details=_json_details(
                        from_severity=(
                            previous_severity.value
                        ),
                        to_severity=severity.value,
                        alert_id=alert.id,
                    ),
                )

        if should_capture_alert_metrics:
            repository.create_metric_snapshot(
                db,
                incident_id=incident.id,
                metric_type="RELIABILITY_ALERT",
                metric_name="triggered_value",
                value=float(alert.triggered_value),
                source="RELIABILITY_ALERT",
                metadata_json={
                    "alert_id": str(alert.id),
                    "alert_type": _enum_value(
                        alert.alert_type
                    ),
                },
            )
            repository.create_metric_snapshot(
                db,
                incident_id=incident.id,
                metric_type="RELIABILITY_ALERT",
                metric_name="threshold_value",
                value=float(alert.threshold_value),
                source="RELIABILITY_ALERT",
                metadata_json={
                    "alert_id": str(alert.id),
                    "alert_type": _enum_value(
                        alert.alert_type
                    ),
                },
            )

        db.commit()
        db.refresh(incident)

        detail = get_incident_detail(
            db,
            incident.id,
        )

        if detail is None:
            raise RuntimeError(
                "Incident was committed but could not be reloaded"
            )

        return detail

    except Exception:
        db.rollback()
        raise


def _stage_status_update(
    db: Session,
    incident: Incident,
    request: IncidentStatusUpdateRequest,
    *,
    actor_user_id: str | None,
    occurred_at: datetime,
) -> Incident:
    previous_status = incident.status
    requested_status = request.status

    validate_status_transition(
        current_status=previous_status,
        new_status=requested_status,
    )

    field_updates: dict[str, Any] = {}

    if (
        requested_status == IncidentStatus.ACKNOWLEDGED
        and incident.acknowledged_at is None
    ):
        field_updates["acknowledged_at"] = occurred_at

    if (
        requested_status == IncidentStatus.INVESTIGATING
        and incident.investigation_started_at is None
    ):
        field_updates[
            "investigation_started_at"
        ] = occurred_at

    if (
        requested_status == IncidentStatus.REMEDIATING
        and incident.remediation_started_at is None
    ):
        field_updates[
            "remediation_started_at"
        ] = occurred_at

    if requested_status == IncidentStatus.RESOLVED:
        field_updates["resolved_at"] = occurred_at

    if request.resolution_summary is not None:
        field_updates["resolution_summary"] = (
            request.resolution_summary
        )

    if request.rca_summary is not None:
        field_updates["rca_summary"] = request.rca_summary

    if request.remediation_summary is not None:
        field_updates["remediation_summary"] = (
            request.remediation_summary
        )

    repository.update_incident_status(
        db,
        incident,
        status=requested_status,
        **field_updates,
    )

    repository.create_timeline_event(
        db,
        incident_id=incident.id,
        event_type=get_timeline_event_type(
            requested_status
        ),
        source=(
            "OPERATOR"
            if actor_user_id is not None
            else "SYSTEM"
        ),
        message=(
            request.note
            or (
                "Incident status changed from "
                f"{previous_status.value} to "
                f"{requested_status.value}."
            )
        ),
        from_status=previous_status,
        to_status=requested_status,
        actor_user_id=actor_user_id,
        occurred_at=occurred_at,
    )

    repository.create_audit_event(
        db,
        action="INCIDENT_STATUS_UPDATED",
        entity_type="INCIDENT",
        entity_id=str(incident.id),
        actor_id=actor_user_id,
        details=_json_details(
            from_status=previous_status.value,
            to_status=requested_status.value,
            note=request.note,
        ),
    )

    return incident


def update_incident_status(
    db: Session,
    incident_id: UUID,
    request: IncidentStatusUpdateRequest,
    *,
    actor_user_id: str | None = None,
) -> IncidentDetailResponse | None:
    try:
        incident = repository.get_incident_by_id(
            db,
            incident_id,
        )

        if incident is None:
            return None

        _stage_status_update(
            db,
            incident,
            request,
            actor_user_id=actor_user_id,
            occurred_at=_utcnow(),
        )

        db.commit()
        db.refresh(incident)

        return get_incident_detail(
            db,
            incident.id,
        )

    except Exception:
        db.rollback()
        raise


def acknowledge_incident(
    db: Session,
    incident_id: UUID,
    request: IncidentAcknowledgeRequest,
    *,
    actor_user_id: str | None = None,
) -> IncidentDetailResponse | None:
    try:
        incident = repository.get_incident_by_id(
            db,
            incident_id,
        )

        if incident is None:
            return None

        now = _utcnow()

        status_request = IncidentStatusUpdateRequest(
            status=IncidentStatus.ACKNOWLEDGED,
            note=request.note,
        )

        _stage_status_update(
            db,
            incident,
            status_request,
            actor_user_id=actor_user_id,
            occurred_at=now,
        )

        if request.assigned_to_user_id is not None:
            repository.close_active_assignment(
                db,
                incident_id=incident.id,
                unassigned_at=now,
            )

            repository.create_assignment(
                db,
                incident_id=incident.id,
                assigned_to_user_id=(
                    request.assigned_to_user_id
                ),
                assigned_by_user_id=actor_user_id,
                assignment_note=(
                    "Assigned during incident acknowledgement"
                ),
                assigned_at=now,
            )

            repository.update_incident(
                db,
                incident,
                current_assignee_id=(
                    request.assigned_to_user_id
                ),
            )

            repository.create_timeline_event(
                db,
                incident_id=incident.id,
                event_type="OPERATOR_ASSIGNED",
                source="OPERATOR",
                message=(
                    "Incident assigned during acknowledgement."
                ),
                actor_user_id=actor_user_id,
                metadata_json={
                    "assigned_to_user_id": (
                        request.assigned_to_user_id
                    ),
                },
                occurred_at=now,
            )

            repository.create_audit_event(
                db,
                action="INCIDENT_ASSIGNED",
                entity_type="INCIDENT",
                entity_id=str(incident.id),
                actor_id=actor_user_id,
                details=_json_details(
                    assigned_to_user_id=(
                        request.assigned_to_user_id
                    ),
                    assignment_source="ACKNOWLEDGEMENT",
                ),
            )

        db.commit()
        db.refresh(incident)

        return get_incident_detail(
            db,
            incident.id,
        )

    except Exception:
        db.rollback()
        raise


def assign_incident(
    db: Session,
    incident_id: UUID,
    request: IncidentAssignmentRequest,
    *,
    assigned_by_user_id: str | None = None,
) -> IncidentAssignmentResponse | None:
    try:
        incident = repository.get_incident_by_id(
            db,
            incident_id,
        )

        if incident is None:
            return None

        now = _utcnow()

        repository.close_active_assignment(
            db,
            incident_id=incident.id,
            unassigned_at=now,
        )

        assignment = repository.create_assignment(
            db,
            incident_id=incident.id,
            assigned_to_user_id=(
                request.assigned_to_user_id
            ),
            assigned_by_user_id=assigned_by_user_id,
            assignment_note=request.assignment_note,
            assigned_at=now,
        )

        repository.update_incident(
            db,
            incident,
            current_assignee_id=(
                request.assigned_to_user_id
            ),
        )

        repository.create_timeline_event(
            db,
            incident_id=incident.id,
            event_type="OPERATOR_ASSIGNED",
            source="OPERATOR",
            message=(
                request.assignment_note
                or (
                    "Incident assigned to operator "
                    f"{request.assigned_to_user_id}."
                )
            ),
            actor_user_id=assigned_by_user_id,
            metadata_json={
                "assigned_to_user_id": (
                    request.assigned_to_user_id
                ),
            },
            occurred_at=now,
        )

        repository.create_audit_event(
            db,
            action="INCIDENT_ASSIGNED",
            entity_type="INCIDENT",
            entity_id=str(incident.id),
            actor_id=assigned_by_user_id,
            details=_json_details(
                assigned_to_user_id=(
                    request.assigned_to_user_id
                ),
                assignment_note=request.assignment_note,
            ),
        )

        db.commit()
        db.refresh(assignment)

        response = _assignment_response(assignment)

        if response is None:
            raise RuntimeError(
                "Assignment was committed but not returned"
            )

        return response

    except Exception:
        db.rollback()
        raise


def add_incident_comment(
    db: Session,
    incident_id: UUID,
    request: IncidentCommentCreateRequest,
    *,
    author_user_id: str | None = None,
) -> IncidentCommentResponse | None:
    try:
        incident = repository.get_incident_by_id(
            db,
            incident_id,
        )

        if incident is None:
            return None

        comment = repository.create_comment(
            db,
            incident_id=incident.id,
            comment=request.comment,
            author_user_id=author_user_id,
        )

        repository.create_timeline_event(
            db,
            incident_id=incident.id,
            event_type="COMMENT_ADDED",
            source=(
                "OPERATOR"
                if author_user_id is not None
                else "SYSTEM"
            ),
            message="A comment was added to the incident.",
            actor_user_id=author_user_id,
            metadata_json={
                "comment_id": str(comment.id),
            },
        )

        repository.create_audit_event(
            db,
            action="INCIDENT_COMMENT_ADDED",
            entity_type="INCIDENT",
            entity_id=str(incident.id),
            actor_id=author_user_id,
            details=_json_details(
                comment_id=comment.id,
            ),
        )

        db.commit()
        db.refresh(comment)

        return _comment_response(comment)

    except Exception:
        db.rollback()
        raise


def capture_incident_metric(
    db: Session,
    incident_id: UUID,
    *,
    metric_type: str,
    metric_name: str,
    value: float,
    source: str,
    unit: str | None = None,
    captured_at: datetime | None = None,
    metadata_json: dict[str, Any] | None = None,
    actor_user_id: str | None = None,
) -> IncidentMetricResponse | None:
    try:
        incident = repository.get_incident_by_id(
            db,
            incident_id,
        )

        if incident is None:
            return None

        numeric_value = float(value)
        event_time = captured_at or _utcnow()

        metric = repository.create_metric_snapshot(
            db,
            incident_id=incident.id,
            metric_type=metric_type,
            metric_name=metric_name,
            value=numeric_value,
            source=source,
            unit=unit,
            captured_at=event_time,
            metadata_json=metadata_json,
        )

        repository.create_timeline_event(
            db,
            incident_id=incident.id,
            event_type="METRIC_CAPTURED",
            source=source,
            message=(
                f"Captured metric {metric_name}: "
                f"{numeric_value}"
                f"{f' {unit}' if unit else ''}."
            ),
            actor_user_id=actor_user_id,
            metadata_json={
                "metric_id": str(metric.id),
                "metric_type": metric_type,
                "metric_name": metric_name,
                "value": numeric_value,
                "unit": unit,
            },
            occurred_at=event_time,
        )

        repository.create_audit_event(
            db,
            action="INCIDENT_METRIC_CAPTURED",
            entity_type="INCIDENT",
            entity_id=str(incident.id),
            actor_id=actor_user_id,
            details=_json_details(
                metric_id=metric.id,
                metric_type=metric_type,
                metric_name=metric_name,
                value=numeric_value,
                unit=unit,
                source=source,
            ),
        )

        db.commit()
        db.refresh(metric)

        return _metric_response(metric)

    except Exception:
        db.rollback()
        raise

def get_service_runtime_timeline(
    db: Session,
    service_id: str,
    *,
    environment: str | None = None,
    incident_limit: int = 10,
    snapshot_limit: int = 50,
) -> dict[str, Any]:
    """Build the compatibility runtime timeline without router-level SQL."""
    from app.observability.service import (
        get_service_health_history,
    )

    incidents = repository.list_incidents(
        db,
        service_id=service_id,
        environment=environment,
        offset=0,
        limit=incident_limit,
    )

    timeline: list[dict[str, Any]] = []

    for incident in incidents:
        events = repository.get_incident_timeline(
            db,
            incident.id,
        )

        for event in events:
            timeline.append(
                {
                    "source": (
                        event.source
                        or "incident_timeline_events"
                    ),
                    "type": event.event_type,
                    "message": event.message,
                    "metadata": {
                        **(event.metadata_json or {}),
                        "incident_id": str(incident.id),
                        "incident_number": (
                            incident.incident_number
                        ),
                        "from_status": _enum_value(
                            event.from_status
                        ),
                        "to_status": _enum_value(
                            event.to_status
                        ),
                        "alert_id": event.alert_id,
                        "deployment_id": (
                            str(event.deployment_id)
                            if event.deployment_id
                            else None
                        ),
                    },
                    "timestamp": event.occurred_at,
                }
            )

    snapshots = get_service_health_history(
        db,
        service_id,
        limit=snapshot_limit,
    )

    for snapshot in snapshots:
        if (
            environment is not None
            and snapshot.environment != environment
        ):
            continue

        timeline.append(
            {
                "source": "service_health_snapshots",
                "type": "HEALTH_SNAPSHOT",
                "message": (
                    "Service health snapshot recorded "
                    f"with status "
                    f"{_enum_value(snapshot.status)}"
                ),
                "metadata": {
                    "snapshot_id": str(snapshot.id),
                    "service_id": str(snapshot.service_id),
                    "service_name": snapshot.service_name,
                    "environment": snapshot.environment,
                    "status": _enum_value(snapshot.status),
                    "latency_ms": snapshot.latency_ms,
                    "error_rate": snapshot.error_rate,
                    "cpu_usage": snapshot.cpu_usage,
                    "memory_usage": snapshot.memory_usage,
                    "pod_restart_count": (
                        snapshot.pod_restart_count
                    ),
                    "replica_count": snapshot.replica_count,
                    "available_replicas": (
                        snapshot.available_replicas
                    ),
                    "source": snapshot.source,
                },
                "timestamp": snapshot.created_at,
            }
        )

    timeline.sort(
        key=lambda item: str(
            item.get("timestamp") or ""
        ),
        reverse=True,
    )

    return {
        "service_id": service_id,
        "timeline": timeline,
    }

