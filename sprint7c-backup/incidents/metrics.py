"""Pure incident response-time metric calculations."""

from datetime import datetime, timedelta
from typing import TypedDict


class IncidentMetricDurations(TypedDict):
    """Calculated incident durations."""

    mttd: timedelta | None
    mtta: timedelta | None
    mttr: timedelta | None
    impact_duration: timedelta | None


def _calculate_duration(
    start_time: datetime | None,
    end_time: datetime | None,
) -> timedelta | None:
    """
    Calculate the duration between two timestamps.

    None is returned when either required timestamp is missing.
    """
    if start_time is None or end_time is None:
        return None

    return end_time - start_time


def calculate_mttd(
    failure_started_at: datetime | None,
    detected_at: datetime | None,
) -> timedelta | None:
    """
    Calculate Mean Time to Detect.

    MTTD = detected_at - failure_started_at
    """
    return _calculate_duration(
        failure_started_at,
        detected_at,
    )


def calculate_mtta(
    detected_at: datetime | None,
    acknowledged_at: datetime | None,
) -> timedelta | None:
    """
    Calculate Mean Time to Acknowledge.

    MTTA = acknowledged_at - detected_at
    """
    return _calculate_duration(
        detected_at,
        acknowledged_at,
    )


def calculate_mttr(
    detected_at: datetime | None,
    resolved_at: datetime | None,
) -> timedelta | None:
    """
    Calculate Mean Time to Resolve.

    MTTR = resolved_at - detected_at
    """
    return _calculate_duration(
        detected_at,
        resolved_at,
    )


def calculate_impact_duration(
    failure_started_at: datetime | None,
    resolved_at: datetime | None,
) -> timedelta | None:
    """
    Calculate the total customer-impact duration.

    Impact duration = resolved_at - failure_started_at
    """
    return _calculate_duration(
        failure_started_at,
        resolved_at,
    )


def calculate_incident_metrics(
    *,
    failure_started_at: datetime | None,
    detected_at: datetime | None,
    acknowledged_at: datetime | None,
    resolved_at: datetime | None,
) -> IncidentMetricDurations:
    """
    Calculate all incident response-time metrics together.
    """
    return {
        "mttd": calculate_mttd(
            failure_started_at,
            detected_at,
        ),
        "mtta": calculate_mtta(
            detected_at,
            acknowledged_at,
        ),
        "mttr": calculate_mttr(
            detected_at,
            resolved_at,
        ),
        "impact_duration": calculate_impact_duration(
            failure_started_at,
            resolved_at,
        ),
    }
