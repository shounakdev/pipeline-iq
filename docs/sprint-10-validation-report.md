# Sprint 10 Validation Report

## Scope and evidence level

This report covers the Sprint 10J deterministic validation implemented on the
`sprint-10` branch. The automated matrix uses SQLite/in-memory domain persistence
and `MockChaosAdapter`; it verifies orchestration contracts and repeatable
calculations without mutating Kubernetes. A real staging-cluster matrix remains
required before claiming infrastructure-level repeatability.

## Experiment configuration

- Environment: `staging`
- Namespace: `platformiq-staging`
- Service: `payment-service`
- Cleanup: mandatory `delete`
- Concurrency: one active run
- Scenarios: all five definitions in `experiment-scenarios.md`
- Repetitions: three per scenario, 15 total
- Automated timing fixtures per scenario:
  - Detection: 10 s, 11 s, 12 s
  - Incident: 30 s, 31 s, 32 s
  - Recovery: 120 s, 123 s, 126 s
  - Diagnosis: exact expected category

## Automated repeatability results

Verification executed in the repository-local Python environment: `77 passed`
for `pytest tests/chaos -q`. The focused Sprint 10J selection reported `55
passed`. No chaos test failed.

| Scenario | Runs | Detection | Incident | RCA correct | Recovery | Avg / max detect | Detect variance | Avg / max recovery | Recovery variance |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `FAULTY_RELEASE` | 3 | 100% | 100% | 100% | 100% | 11 s / 12 s | 0.667 s² | 123 s / 126 s | 6 s² |
| `POD_KILL` | 3 | 100% | 100% | 100% | 100% | 11 s / 12 s | 0.667 s² | 123 s / 126 s | 6 s² |
| `NETWORK_DELAY` | 3 | 100% | 100% | 100% | 100% | 11 s / 12 s | 0.667 s² | 123 s / 126 s | 6 s² |
| `DATABASE_DELAY` | 3 | 100% | 100% | 100% | 100% | 11 s / 12 s | 0.667 s² | 123 s / 126 s | 6 s² |
| `CPU_PRESSURE` | 3 | 100% | 100% | 100% | 100% | 11 s / 12 s | 0.667 s² | 123 s / 126 s | 6 s² |

The acceptance path also verifies that injection, anomaly, and alert occur in
order; incident, RCA, remediation, execution, and verification foreign keys point
to the same run; and benchmark anchors calculate to 10 s detection, 20 s alert,
30 s incident, 70 s diagnosis, 15 s approval, and 150 s recovery.

## Integration checklist

- Chaos injection is stored as `FAILURE_INJECTED` with provider identity.
- Pre-injection platform events are excluded; post-injection anomaly and alert
  evidence is retained.
- Incident, completed RCA, remediation recommendation/execution, and verified
  recovery link to the run.
- Benchmark values are derived from the earliest typed observations.
- Cleanup is asserted after normal completion, observer failure, adapter failure,
  timeout, and abort handling.
- Production execution is rejected before database or Kubernetes mutation.
- Every scenario materializes its own persisted configuration and resource kind.

## Failed or incomplete runs

None in the deterministic 15-run fixture. The repeatability aggregator treats a
missing benchmark as unsuccessful and lists all `FAILED` or `INCOMPLETE` run IDs.
Populate this section with real run IDs and causes during staging execution; do
not remove them from rate denominators.

## Known limitations

- Mock evidence does not validate Chaos Mesh controller behavior, Kubernetes
  scheduling, real telemetry lag, Kafka delivery, Celery reliability, or network
  clocks.
- The 15 automated runs intentionally use fixed timings, so their variance
  validates the calculation rather than characterizing staging noise.
- The production block is tested; production execution is neither required nor
  permitted.
- Network and database delay scenarios do not prescribe an automatic remediation;
  the normal human-approved remediation workflow must select a safe action.
- Staging run IDs, timestamps, cluster version, Chaos Mesh version, and raw logs
  must be appended after the live matrix.
- The broader backend suite reported `219 passed` and `141` setup errors because
  its configured PostgreSQL host `postgres` was unavailable outside Docker. The
  errors occurred during database fixture setup, not in Sprint 10J assertions.

## Reproduction commands

```bash
cd backend
TESTING=1 pytest tests/chaos/test_correlation_service.py \
  tests/chaos/test_experiment_orchestration.py \
  tests/chaos/test_chaos_execution_safety.py \
  tests/chaos/test_benchmark_service.py \
  tests/chaos/test_repeatability_service.py -q
```
