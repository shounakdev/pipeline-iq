# Sprint 8A Deployment and Pipeline Evidence Baseline

## Sources of truth

Primary model file:

- `backend/app/models.py`

Deployment implementation:

- `backend/app/deployments/router.py`
- `backend/app/deployments/schemas.py`
- `backend/app/deployments/kubernetes_capture.py`

Incident deployment correlation:

- `backend/app/incidents/repository.py`
- `backend/app/incidents/service.py`
- `backend/app/incidents/config.py`

Pipeline execution sources:

- `backend/app/executor.py`
- `backend/app/pipeline_runner.py`
- `backend/app/tasks.py`
- `backend/app/pipelineiq/`
- `backend/app/sonar_service.py`

Event timeline sources:

- `backend/app/events/constants.py`
- `backend/app/events/service.py`
- `backend/app/events/handlers.py`

## Deployment model

The `Deployment` model contains:

- `id`
- `service_id`
- `pipeline_run_id`
- `environment_id`
- `commit_sha`
- `image_tag`
- `deployment_version`
- `argo_sync_status`
- `kubernetes_rollout_status`
- `previous_revision`
- `namespace`
- `cluster_name`
- `service_name`
- `argo_application_name`
- `pod_count`
- `restart_count`
- `failure_reason`
- `created_at`
- `deployed_at`

This model provides the deterministic link between a deployed release, its
service, its environment and the pipeline run that produced it.

## Deployment-to-pipeline correlation

The primary deterministic relationship is:

`Incident.suspected_deployment_id`
→ `Deployment.id`
→ `Deployment.pipeline_run_id`
→ `PipelineRun.id`

Additional supporting correlation fields include:

- `Deployment.commit_sha`
- `PipelineRun.commit_sha`
- `Deployment.image_tag`
- deployment and pipeline timestamps
- service identity
- environment identity
- event `correlation_id`

The RCA collector should use the foreign-key relationship first.

Commit SHA and event correlation should be supporting evidence rather than the
primary join when `pipeline_run_id` exists.

## Kubernetes workload evidence

A deployment has one or more `KubernetesWorkload` records.

Available fields include:

- `workload_name`
- `namespace`
- `kind`
- `desired_replicas`
- `available_replicas`
- `pod_count`
- `restart_count`
- `status`
- `failure_reason`
- `created_at`

This evidence can explain whether a release failed because workloads did not
become available, pods restarted, or Kubernetes reported an unhealthy state.

## Deployment revision evidence

`DeploymentRevision` contains:

- `revision`
- `image_tag`
- `commit_sha`
- `status`
- `created_at`
- `deployed_at`

The deployment also contains `previous_revision`.

Together, these fields can provide release-change and rollback context.

No dedicated `rollback_of_deployment_id` field was identified during this
baseline investigation.

## Deployment event evidence

Existing event types include:

- `DEPLOYMENT_STARTED`
- `DEPLOYMENT_COMPLETED`
- `DEPLOYMENT_FAILED`
- `KUBERNETES_DEPLOYMENT_HEALTHY`
- `KUBERNETES_DEPLOYMENT_UNHEALTHY`

Deployment events include evidence such as:

- `deployment_id`
- `pipeline_run_id`
- `image_tag`
- service identity
- environment
- event timestamp
- correlation ID

When available, deployment events use `pipeline_run_id` as the release
correlation ID.

## Incident deployment correlation

The incident system already performs deterministic suspected-deployment
correlation using a configured time window.

Existing incident timeline evidence includes:

- `DEPLOYMENT_RELEASED`
- `DEPLOYMENT_CORRELATED`

The correlation records:

- deployment ID
- deployment version
- image tag
- release timestamp
- configured correlation window

The RCA layer should consume this stored correlation and supporting evidence.
It should not ask the LLM to independently infer a deployment solely from the
incident description.

## Pipeline model distinction

The repository contains two pipeline representations:

### Legacy `Pipeline`

The legacy `Pipeline` model contains:

