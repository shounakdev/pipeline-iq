"""Pure incident lifecycle transition validation rules."""

from app.models import IncidentStatus


ALLOWED_TRANSITIONS: dict[
    IncidentStatus,
    set[IncidentStatus],
] = {
    IncidentStatus.DETECTED: {
        IncidentStatus.ACKNOWLEDGED,
    },
    IncidentStatus.ACKNOWLEDGED: {
        IncidentStatus.INVESTIGATING,
    },
    IncidentStatus.INVESTIGATING: {
        IncidentStatus.ACTION_RECOMMENDED,
        IncidentStatus.REMEDIATING,
        IncidentStatus.RESOLVED,
    },
    IncidentStatus.ACTION_RECOMMENDED: {
        IncidentStatus.REMEDIATING,
        IncidentStatus.RESOLVED,
    },
    IncidentStatus.REMEDIATING: {
        IncidentStatus.RESOLVED,
        IncidentStatus.FAILED_RECOVERY,
    },
    IncidentStatus.FAILED_RECOVERY: {
        IncidentStatus.INVESTIGATING,
        IncidentStatus.ACTION_RECOMMENDED,
        IncidentStatus.REMEDIATING,
    },
    IncidentStatus.RESOLVED: set(),
}


def _normalise_status(
    status: IncidentStatus | str,
) -> IncidentStatus:
    """
    Convert an IncidentStatus or string into IncidentStatus.

    Both persisted values and enum member names are accepted.
    This also supports temporary compatibility aliases such as OPEN.
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


def validate_status_transition(
    current_status: IncidentStatus | str,
    new_status: IncidentStatus | str,
) -> None:
    """
    Validate an incident lifecycle transition.

    Returns None when the transition is allowed.

    Raises:
        ValueError: When either status is unsupported or the transition
        is not permitted by the incident lifecycle.
    """
    current = _normalise_status(current_status)
    target = _normalise_status(new_status)

    allowed_targets = ALLOWED_TRANSITIONS[current]

    if target not in allowed_targets:
        allowed_values = sorted(
            status.value for status in allowed_targets
        )

        allowed_description = (
            ", ".join(allowed_values)
            if allowed_values
            else "no further statuses"
        )

        raise ValueError(
            "Invalid incident status transition: "
            f"{current.value} -> {target.value}. "
            f"Allowed from {current.value}: "
            f"{allowed_description}."
        )
