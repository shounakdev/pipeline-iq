# Sprint 8A Incident Data Baseline

## Source of truth

Primary model file:

- `backend/app/models.py`

Primary incident repository:

- `backend/app/incidents/repository.py`

Primary incident orchestration service:

- `backend/app/incidents/service.py`

## Incident identity and scope

The `Incident` model contains:

- `id`
- `incident_number`
- `title`
- `description`
- `severity`
- `status`
- `primary_service_id`
- `environment`
- `deduplication_key`

These fields establish the incident identity, affected service, environment,
severity and lifecycle state required by the RCA evidence contract.

## Incident timing fields

The existing incident lifecycle timestamps are:

- `failure_started_at`
- `detected_at`
- `acknowledged_at`
- `investigation_started_at`
- `remediation_started_at`
- `resolved_at`

These timestamps can be used to define the evidence collection window and to
calculate incident response metrics.

## Alert evidence

The incident contains:

- `triggering_alert_id`
- `alert_links`
- `IncidentAlertLink.reliability_alert_id`
- `IncidentAlertLink.is_triggering_alert`
- `IncidentAlertLink.linked_at`

The existing repository can retrieve linked reliability alerts.

The RCA collector should retrieve all linked alerts and separately identify the
triggering alert.

## Deployment evidence

The incident contains:

- `suspected_deployment_id`
- `suspected_deployment` relationship

Timeline events may also contain:

- `deployment_id`
- deployment-related metadata in `metadata_json`

The existing repository contains deterministic suspected-deployment correlation
logic.

The RCA collector should not ask the LLM to determine the deployment correlation
from an incident description alone. It should provide the stored suspected
deployment and supporting timestamps.

## Timeline evidence

`IncidentTimelineEvent` contains:

- `event_type`
- `source`
- `message`
- `from_status`
- `to_status`
- `actor_user_id`
- `alert_id`
- `deployment_id`
- `metadata_json`
- `occurred_at`
- `created_at`

The repository returns timeline events ordered by:

1. `occurred_at ASC`
2. `id ASC`

This provides deterministic chronological evidence for RCA generation.

## Metric evidence

`IncidentMetric` contains:

- `metric_type`
- `metric_name`
- `value`
- `unit`
- `source`
- `captured_at`
- `metadata_json`

The repository returns metric snapshots ordered by:

1. `captured_at ASC`
2. `id ASC`

These stored metrics can be included directly in the structured evidence JSON.

## Assignment and comment context

The incident has:

- assignment history
- active assignment
- comments

Assignment and comment records may provide investigation context, but they must
be classified as human-authored context rather than deterministic telemetry.

The RCA evidence JSON should distinguish:

- system evidence
- observability evidence
- deployment evidence
- pipeline evidence
- human investigation notes

## Existing retrieval functions

Existing repository functionality includes retrieval of:

- incident details
- linked reliability alerts
- active assignment
- assignment history
- incident metrics
- incident timeline
- suspected deployment

Sprint 8 should reuse or wrap these repository functions rather than duplicate
database queries inside the LLM integration layer.

## Initial RCA contract implications

The incident evidence collector should accept an `incident_id` and assemble:

- incident identity
- affected service and environment
- lifecycle timestamps
- triggering alert
- all linked alerts
- suspected deployment
- incident timeline
- stored metric snapshots
- calculated incident response metrics
- optional human-authored investigation context

The collector must return structured evidence before any LLM invocation.

## Raw evidence files

- `raw/incident_model_matches.txt`
- `raw/incident_field_usage.txt`
- `raw/incident_relationship_usage.txt`
