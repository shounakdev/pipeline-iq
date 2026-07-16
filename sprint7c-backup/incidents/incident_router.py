"""HTTP routes for Sprint 7 incident operations.

The router translates HTTP input/output and delegates all incident business
logic and transaction handling to app.incidents.service.
"""

from __future__ import annotations

from typing import Any
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.incidents import service as incident_service
from app.incidents.schemas import (
    IncidentAcknowledgeRequest,
    IncidentAssignmentRequest,
    IncidentAssignmentResponse,
    IncidentCommentCreateRequest,
    IncidentCommentResponse,
    IncidentDetailResponse,
    IncidentListResponse,
    IncidentStatusUpdateRequest,
    IncidentTimelineResponse,
)
from app.models import IncidentSeverity, IncidentStatus


router = APIRouter(
    prefix="/api/incidents",
    tags=["incidents"],
)

service_runtime_router = APIRouter(
    prefix="/api/services",
    tags=["runtime-timeline"],
)


def _require_found(result: Any) -> Any:
    if result is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Incident not found",
        )

    return result


@router.get(
    "",
    response_model=list[IncidentListResponse],
)
def list_incidents_endpoint(
    status_filter: IncidentStatus | None = Query(
        default=None,
        alias="status",
    ),
    severity_filter: IncidentSeverity | None = Query(
        default=None,
        alias="severity",
    ),
    service_id: str | None = Query(default=None),
    environment: str | None = Query(default=None),
    assigned_to_user_id: str | None = Query(default=None),
    offset: int = Query(default=0, ge=0),
    limit: int = Query(default=100, ge=1, le=500),
    db: Session = Depends(get_db),
):
    return incident_service.list_incidents(
        db=db,
        statuses=[status_filter] if status_filter else None,
        severities=[severity_filter] if severity_filter else None,
        service_id=service_id,
        environment=environment,
        assigned_to_user_id=assigned_to_user_id,
        offset=offset,
        limit=limit,
    )


@router.get(
    "/{incident_id}",
    response_model=IncidentDetailResponse,
)
def get_incident_endpoint(
    incident_id: UUID,
    db: Session = Depends(get_db),
):
    result = incident_service.get_incident_detail(
        db=db,
        incident_id=incident_id,
    )

    return _require_found(result)


@router.get(
    "/{incident_id}/timeline",
    response_model=IncidentTimelineResponse,
)
def get_incident_timeline_endpoint(
    incident_id: UUID,
    db: Session = Depends(get_db),
):
    result = incident_service.get_incident_timeline(
        db=db,
        incident_id=incident_id,
    )

    return _require_found(result)


@router.post(
    "/{incident_id}/acknowledge",
    response_model=IncidentDetailResponse,
)
def acknowledge_incident_endpoint(
    incident_id: UUID,
    request: IncidentAcknowledgeRequest | None = None,
    db: Session = Depends(get_db),
):
    try:
        result = incident_service.acknowledge_incident(
            db=db,
            incident_id=incident_id,
            request=request or IncidentAcknowledgeRequest(),
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc

    return _require_found(result)


@router.post(
    "/{incident_id}/resolve",
    response_model=IncidentDetailResponse,
)
def resolve_incident_endpoint(
    incident_id: UUID,
    db: Session = Depends(get_db),
):
    request = IncidentStatusUpdateRequest(
        status=IncidentStatus.RESOLVED,
    )

    try:
        result = incident_service.update_incident_status(
            db=db,
            incident_id=incident_id,
            request=request,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc

    return _require_found(result)


@router.patch(
    "/{incident_id}/status",
    response_model=IncidentDetailResponse,
)
def update_incident_status_endpoint(
    incident_id: UUID,
    request: IncidentStatusUpdateRequest,
    db: Session = Depends(get_db),
):
    try:
        result = incident_service.update_incident_status(
            db=db,
            incident_id=incident_id,
            request=request,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc

    return _require_found(result)


@router.post(
    "/{incident_id}/assign",
    response_model=IncidentAssignmentResponse,
)
def assign_incident_endpoint(
    incident_id: UUID,
    request: IncidentAssignmentRequest,
    db: Session = Depends(get_db),
):
    result = incident_service.assign_incident(
        db=db,
        incident_id=incident_id,
        request=request,
    )

    return _require_found(result)


@router.post(
    "/{incident_id}/comments",
    response_model=IncidentCommentResponse,
)
def add_incident_comment_endpoint(
    incident_id: UUID,
    request: IncidentCommentCreateRequest,
    db: Session = Depends(get_db),
):
    result = incident_service.add_incident_comment(
        db=db,
        incident_id=incident_id,
        request=request,
    )

    return _require_found(result)


@service_runtime_router.get(
    "/{service_id}/incidents",
    response_model=list[IncidentListResponse],
)
def get_service_incidents_endpoint(
    service_id: str,
    status_filter: IncidentStatus | None = Query(
        default=None,
        alias="status",
    ),
    environment: str | None = Query(default=None),
    offset: int = Query(default=0, ge=0),
    limit: int = Query(default=100, ge=1, le=500),
    db: Session = Depends(get_db),
):
    return incident_service.list_incidents(
        db=db,
        statuses=[status_filter] if status_filter else None,
        service_id=service_id,
        environment=environment,
        offset=offset,
        limit=limit,
    )


@service_runtime_router.get(
    "/{service_id}/runtime-timeline",
    response_model=dict[str, Any],
)
def get_service_runtime_timeline_endpoint(
    service_id: str,
    environment: str | None = Query(default=None),
    db: Session = Depends(get_db),
):
    return incident_service.get_service_runtime_timeline(
        db=db,
        service_id=service_id,
        environment=environment,
    )
