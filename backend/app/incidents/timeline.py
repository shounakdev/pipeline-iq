"""Pure incident lifecycle-to-timeline mapping rules."""

from app.models import IncidentStatus


STATUS_TO_TIMELINE_EVENT_TYPE: dict[IncidentStatus, str] = {
    IncidentStatus.DETECTED: "INCIDENT_DETECTED",
    IncidentStatus.ACKNOWLEDGED: "INCIDENT_ACKNOWLEDGED",
    IncidentStatus.INVESTIGATING: "INVESTIGATION_STARTED",
    IncidentStatus.ACTION_RECOMMENDED: "ACTION_RECOMMENDED",
    IncidentStatus.REMEDIATING: "REMEDIATION_STARTED",
    IncidentStatus.RESOLVED: "INCIDENT_RESOLVED",
    IncidentStatus.FAILED_RECOVERY: "RECOVERY_FAILED",
}


def _normalise_status(
    status: IncidentStatus | str,
) -> IncidentStatus:
    """
    Convert an IncidentStatus or string into IncidentStatus.

    Persisted values, enum member names, and temporary compatibility
    aliases are accepted.
    """
    if isinstance(status, IncidentStatus):
        return status

    normalised = str(status).strip().upper()

    if not normalised:
        raise ValueError("Incident status must not be empty")

    try:
        return IncidentStatus(normalised)
    except ValueError:
        try:
            return IncidentStatus[normalised]
        except KeyError as exc:
            raise ValueError(
                f"Unsupported incident status: {status!r}"
            ) from exc


def get_timeline_event_type(
    status: IncidentStatus | str,
) -> str:
    """
    Return the timeline event type for an incident lifecycle status.
    """
    normalised_status = _normalise_status(status)

    return STATUS_TO_TIMELINE_EVENT_TYPE[normalised_status]
