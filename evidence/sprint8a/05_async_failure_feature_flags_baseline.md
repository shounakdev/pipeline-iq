# Sprint 8A Async Execution, Failure Handling and Feature-Flag Baseline

## Sources of truth

Primary Celery configuration:

- `backend/app/celery_app.py`

Task implementations:

- `backend/app/tasks.py`
- `backend/app/reliability/tasks.py`

Event failure infrastructure:

- `backend/app/events/outbox.py`
- `backend/app/events/outbox_publisher.py`
- `backend/app/events/consumer.py`
- `backend/app/events/service.py`

Runtime configuration:

- environment variables read by `backend/app`
- `docker-compose.yml`

## Celery broker

The Celery broker URL is resolved in this order:

1. `CELERY_BROKER_URL`
2. `REDIS_URL`
3. `redis://<REDIS_HOST>:<REDIS_PORT>/0`

Default Redis values are:

- host: `localhost`
- port: `6379`
- database: `0`

Redis TLS configuration is applied when the URL starts with `rediss://`.

The current TLS configuration disables certificate verification by using
`ssl.CERT_NONE`.

## Celery result handling

Celery results are disabled through:

- application backend: `disabled://`
- `task_ignore_result=True`
- `result_backend="disabled://"`

Therefore, persistent RCA job state should not rely on Celery's result backend.

Any future RCA task must persist its status and output in the application
database.

## Included task modules

Celery currently includes:

- `app.tasks`
- `app.reliability.tasks`

A future RCA task module would need to be added explicitly to Celery discovery
unless it is imported through an existing included module.

## Task queue

Existing tasks are routed to:

- `pipeline_queue`

Current routed tasks include:

- pipeline execution
- transactional outbox publishing
- Kafka event consumption
- SLO evaluation

No dedicated RCA queue exists.

The initial RCA implementation may use the existing queue, but a dedicated queue
should be considered if model calls or evidence collection could block pipeline
and reliability tasks.

## Celery Beat schedules

Existing schedules are:

- publish outbox events every 10 seconds
- consume Kafka events every 10 seconds
- evaluate all SLOs every 60 seconds

RCA generation is not currently scheduled.

RCA should normally be event-triggered or explicitly requested rather than run
for every incident on a periodic scan.

## Pipeline task retry behavior

The pipeline execution task is bound to the Celery task instance and defines:

- `max_retries=2`
- retry countdown of 30 seconds

Before retrying, the implementation records intermediate failure information.

After retry exhaustion, it records terminal pipeline failure and emits the
pipeline failure event.

## Stale task recovery

The current code includes stale-running-pipeline handling.

A running pipeline may be marked failed when it exceeds a timeout window or when
a worker appears to have stopped unexpectedly.

This establishes an existing pattern for recovering database state when a task
does not complete normally.

A future RCA job should have an equivalent stale-job or timeout policy.

## Database failure handling

Existing task and service patterns use:

- `try` and `except`
- `db.rollback()` on database failures
- explicit terminal status updates
- persisted `failure_reason`
- best-effort secondary failure handling

Future RCA tasks should use one database transaction for each state transition
and rollback before writing a clean failure state in a new transaction.

## Transactional outbox

Existing event publishing uses a transactional outbox.

Outbox records contain:

- publication status
- retry count
- last error
- publication timestamp

The publisher retries failed events and eventually marks terminal failures.

RCA completion events should use this existing outbox pattern rather than
publishing directly before the database transaction commits.

## Dead-letter handling

Kafka consumer failures can be persisted as `DeadLetterEvent` records and
published to a dead-letter topic.

Dead-letter records support:

- failure storage
- status tracking
- manual retry
- failed-retry persistence

This pattern is relevant to event-driven RCA triggering.

An invalid RCA-trigger event should be dead-lettered rather than silently
discarded.

## Reliability task isolation

The SLO evaluation task processes SLOs independently.

A failure while evaluating one SLO does not prevent the remaining SLOs from
being evaluated.

The future RCA evidence collector should apply similar source isolation:

- failure to query logs should not discard metrics
- failure to query traces should not discard deployment evidence
- each missing source should be recorded explicitly
- the final job should fail only when minimum required evidence is unavailable

## Celery reliability settings

The baseline must verify whether the following are configured:

- late acknowledgement
- reject on worker loss
- worker prefetch multiplier
- task hard time limit
- task soft time limit
- broker visibility timeout

If `raw/celery_delivery_settings.txt` is empty, these settings are not currently
configured in the inspected application and Docker Compose files.

## Existing feature flags

No dedicated application feature-flag service or framework was identified.

Matches such as:

- `NEXT_TELEMETRY_DISABLED`
- `DYNAMIC_CONFIG_ENABLED`

are infrastructure or framework configuration and do not establish a
PlatformIQ product feature-flag contract.

## RCA feature-flag requirement

Before enabling RCA routes or model invocation, Sprint 8 should introduce an
environment-driven flag such as:

- `RCA_ENABLED`

Potential supporting flags include:

- `RCA_LLM_ENABLED`
- `RCA_LOG_COLLECTION_ENABLED`
- `RCA_TRACE_COLLECTION_ENABLED`
- `RCA_KUBERNETES_EVENTS_ENABLED`

The baseline phase must document these as proposed controls only.

No new flag should be treated as implemented until code and tests exist.

## RCA task-state implications

Because the Celery result backend is disabled, future RCA persistence should
support application-managed states such as:

- `PENDING`
- `COLLECTING_EVIDENCE`
- `EVIDENCE_READY`
- `GENERATING`
- `COMPLETED`
- `FAILED`

The database should retain:

- attempt count
- task identifier if available
- started timestamp
- completed timestamp
- failure code
- sanitized failure message

These are future contract implications, not existing implementation.

## Security observations

The Redis TLS configuration currently uses `ssl.CERT_NONE`.

This may be acceptable for isolated local development but should be recorded as
a production security gap.

Task failure records must not persist:

- secrets
- access tokens
- authorization headers
- full provider credentials
- unsanitized model prompts containing sensitive logs

## Raw evidence files

- `raw/celery_configuration.txt`
- `raw/celery_task_usage.txt`
- `raw/task_file_inventory.txt`
- `raw/task_implementations.txt`
- `raw/task_failure_handling.txt`
- `raw/runtime_configuration_usage.txt`
- `raw/feature_flag_usage.txt`
- `raw/event_failure_patterns.txt`
- `raw/pipeline_task_retry_implementation.txt`
- `raw/celery_delivery_settings.txt`
- `raw/celery_docker_configuration.txt`
