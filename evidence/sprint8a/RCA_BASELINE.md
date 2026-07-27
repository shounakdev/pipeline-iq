# Sprint 8A RCA Baseline

## Objective

Establish the existing evidence, security, observability and asynchronous
execution contracts required to build an evidence-grounded root-cause analysis
engine.

Sprint 8A does not add:

- RCA database models
- Alembic migrations
- API routes
- Celery RCA tasks
- external model invocation
- production evidence collectors

It introduces only a compile-safe RCA package contract and documents the
existing system baseline.

## Critical architecture rule

The RCA model must never receive only an incident description such as:

> Payment service failed. What caused it?

The model must receive structured evidence collected by deterministic
application logic.

## Existing incident evidence

Available incident evidence includes:

- incident identity
- affected service
- environment
- severity
- lifecycle status
- lifecycle timestamps
- triggering alert
- linked alerts
- suspected deployment
- timeline events
- stored incident metrics
- assignments
- comments

System evidence and human-authored context must remain separately classified.

See:

- `02_incident_data_baseline.md`

## Existing deployment and pipeline evidence

Available deployment evidence includes:

- service and environment links
- pipeline-run link
- commit SHA
- image tag
- deployment version
- Argo sync status
- Kubernetes rollout status
- namespace and cluster
- pod count
- restart count
- failure reason
- deployment timestamps
- workload state
- revision history

Available pipeline evidence includes:

- pipeline status and stage
- failure reason
- commit information
- build and test status
- SonarQube status and findings
- Trivy status and findings
- coverage
- quality gate
- risk information
- logs
- execution timestamps

The primary correlation path is:

`Incident.suspected_deployment_id`
→ `Deployment.id`
→ `Deployment.pipeline_run_id`
→ `PipelineRun.id`

See:

- `03_deployment_pipeline_baseline.md`

## Existing observability evidence

Fully available evidence includes:

- stored service health snapshots
- Prometheus availability
- Prometheus error rate
- Prometheus p95 latency
- stored SLO measurements
- stored error-budget evaluations
- reliability alerts
- Kubernetes deployment state
- Kubernetes pod state
- replica availability
- restart counts

Infrastructure exists for Loki and Promtail, but no backend Loki query client
currently exists.

No failed-trace retrieval or raw Kubernetes Event collection currently exists.

See:

- `04_observability_baseline.md`

## Existing asynchronous execution contract

Celery currently uses Redis as the broker and disables result storage.

Existing patterns include:

- explicit database task state
- task retry
- stale-task recovery
- transactional outbox
- Kafka consumer dead-letter handling
- per-source isolation in reliability evaluation

No dedicated RCA queue, task or schedule currently exists.

No explicit late acknowledgement, worker-loss rejection, prefetch, hard task
limit, soft task limit or visibility timeout was identified.

See:

- `05_async_failure_feature_flags_baseline.md`

## Existing security contract

The backend uses:

- OAuth2 bearer tokens
- JWT access tokens
- bcrypt password hashing
- role-based authorization
- audit events
- limited log-secret sanitization

Important gaps include:

- development JWT fallback secret
- privileged role self-selection during registration
- first-role-only authorization evaluation
- inconsistent route protection
- incomplete secret and personal-data sanitization
- no evidence or report retention policy

Every future RCA route must use explicit authorization.

Evidence must be sanitized before external model invocation.

See:

- `06_security_retention_baseline.md`

## Compile-only RCA package

Sprint 8A introduces:

- `backend/app/rca/enums.py`
- `backend/app/rca/contracts.py`
- `backend/app/rca/collectors.py`
- `backend/app/rca/provider.py`
- `backend/app/rca/config.py`
- `backend/app/rca/service.py`

The package defines:

- evidence source classifications
- evidence availability statuses
- RCA job states
- evidence-bundle contracts
- report-output contracts
- collector interfaces
- provider interfaces
- disabled-by-default feature flags

The package intentionally contains no routes, migrations, database models or
provider API calls.

## Initial evidence bundle contract

The initial structured evidence bundle contains:

- incident identity
- evidence time window
- triggering alert
- linked alerts
- deployment
- workloads
- revisions
- deployment events
- pipeline run
- pipeline findings
- pipeline logs
- health snapshots
- Prometheus values
- SLO measurements
- error-budget statuses
- Kubernetes evidence
- logs
- failed traces
- incident timeline
- incident metric snapshots
- per-source availability statuses
- separately classified human context

Missing evidence sources must be represented explicitly rather than omitted or
fabricated.

## Evidence trust hierarchy

### Primary deterministic evidence

- database identifiers
- foreign-key relationships
- stored timestamps
- pipeline statuses
- deployment statuses
- SonarQube findings
- Trivy findings
- Kubernetes workload state
- Prometheus values
- SLO measurements
- error-budget evaluations
- reliability alerts
- event records

### Derived deterministic evidence

- incident-to-deployment time correlation
- calculated durations
- risk scores generated by deterministic code
- restart deltas
- replica-availability differences

### Human-authored context

- comments
- assignment notes
- investigation notes

### Prior AI-generated context

- existing pipeline AI summaries
- existing recommendations
- legacy analysis suggestions and confidence

Prior AI-generated context must never be treated as verified ground truth.

## Feature flags

The RCA package defines disabled-by-default controls:

- `RCA_ENABLED`
- `RCA_LLM_ENABLED`
- `RCA_LOG_COLLECTION_ENABLED`
- `RCA_TRACE_COLLECTION_ENABLED`
- `RCA_KUBERNETES_EVENTS_ENABLED`

Defining these configuration values does not enable routes or provider calls.

## Sprint 8A completion criteria

Sprint 8A is complete when:

- repository baseline is documented
- incident evidence is documented
- deployment and pipeline evidence is documented
- observability evidence is documented
- async and failure handling are documented
- security and retention are documented
- compile-only RCA contracts exist
- RCA package compiles
- no migration exists
- no RCA route exists
- no model provider is called
- all RCA flags default to disabled