- repository URL and branch
- commit information
- pipeline and stage status
- build, test, SonarQube and Trivy status
- logs through `PipelineLog`
- analysis through `Analysis`
- quality and security findings
- risk findings
- AI-generated summary and recommendations

### Service-scoped `PipelineRun`

`PipelineRun` is linked to:

- `Service`
- `Repository`
- `Deployment`

It contains:

- `id`
- `service_id`
- `repo_id`
- `repo_url`
- `branch`
- `status`
- `stage`
- `failure_reason`
- `commit_sha`
- `commit_message`
- `build_status`
- `test_status`
- `sonar_status`
- `trivy_status`
- `coverage`
- `bugs`
- `vulnerabilities`
- `code_smells`
- `duplicated_lines_density`
- `quality_gate`
- `sonar_report_url`
- `sonar_issues`
- Trivy severity counts
- `trivy_report`
- `risk_score`
- `risk_level`
- `risk_summary`
- `ai_summary`
- `recommendations`
- `logs`
- `created_at`
- `started_at`
- `finished_at`
- `duration_seconds`

For RCA collection, `PipelineRun` should be the primary source whenever the
deployment has a `pipeline_run_id`.

The legacy `Pipeline` model should only be queried when compatibility with
older pipeline executions is explicitly required.

## Deterministic pipeline evidence

The RCA collector can include:

- overall pipeline status
- failed stage
- failure reason
- build result
- test result
- SonarQube result
- Trivy result
- coverage
- quality gate
- bug count
- vulnerability count
- code-smell count
- Trivy severity counts
- Sonar issues
- Trivy report
- release risk score
- release risk level
- release risk summary
- raw pipeline logs
- pipeline start and finish times

Existing AI-generated pipeline fields such as `ai_summary`,
`recommendations`, and legacy `Analysis` output must not be treated as primary
system evidence.

They may be included only as clearly labelled prior AI analysis.

## Evidence trust classification

### Deterministic evidence

- database identifiers
- foreign-key relationships
- commit SHA
- deployment image and version
- timestamps
- stage statuses
- SonarQube findings
- Trivy findings
- Kubernetes workload state
- failure reasons emitted by pipeline or deployment logic
- stored event records

### Derived deterministic evidence

- incident-to-deployment time-window correlation
- release risk score generated by deterministic application logic
- calculated duration
- replica availability differences
- restart deltas

### Prior AI-generated context

- `Pipeline.ai_summary`
- `Pipeline.recommendations`
- `PipelineRun.ai_summary`
- `PipelineRun.recommendations`
- legacy `Analysis.failure_reason`
- legacy `Analysis.suggestion`
- legacy `Analysis.confidence`

Prior AI-generated context must not be presented to the RCA model as verified
ground truth.

## Initial RCA collector path

The expected collection path is:

1. Load incident.
2. Load stored suspected deployment.
3. Load deployment workloads and revisions.
4. Load deployment and Kubernetes events.
5. Follow `deployment.pipeline_run_id`.
6. Load the matching `PipelineRun`.
7. Extract deterministic pipeline findings and logs.
8. Label any existing AI-generated pipeline fields separately.
9. Record missing evidence without inventing values.
10. Return structured JSON before invoking an RCA model.

## Missing or unclear items

The baseline did not identify:

- a dedicated deployment repository module
- a dedicated `rollback_of_deployment_id`
- dedicated deployment log or deployment metric tables
- a dedicated `PipelineFinding` model
- a dedicated `PipelineStage` model

Equivalent evidence currently appears to be stored in:

- `PipelineRun` columns
- `PipelineRun.logs`
- SonarQube JSON
- Trivy JSON
- deployment event records
- Kubernetes workload records

## Raw evidence files

- `raw/deployment_model_matches.txt`
- `raw/deployment_field_usage.txt`
- `raw/deployment_repository_usage.txt`
- `raw/kubernetes_deployment_evidence.txt`
- `raw/pipeline_model_matches.txt`
- `raw/pipeline_field_usage.txt`
- `raw/pipeline_execution_evidence.txt`
- `raw/deployment_pipeline_links.txt`
