# Sprint 8A Observability Evidence Baseline

## Sources of truth

Observability modules:

- `backend/app/observability/`
- `backend/app/reliability/`

Primary Prometheus client:

- `backend/app/reliability/prometheus_client.py`

Kubernetes runtime capture:

- `backend/app/deployments/kubernetes_capture.py`

Infrastructure configuration:

- `docker-compose.yml`
- `observability/prometheus/`
- `observability/loki/`
- `observability/grafana/`

## Service health snapshot evidence

`ServiceHealthSnapshot` stores:

- `service_id`
- `service_name`
- `environment`
- `status`
- `latency_ms`
- `error_rate`
- `cpu_usage`
- `memory_usage`
- `pod_restart_count`
- `replica_count`
- `available_replicas`
- `source`
- `created_at`

These stored snapshots provide deterministic runtime evidence independent of
future observability queries.

## Prometheus integration

A dedicated Prometheus client exists at:

- `backend/app/reliability/prometheus_client.py`

The client uses the Prometheus HTTP API:

- `/api/v1/query`

The Prometheus base URL and timeout are configurable through:

- `PROMETHEUS_URL`
- `PROMETHEUS_TIMEOUT_SECONDS`

The client validates query inputs and handles:

- HTTP failures
- connection failures
- request timeouts
- invalid JSON
- unsuccessful Prometheus responses
- empty result sets
- unsupported result formats
- non-numeric values
- NaN and infinite values

## Supported Prometheus evidence

The current client exposes deterministic retrieval for:

- availability
- error rate
- p95 latency

Relevant functions include:

- `get_availability`
- `get_error_rate`
- `get_p95_latency`
- `query_prometheus`

The current client performs instant queries rather than time-range queries.

No `query_range` implementation was identified during the baseline.

## SLO evidence

`SLODefinition` stores:

- `service_id`
- `metric_type`
- `target_value`
- `window_minutes`
- `severity_on_breach`
- `enabled`
- lifecycle timestamps

Supported metric types include:

- availability
- p95 latency
- error rate

## SLO measurement evidence

`SLOMeasurement` stores:

- `slo_definition_id`
- `service_id`
- `metric_type`
- `measured_value`
- `target_value`
- `is_breached`
- `window_minutes`
- `source`
- `evaluated_at`
- `created_at`

The default source is `PROMETHEUS`.

Stored SLO measurements should be preferred as reproducible incident evidence
when available.

## Error-budget evidence

`ErrorBudgetStatus` stores:

- `slo_definition_id`
- `service_id`
- `target_percentage`
- `allowed_failure_percentage`
- `consumed_percentage`
- `remaining_percentage`
- `burn_rate`
- `status`
- `window_minutes`
- `evaluated_at`
- `created_at`

Possible error-budget states include:

- `HEALTHY`
- `WARNING`
- `BREACHED`
- `EXHAUSTED`

This provides deterministic reliability context for RCA generation.

## Reliability alert evidence

`ReliabilityAlert` stores:

- `service_id`
- `slo_definition_id`
- `alert_type`
- `severity`
- `triggered_value`
- `threshold_value`
- `deployment_id`
- `status`
- `created_at`
- `resolved_at`

Supported alert categories include:

- SLO breach
- error-budget burn
- error-budget exhausted
- latency breach
- availability breach
- error-rate breach

Reliability alerts may be linked directly to deployments and incidents.

## Scheduled reliability evaluation

Existing reliability tasks evaluate enabled SLOs independently.

Failures affecting one SLO do not prevent evaluation of other SLOs.

The evaluation flow uses Prometheus measurements and persists:

- SLO measurements
- error-budget status
- reliability alerts

## Loki infrastructure

Docker Compose includes:

- Loki
- Promtail
- Grafana

Loki is exposed on port `3100`.

Promtail is present for log shipping.

However, no backend application client was identified for:

- Loki HTTP API
- LogQL
- log range queries
- incident-window log retrieval

Therefore, Loki is infrastructure-configured but not yet available to the RCA
collector through an application API.

## Trace evidence

No active application integration was identified for:

- Tempo
- Jaeger
- OpenTelemetry trace retrieval
- trace IDs
- span IDs
- failed-trace queries

Trace-related matches inside the Python virtual environment were third-party
package code and are not PlatformIQ integrations.

Failed traces are therefore currently unavailable as an RCA evidence source.

## Kubernetes runtime evidence

The Kubernetes capture module initializes:

- `AppsV1Api`
- `CoreV1Api`

It retrieves:

- namespaced Deployments
- namespaced Pods

Available runtime evidence includes:

- deployment state
- pod state
- desired replicas
- available replicas
- pod count
- restart count
- workload health
- workload failure reason

## Raw Kubernetes Event evidence

No use was identified for:

- `list_namespaced_event`
- `list_event_for_all_namespaces`
- Kubernetes `EventV1Api`

Therefore, raw Kubernetes Event objects such as:

- scheduling failures
- image pull failures
- probe failures
- eviction events
- volume mount failures

are not currently collected.

Kubernetes evidence is limited to deployment and pod state snapshots and
derived health transitions.

## Evidence availability classification

### Fully available

- stored service health snapshots
- Prometheus availability
- Prometheus error rate
- Prometheus p95 latency
- stored SLO measurements
- stored error-budget evaluations
- stored reliability alerts
- Kubernetes deployment state
- Kubernetes pod state
- replica availability
- restart counts

### Infrastructure available but no collector client

- Loki logs
- Promtail-shipped logs

### Not implemented

- Loki query client
- LogQL evidence retrieval
- Prometheus range queries
- Tempo or Jaeger client
- distributed trace retrieval
- failed-trace retrieval
- raw Kubernetes Event collection

## RCA collector implications

The first RCA collector version can safely include:

1. Stored service health snapshots.
2. Stored SLO measurements.
3. Error-budget status.
4. Linked reliability alerts.
5. Current Prometheus measurements.
6. Kubernetes workload state.
7. Deployment and pod restart evidence.

The collector must explicitly return missing-source information for:

- logs
- traces
- raw Kubernetes Events

It must not fabricate these sections or treat infrastructure configuration as
evidence retrieval capability.

## Raw evidence files

- `raw/observability_model_matches.txt`
- `raw/observability_file_inventory.txt`
- `raw/observability_client_usage.txt`
- `raw/service_health_evidence.txt`
- `raw/slo_error_budget_evidence.txt`
- `raw/reliability_alert_evidence.txt`
- `raw/log_trace_integrations.txt`
- `raw/prometheus_query_evidence.txt`
- `raw/observability_stack_services.txt`
- `raw/prometheus_client_implementation.txt`
- `raw/slo_evaluation_flow.txt`
- `raw/kubernetes_api_usage.txt`
