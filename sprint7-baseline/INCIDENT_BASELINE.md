# Sprint 7 Incident Baseline

## Existing Incident Model

- File: `backend/app/models.py`
- Table: `incidents`
- Primary key: UUID
- Existing fields:
  - id
  - title
  - description
  - severity
  - status
  - service_id
  - environment
  - correlation_id
  - triggered_by_event_id
  - started_at
  - resolved_at
  - created_at
  - updated_at
- Existing relationships:
  - `Incident.events` to `IncidentEvent`
- Existing indexes:
  - severity
  - status
  - service_id
  - environment
  - correlation_id
  - triggered_by_event_id
- Existing status values:
  - OPEN
  - ACKNOWLEDGED
  - RESOLVED
  - FALSE_POSITIVE
- Existing severity values:
  - LOW
  - MEDIUM
  - HIGH
  - CRITICAL

## Existing Incident Router

- Active file: `backend/app/incidents/incident_router.py`
- Legacy/unregistered file: `backend/app/incidents/router.py`
- Router prefix: Confirmed from active router source
- Registered in: `backend/app/main.py`
- Existing endpoints:
  - GET `/api/incidents`
  - GET `/api/incidents/{incident_id}`
  - GET `/api/incidents/{incident_id}/timeline`
  - POST `/api/incidents/{incident_id}/acknowledge`
  - POST `/api/incidents/{incident_id}/resolve`

## Existing Incident Creation Flow

- Trigger: Consumed `telemetry.alerts` Kafka event
- Handler: `handle_telemetry_alert`
- Function: `create_or_update_incident_from_alert`
- Files:
  - `backend/app/events/handlers.py`
  - `backend/app/incidents/incident_service.py`
- Processing: Asynchronous through Kafka and the scheduled Celery consumer
- Existing deduplication:
  - Event-envelope idempotency
  - Active incident lookup using correlation ID
  - Additional matching alerts create `INCIDENT_ALERT_ATTACHED`
- Existing audit logging:
  - Incident lifecycle entries are stored in `incident_events`
  - Incident Kafka publication is currently only logged and is not using the outbox

## Reliability Alert Integration

- Alert model: `ReliabilityAlert`
- Alert creation function: `create_reliability_alert_and_event`
- Event emitted:
  - Reliability alert type such as `SLO_BREACH`
  - `ERROR_BUDGET_EXHAUSTED`
- Topic: `telemetry.alerts`
- Outbox used: Yes
- Transactional behaviour:
  - Measurement, error budget, reliability alert and outbox event are committed together

## Deployment Correlation

- Existing function: `_find_latest_deployment`
- File: `backend/app/reliability/alert_service.py`
- Existing window:
  - Deployment belongs to the same service
  - Deployment creation time is not later than the alert occurrence time
- Stored field:
  - `ReliabilityAlert.deployment_id`
- Event payload:
  - `deployment_id` is included in the reliability alert payload
- Incident limitation:
  - The current Incident model has no direct deployment ID field

## Existing Frontend

- List page: See `sprint7-baseline/frontend-incident-list-page.txt`
- Detail page: See `sprint7-baseline/frontend-incident-detail-page.txt`
- API usage: See `sprint7-baseline/frontend-incident-api-usage.txt`
- Expected fields: See `sprint7-baseline/frontend-incident-fields.txt`
- Existing actions: Acknowledge and resolve
- Compatibility requirement:
  - Preserve the existing `id` field
  - Preserve existing endpoint paths
  - Preserve fields required by the Sprint 5 pages

## Existing Tests

- Incident tests: See `sprint7-baseline/incident-tests.txt`
- Indirect tests: See `sprint7-baseline/indirect-incident-tests.txt`
- Targeted test result: See `sprint7-baseline/incident-test-results.txt`
- Full suite result: See `sprint7-baseline/full-test-results.txt`
- Baseline exit codes:
  - See `incident-test-exit-code.txt`
  - See `full-test-exit-code.txt`

## Database Baseline

- Table definition: See `sprint7-baseline/incidents-database-inspection.txt`
- Existing incident counts: Recorded by status and severity
- Existing enum values: Recorded from PostgreSQL
- Recent sample rows: Recorded without modification

## Migration Risks

- Existing data requiring conversion:
  - OPEN may need conversion or compatibility mapping to DETECTED
  - Existing LOW, MEDIUM, HIGH and CRITICAL values require mapping to SEV-1, SEV-2 and SEV-3
- Frontend compatibility concerns:
  - Existing pages depend on `/api/incidents`
  - Existing pages may depend on `id`, status and severity values
- Foreign-key concerns:
  - `service_id` is currently a String rather than a Service foreign key
  - Incident does not directly reference ReliabilityAlert
  - Incident does not directly reference Deployment
- Enum conversion concerns:
  - PostgreSQL enum alteration requires a deliberate Alembic migration
  - Existing rows must remain valid during deployment
- Code duplication:
  - `router.py` and `incident_router.py` both contain routes
  - `handle_telemetry_alert_event` is stale and references missing model fields
