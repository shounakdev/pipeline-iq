# Sprint 10 — Carried-Forward Work

## Status

Sprint 10 implementation and automated testing are complete. Live repeatability validation, full artifact correlation, reporting, and the final demonstration remain incomplete and are carried forward while Sprint 11 begins.

```text
Implementation: Complete
Automated testing: Complete — 80 tests passing
Live core-path validation: Partially complete
Repeatability validation: Pending
Final demo: Pending
Overall sign-off: Conditional / carried forward
```

## Completed work

- Chaos Mesh installed and verified in Kubernetes.
- Staging-only injection boundary configured.
- Development and production execution blocked by the restricted chaos identity.
- Chaos experiment, run, observation, and benchmark models implemented.
- Experiment APIs implemented.
- Experiment list and detail pages implemented.
- Five experiment scenario implementations created.
- Automated chaos integration suite passing with **80 tests**.
- One successful live staging `POD_KILL` core-path run completed.
- The successful live run demonstrated:
  - Chaos event injection.
  - Telemetry anomaly detection.
  - Alert creation and correlation.
  - Incident creation and correlation.
  - Workload recovery.
  - Detection, alert, incident, and recovery timing.
  - Chaos resource cleanup.
- Environment restored to `CHAOS_ADAPTER=mock` after live testing.

## Remaining engineering work

### 1. Support post-run artifact correlation

Update:

```text
backend/app/chaos/services/correlation_service.py
```

RCA, remediation, approval, execution, and recovery-verification events may occur after the configured fault duration. These events must still attach to the correct completed experiment when they reference an incident already linked to that experiment.

Required behaviour:

- Resolve a run directly through its linked `incident_id`.
- Allow trusted incident-linked artifacts to be recorded after the original observation window.
- Continue rejecting unrelated late events that do not reference the linked incident.
- Recalculate the experiment benchmark when late artifacts are attached.
- Preserve event ordering and experiment-run linkage.

### 2. Add regression tests for late artifacts

Add automated tests covering:

- Post-deadline RCA linked through the experiment's incident.
- Post-deadline remediation recommendation linked through the incident.
- Approval and remediation execution linkage.
- Recovery-verification linkage.
- Benchmark recalculation after late artifacts arrive.
- Rejection of an unrelated post-deadline alert.

Run these tests while the safe mock adapter is active:

```bash
cd backend
source ../.venv/bin/activate
python -m pytest tests/chaos -q
```

### 3. Verify the complete artifact chain

After the correlation fix passes automated testing, validate this sequence in staging:

```text
Failure injected
→ Telemetry anomaly detected
→ Alert created
→ Incident created
→ RCA generated
→ Remediation recommended
→ Remediation approved and executed
→ Recovery verified
→ Benchmark recalculated
```

The experiment detail page must show links to the incident, RCA report, remediation result, and recovery-verification result.

## Remaining live repeatability validation

Each scenario requires at least three **successful** live staging executions:

| Scenario | Required | Successfully validated | Remaining |
| --- | ---: | ---: | ---: |
| `FAULTY_RELEASE` | 3 | 0 | 3 |
| `POD_KILL` | 3 | 1 | 2 |
| `NETWORK_DELAY` | 3 | 0 | 3 |
| `DATABASE_DELAY` | 3 | 0 | 3 |
| `CPU_PRESSURE` | 3 | 0 | 3 |
| **Total** | **15** | **1** | **14** |

Failed or incomplete attempts must be recorded in the validation report, but they do not count toward the three successful executions required for each scenario.

For every live run, capture:

- Experiment and run identifiers.
- Scenario configuration.
- Injection timestamp.
- First anomaly timestamp.
- Alert timestamp.
- Incident timestamp.
- RCA completion timestamp.
- Remediation approval timestamp.
- Recovery completion timestamp.
- Detection success.
- Incident creation success.
- Diagnosis correctness.
- Recovery success.
- Detection time.
- Recovery time.
- Cleanup result.
- Failure or incomplete-run reason, when applicable.

## Remaining analysis

After all live executions, calculate and compare:

- Detection success rate.
- Incident creation success rate.
- RCA correctness rate.
- Recovery success rate.
- Average detection time.
- Maximum detection time.
- Detection-time variance.
- Average recovery time.
- Maximum recovery time.
- Recovery-time variance.

## Validation report update

Update:

```text
docs/chaos-engineering/sprint-10-validation-report.md
```

The final report must include:

- Experiment configurations.
- Number of executions per scenario.
- Successful, failed, and incomplete runs.
- Detection success percentage.
- Incident creation success percentage.
- Diagnosis accuracy.
- Recovery success percentage.
- Average and maximum response times.
- Variance between runs.
- Cleanup verification.
- Production-blocking verification.
- Known limitations.
- Links or references to captured demo evidence.

## Final Sprint 10 demo

The required final demonstration remains pending:

```text
Start faulty-release experiment
→ Deploy a bad payment-service image or configuration
→ Detect service degradation
→ Create and link an incident
→ Generate and link RCA
→ Approve and execute rollback
→ Verify service recovery
→ Record detection and recovery times
→ Remove all chaos resources
```

## Safety procedure for future live runs

Do not reconnect to live execution until the correlation changes pass the automated test suite.

Prepare staging immediately before a controlled validation session:

```bash
bash scripts/prepare-sprint10j-staging.sh
```

After every live session, restore the safe environment:

```bash
bash scripts/restore-sprint10j-environment.sh
```

Verify the restored state:

```bash
grep '^CHAOS_ADAPTER=' .env

kubectl -n platformiq-staging get \
  podchaos,networkchaos,stresschaos,httpchaos
```

Expected result:

```text
CHAOS_ADAPTER=mock
No resources found in platformiq-staging namespace.
```

## Sprint 11 transition decision

Sprint 11 may begin while this work is carried forward, provided:

- Sprint 10 is not reported as fully signed off.
- The remaining items stay visible in the project backlog.
- Sprint 11 does not rely on unverified RCA or benchmark results as trusted production evidence.
- The carried-forward work is completed before final project acceptance.

