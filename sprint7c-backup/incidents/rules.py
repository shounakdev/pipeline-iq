"""Pure incident deduplication and severity calculation rules."""

from enum import Enum
from typing import Any

from app.models import IncidentSeverity, ReliabilitySeverity


CRITICAL_AVAILABILITY_THRESHOLD = 95.0
HIGH_SEVERITY_ALERT_ESCALATION_COUNT = 3


RELIABILITY_TO_INCIDENT_SEVERITY = {
    ReliabilitySeverity.CRITICAL: IncidentSeverity.SEV_1,
    ReliabilitySeverity.HIGH: IncidentSeverity.SEV_2,
    ReliabilitySeverity.MEDIUM: IncidentSeverity.SEV_3,
    ReliabilitySeverity.LOW: IncidentSeverity.SEV_3,
}


def _enum_value(value: Any) -> str:
    """Return the stored value of an enum or its string value."""
    if isinstance(value, Enum):
        return str(value.value)

    return str(value)


def _normalise_key_part(value: Any, field_name: str) -> str:
    """Normalise one deduplication-key component."""
    if value is None:
        raise ValueError(f"{field_name} is required")

    normalised = _enum_value(value).strip().lower()

    if not normalised:
        raise ValueError(f"{field_name} must not be empty")

    return normalised.replace(":", "-")


def build_deduplication_key(
    service_id: Any,
    environment: str,
    alert_type: Any,
) -> str:
    """
    Build a stable service, environment, and alert-type key.
    """
    return ":".join(
        (
            _normalise_key_part(service_id, "service_id"),
            _normalise_key_part(environment, "environment"),
            _normalise_key_part(alert_type, "alert_type"),
        )
    )


def _normalise_reliability_severity(
    severity: ReliabilitySeverity | str,
) -> ReliabilitySeverity:
    """Convert a reliability-severity string or enum to its enum."""
    if isinstance(severity, ReliabilitySeverity):
        return severity

    try:
        return ReliabilitySeverity(str(severity).strip().upper())
    except ValueError as exc:
        raise ValueError(
            f"Unsupported reliability severity: {severity!r}"
        ) from exc


def should_escalate_severity(
    *,
    affected_service_count: int = 1,
    availability_percent: float | None = None,
    high_severity_alert_count: int = 0,
    critical_availability_threshold: float = (
        CRITICAL_AVAILABILITY_THRESHOLD
    ),
    high_severity_alert_escalation_count: int = (
        HIGH_SEVERITY_ALERT_ESCALATION_COUNT
    ),
) -> bool:
    """
    Determine whether an incident should be escalated to SEV-1.
    """
    if affected_service_count < 0:
        raise ValueError("affected_service_count cannot be negative")

    if high_severity_alert_count < 0:
        raise ValueError(
            "high_severity_alert_count cannot be negative"
        )

    if availability_percent is not None:
        if not 0.0 <= availability_percent <= 100.0:
            raise ValueError(
                "availability_percent must be between 0 and 100"
            )

    multiple_services_affected = affected_service_count > 1

    critically_low_availability = (
        availability_percent is not None
        and availability_percent <= critical_availability_threshold
    )

    several_high_severity_alerts = (
        high_severity_alert_count
        >= high_severity_alert_escalation_count
    )

    return (
        multiple_services_affected
        or critically_low_availability
        or several_high_severity_alerts
    )


def calculate_incident_severity(
    reliability_severity: ReliabilitySeverity | str,
    *,
    affected_service_count: int = 1,
    availability_percent: float | None = None,
    high_severity_alert_count: int = 0,
) -> IncidentSeverity:
    """
    Calculate incident severity from reliability-alert information.
    """
    normalised_severity = _normalise_reliability_severity(
        reliability_severity
    )

    calculated_severity = RELIABILITY_TO_INCIDENT_SEVERITY[
        normalised_severity
    ]

    if calculated_severity is IncidentSeverity.SEV_1:
        return calculated_severity

    if should_escalate_severity(
        affected_service_count=affected_service_count,
        availability_percent=availability_percent,
        high_severity_alert_count=high_severity_alert_count,
    ):
        return IncidentSeverity.SEV_1

    return calculated_severity