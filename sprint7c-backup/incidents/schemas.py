from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.models import IncidentSeverity, IncidentStatus


class ResponseSchema(BaseModel):
    """
    Common configuration for schemas returned by the incident APIs.
    """

    model_config = ConfigDict(from_attributes=True)


class RequestSchema(BaseModel):
    """
    Common configuration for incident request bodies.
    """

    model_config = ConfigDict(extra="forbid")


# ---------------------------------------------------------------------------
# Shared summary responses
# ---------------------------------------------------------------------------


class ServiceSummaryResponse(ResponseSchema):
    id: str
    name: str
    service_type: str | None = None
    owner: str | None = None


class OperatorSummaryResponse(ResponseSchema):
    id: str
    email: str
    full_name: str | None = None


class ReliabilityAlertSummaryResponse(ResponseSchema):
    id: str
    service_id: str
    slo_definition_id: str
    alert_type: str
    severity: str
    triggered_value: float
    threshold_value: float
    deployment_id: UUID | None = None
    status: str
    created_at: datetime
    resolved_at: datetime | None = None


class DeploymentSummaryResponse(ResponseSchema):
    id: UUID
    service_id: str
    service_name: str | None = None
    environment_id: str | None = None
    image_tag: str
    deployment_version: str | None = None
    commit_sha: str | None = None
    argo_sync_status: str | None = None
    kubernetes_rollout_status: str | None = None
    deployed_at: datetime | None = None
    created_at: datetime


# ---------------------------------------------------------------------------
# Timeline responses
# ---------------------------------------------------------------------------


class IncidentTimelineEventResponse(ResponseSchema):
    id: UUID
    incident_id: UUID

    event_type: str
    source: str
    message: str | None = None

    from_status: IncidentStatus | None = None
    to_status: IncidentStatus | None = None

    actor_user_id: str | None = None
    actor: OperatorSummaryResponse | None = None

    alert_id: str | None = None
    alert: ReliabilityAlertSummaryResponse | None = None

    deployment_id: UUID | None = None
    deployment: DeploymentSummaryResponse | None = None

    metadata_json: dict[str, Any] | None = None

    occurred_at: datetime
    created_at: datetime


# ---------------------------------------------------------------------------
# Assignment requests and responses
# ---------------------------------------------------------------------------


class IncidentAssignmentRequest(RequestSchema):
    assigned_to_user_id: str = Field(
        min_length=1,
        max_length=36,
    )
    assignment_note: str | None = Field(
        default=None,
        max_length=4000,
    )


class IncidentAssignmentResponse(ResponseSchema):
    id: UUID
    incident_id: UUID

    assigned_to_user_id: str | None = None
    assigned_to_user: OperatorSummaryResponse | None = None

    assigned_by_user_id: str | None = None
    assigned_by_user: OperatorSummaryResponse | None = None

    assignment_note: str | None = None

    assigned_at: datetime
    unassigned_at: datetime | None = None
    is_active: bool


# ---------------------------------------------------------------------------
# Incident update requests
# ---------------------------------------------------------------------------


class IncidentStatusUpdateRequest(RequestSchema):
    status: IncidentStatus

    note: str | None = Field(
        default=None,
        max_length=4000,
    )

    resolution_summary: str | None = Field(
        default=None,
        max_length=10000,
    )
    rca_summary: str | None = Field(
        default=None,
        max_length=10000,
    )
    remediation_summary: str | None = Field(
        default=None,
        max_length=10000,
    )


class IncidentAcknowledgeRequest(RequestSchema):
    assigned_to_user_id: str | None = Field(
        default=None,
        min_length=1,
        max_length=36,
    )
    note: str | None = Field(
        default=None,
        max_length=4000,
    )


# ---------------------------------------------------------------------------
# Comment requests and responses
# ---------------------------------------------------------------------------


class IncidentCommentCreateRequest(RequestSchema):
    comment: str = Field(
        min_length=1,
        max_length=10000,
    )


class IncidentCommentResponse(ResponseSchema):
    id: UUID
    incident_id: UUID

    author_user_id: str | None = None
    author: OperatorSummaryResponse | None = None

    comment: str

    created_at: datetime
    updated_at: datetime


# ---------------------------------------------------------------------------
# Incident metric responses
# ---------------------------------------------------------------------------


class IncidentMetricResponse(ResponseSchema):
    id: UUID
    incident_id: UUID

    metric_type: str
    metric_name: str
    value: float
    unit: str | None = None
    source: str

    captured_at: datetime
    metadata_json: dict[str, Any] | None = None
    created_at: datetime


class IncidentCalculatedMetricsResponse(ResponseSchema):
    incident_id: UUID

    failure_started_at: datetime | None = None
    detected_at: datetime
    acknowledged_at: datetime | None = None
    resolved_at: datetime | None = None

    mttd_seconds: float | None = Field(
        default=None,
        ge=0,
    )
    mtta_seconds: float | None = Field(
        default=None,
        ge=0,
    )
    mttr_seconds: float | None = Field(
        default=None,
        ge=0,
    )


# ---------------------------------------------------------------------------
# Incident list and detail responses
# ---------------------------------------------------------------------------


class IncidentListResponse(ResponseSchema):
    incident_id: UUID

    # Temporary compatibility field for the current Sprint 5 frontend.
    # Both values will contain the same incident UUID.
    id: UUID | None = None

    incident_number: str
    title: str

    severity: IncidentSeverity
    status: IncidentStatus

    # These represent the new primary_service_id relationship in a
    # frontend-friendly form.
    service_id: str
    service_name: str | None = None

    environment: str

    assigned_operator: OperatorSummaryResponse | None = None
    suspected_deployment_id: UUID | None = None

    detected_at: datetime
    acknowledged_at: datetime | None = None
    resolved_at: datetime | None = None

    created_at: datetime
    updated_at: datetime


class IncidentDetailResponse(ResponseSchema):
    incident: IncidentListResponse

    description: str | None = None
    deduplication_key: str

    primary_service: ServiceSummaryResponse
    affected_services: list[ServiceSummaryResponse] = Field(
        default_factory=list,
    )

    triggering_alert_id: str | None = None
    triggering_alert: ReliabilityAlertSummaryResponse | None = None

    related_alerts: list[ReliabilityAlertSummaryResponse] = Field(
        default_factory=list,
    )

    suspected_deployment: DeploymentSummaryResponse | None = None

    failure_started_at: datetime | None = None
    investigation_started_at: datetime | None = None
    remediation_started_at: datetime | None = None

    created_by: str | None = None
    creator: OperatorSummaryResponse | None = None

    current_assignment: IncidentAssignmentResponse | None = None

    assignment_history: list[IncidentAssignmentResponse] = Field(
        default_factory=list,
    )
    comments: list[IncidentCommentResponse] = Field(
        default_factory=list,
    )
    metric_snapshot: list[IncidentMetricResponse] = Field(
        default_factory=list,
    )
    timeline_summary: list[IncidentTimelineEventResponse] = Field(
        default_factory=list,
    )

    resolution_summary: str | None = None
    rca_summary: str | None = None
    remediation_summary: str | None = None

    calculated_incident_metrics: (
        IncidentCalculatedMetricsResponse | None
    ) = None


class IncidentTimelineResponse(ResponseSchema):
    incident_id: UUID
    incident_number: str

    timeline: list[IncidentTimelineEventResponse] = Field(
        default_factory=list,
    )

    calculated_incident_metrics: (
        IncidentCalculatedMetricsResponse | None
    ) = None