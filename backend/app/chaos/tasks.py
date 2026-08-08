from app.celery_app import celery_app
from app.chaos.reconciliation import reconcile_expired_runs_once


@celery_app.task(name="app.chaos.tasks.reconcile_expired_runs")
def reconcile_expired_runs_task() -> int:
    return reconcile_expired_runs_once()

