# PlatformIQ Chaos Mesh setup

This package installs Chaos Mesh 2.8.3 and gives PlatformIQ a deliberately
small, namespaced permission set for `PodChaos`, `NetworkChaos`, `StressChaos`,
`HTTPChaos`, and `Workflow` resources.

## Safety model

Kubernetes enforces the hard cluster boundary:

- The installer grants a Role only in the single environment selected by
  `CHAOS_TARGET_ENVIRONMENT`; it removes the corresponding RoleBinding and
  injection annotation from the other environment.
- Chaos Mesh `FilterNamespace` is enabled. Only the selected namespace accepts
  fault injection.
- The account may create, inspect, and delete the five approved resource types.
  It cannot update/patch experiments or access Pods, Secrets, Deployments, or
  other Kubernetes resources.
- The dashboard is authenticated and cluster-internal.

PlatformIQ must enforce request/business invariants before calling Kubernetes;
plain RBAC cannot inspect a Chaos custom resource body or coordinate concurrent
requests. The application must reject a request unless all of these are true:

1. `CHAOS_ENGINE_ENABLED` is true.
2. Environment and namespace are members of their configured allowlists, and
   the requested environment matches the namespace's configured environment.
3. The target service is in PlatformIQ's service allowlist. Generate selectors
   server-side from its immutable `app.kubernetes.io/name` label; never accept a
   raw selector from the caller.
4. Duration is present, positive, and no greater than
   `CHAOS_MAX_DURATION_SECONDS`. Write the same value to `spec.duration`.
5. Cleanup behavior is explicit. On normal completion, timeout, cancellation,
   and process recovery, delete the Chaos resource and wait for recovery.
6. Database partial unique indexes permit at most one active run for
   `(environment, service)` and, while `CHAOS_MAX_CONCURRENT_RUNS=1`, at most
   one active run globally.
7. The authenticated operator ID is stored in the audit record and in the
   resource annotation `platformiq.io/operator` (never trust a client-supplied
   operator value).
8. A persisted deadline is set at `started_at + duration`. A watchdog deletes
   overdue resources, marks the run `aborted`, and records the cleanup result.

A follow-up Alembic migration denormalizes the target onto `chaos_runs` and
creates the PostgreSQL safety indexes. This is necessary because PostgreSQL
indexes cannot enforce a uniqueness rule through a join to
`chaos_experiments`.

```sql
CREATE UNIQUE INDEX one_active_chaos_run_per_target
ON chaos_runs (target_environment, target_service_id)
WHERE status IN ('PENDING', 'RUNNING', 'FAULT_INJECTED',
                 'OBSERVING', 'RECOVERING');
```

Creating the database row and claiming the uniqueness constraint must happen
before the Kubernetes create call. If Kubernetes creation fails, mark the row
failed. On restart, reconcile all active rows against Kubernetes so deadlines
cannot be bypassed by a PlatformIQ process restart.

## Install

Prerequisites: Kubernetes, Helm 3, `kubectl`, cluster-admin installation rights,
and the namespace for the selected non-production environment.

First label the cluster after manually confirming its identity. This is a
one-time guard against installing into the wrong context:

```bash
kubectl --context <dev-context> label namespace kube-system \
  platformiq.io/environment=development
```

Then run:

```bash
export KUBE_CONTEXT=<dev-context>
export CHAOS_TARGET_ENVIRONMENT=development
./k8s/chaos-mesh/installation/install.sh
```

The service account disables automatic token mounting. For an in-cluster
PlatformIQ workload, create an equivalent account in the application's
namespace, update both RoleBindings, and mount an explicit projected
`serviceAccountToken` volume with a short expiry. For an external PlatformIQ
process, use a short-lived TokenRequest token through your secret
manager/identity broker and rotate it automatically. Do not create a legacy
long-lived service-account token Secret.

## Verify and access the dashboard

Run all controller, dashboard, CRD, connectivity, and positive/negative RBAC
checks again with:

```bash
KUBE_CONTEXT=<dev-context> ./k8s/chaos-mesh/installation/verify.sh
```

Use a local authenticated tunnel for the dashboard:

```bash
kubectl --context <dev-context> -n chaos-mesh \
  port-forward service/chaos-dashboard 2333:2333
```

## Required PlatformIQ tests

Add these at the service boundary using a fake Kubernetes client, plus one
cluster integration test using the real service account:

| Test | Expected result |
|---|---|
| environment=`production` | rejected before Kubernetes call |
| namespace outside configured allowlist | rejected before Kubernetes call |
| missing/zero/over-limit duration | rejected before Kubernetes call |
| second active run for same environment/service | database conflict; no Kubernetes call |
| allowed request | approved CR created with duration and operator annotation |
| deadline exceeded | CR deleted, recovery awaited, run marked aborted |
| connectivity | list approved CR type succeeds; list Pods fails |

The included `verify.sh` supplies the live connectivity and namespace-isolation
tests. It obtains a ten-minute TokenRequest credential and confirms the
restricted identity cannot list Pods. Backend tests cover validation,
server-generated selectors, migration safety indexes, and duplicate-run
rejection.

## Development test target

Deploy the disposable two-replica target only after the development namespace
is selected:

```bash
kubectl --context "$KUBE_CONTEXT" apply -f k8s/chaos-mesh/chaos-test-service.yaml
kubectl --context "$KUBE_CONTEXT" -n platformiq-dev rollout status \
  deployment/chaos-test-service
```

Create one enabled `POD_KILL` `ChaosExperiment` record for the PlatformIQ
service named `chaos-test-service`. The execution endpoint is
`POST /api/chaos/runs`; callers provide only environment, namespace, service,
duration, and cleanup behavior. PlatformIQ generates the Kubernetes selector,
operator annotation, deadline, and resource name server-side.
