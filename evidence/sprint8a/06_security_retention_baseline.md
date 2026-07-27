# Sprint 8A Authentication, Authorization, Sensitive Data and Retention Baseline

## Sources of truth

Authentication and authorization:

- `backend/app/auth/dependencies.py`
- `backend/app/auth/security.py`
- `backend/app/auth/router.py`
- `backend/app/auth/schemas.py`

Audit logging:

- `backend/app/audit/service.py`
- `AuditEvent` in `backend/app/models.py`

Sensitive-log handling:

- `backend/app/shared/log_sanitizer.py`

Route protection:

- FastAPI dependency declarations throughout `backend/app`

Retention and deletion:

- model foreign-key deletion rules
- application cleanup and stale-run logic
- Alembic migrations

## Authentication mechanism

The backend uses OAuth2 bearer-token extraction through:

- `OAuth2PasswordBearer`
- token URL `/auth/login`

Access tokens are JWTs signed using:

- algorithm: `HS256`
- key source: `JWT_SECRET_KEY`

The current fallback secret is:

- `dev-only-change-this-secret`

This fallback is suitable only for local development.

Production startup should fail when a secure JWT secret is not configured.

## Token lifetime

The access-token expiration is controlled by:

- `ACCESS_TOKEN_EXPIRE_MINUTES`

The default value is:

- 1,440 minutes
- 24 hours

No refresh-token mechanism was identified.

No token-revocation or deny-list mechanism was identified.

## Password handling

Passwords are hashed and verified using Passlib with bcrypt.

The user model stores:

- `password_hash`

Plaintext passwords are not stored by the inspected implementation.

## Current-user resolution

`get_current_user`:

1. extracts the bearer token
2. decodes the JWT
3. reads the `sub` claim
4. loads the user from the database
5. rejects missing users
6. rejects inactive users

Invalid JWT decoding currently returns an empty dictionary, which is later
handled as an invalid authentication token.

## Role model

Supported role names include:

- `admin`
- `developer`
- `operator`
- `viewer`

Authorization is enforced through:

- `require_roles`

The implementation determines a user's authorization role using only:

- `user.roles[0]`

If a user has multiple roles, only the first role is considered.

This creates ordering ambiguity and may deny or grant access inconsistently
depending on relationship ordering.

Future authorization should evaluate the full role set.

## Registration security

The registration route accepts a requested role.

When no role is supplied:

- the first user becomes `admin`
- later users become `viewer`

When a valid role is supplied, the caller may request:

- `admin`
- `developer`
- `operator`
- `viewer`

The current route does not require an authenticated administrator to assign
privileged roles.

This is a material privilege-escalation risk.

Before production use, public registration must not allow callers to
self-assign privileged roles.

## Route protection baseline

The current application has mixed route-protection behavior.

### Explicitly protected areas

The primary Sprint 7 incident router uses role dependencies for:

- incident reads
- incident metrics
- incident detail
- incident timeline
- incident management operations
- assignment
- acknowledgement
- status updates
- comments

Some control-plane and pipeline operations also use role requirements.

### Routes requiring further review

Several route modules show database dependencies without an accompanying
current-user or role dependency, including portions of:

- deployment routes
- observability routes
- reliability routes
- event routes
- legacy incident routes
- control-plane routes
- pipeline read routes

A database dependency is not an authentication control.

The Sprint 8 RCA routes must not copy the least-protected route patterns.

## Proposed RCA authorization contract

Future RCA permissions should distinguish at least:

### RCA read

Likely allowed:

- `admin`
- `developer`
- `operator`
- possibly `viewer`

This includes:

- reading structured evidence
- reading completed RCA reports
- reading report status

### RCA generate or regenerate

Likely allowed:

- `admin`
- `developer`
- `operator`

This includes:

- initiating evidence collection
- initiating model generation
- retrying failed RCA jobs

### RCA administrative actions

Likely restricted to:

- `admin`

This may include:

- deleting reports
- overriding retention
- viewing raw sensitive evidence
- changing provider settings

The exact role matrix is proposed only and is not yet implemented.

## Audit logging

The application has an `AuditEvent` model and a reusable
`create_audit_event` service.

Audit events contain:

- `actor_id`
- `action`
- `entity_type`
- `entity_id`
- `details`
- `created_at`

The `details` payload is serialized to JSON text.

The helper adds the event to the current database transaction but does not
commit independently.

This is consistent with transactionally recording audit activity.

## RCA audit requirements

Future RCA operations should audit:

- evidence collection started
- evidence collection completed
- evidence collection failed
- RCA generation requested
- RCA report generated
- RCA generation failed
- RCA report regenerated
- RCA feedback submitted
- RCA report deleted or expired
- raw evidence viewed, if access is sensitive

Audit records should identify:

- incident ID
- RCA report ID
- actor ID
- action
- status
- provider/model identifier where appropriate
- sanitized failure code

Audit details must not include full raw logs, credentials, authorization
headers, or complete prompts.

## Existing log sanitization

`backend/app/shared/log_sanitizer.py` currently masks:

- `SONARQUBE_TOKEN`
- `SONAR_TOKEN`
- `sonar.login`
- `sonar.token`
- bearer authorization headers
- `-Dsonar.login`
- `-Dsonar.token`

It can also mask explicitly supplied known secret values with at least six
characters.

The replacement marker is:

- `****MASKED_SECRET****`

## Sanitization limitations

The current sanitizer does not explicitly cover:

- `OPENAI_API_KEY`
- generic API keys
- database URLs
- Redis URLs containing credentials
- Kafka credentials
- cookies
- session tokens
- private keys
- cloud-provider credentials
- GitHub tokens
- email addresses
- personal data
- arbitrary access tokens without known prefixes

Therefore, it is not sufficient as the only protection before sending logs to
an external RCA model.

## RCA sensitive-data requirements

Before model invocation, evidence must pass through a dedicated sanitization
layer that can:

1. mask configured secret values
2. mask known authorization formats
3. remove credentials from URLs
4. redact private keys
5. redact common API-key formats
6. limit log line lengths
7. cap the number of logs
8. remove binary or malformed content
9. classify human comments separately
10. avoid including unnecessary personal information

The original stored evidence and the model-safe evidence should be treated as
different representations.

## Provider credential handling

Docker Compose exposes provider configuration through environment variables
such as:

- `OPENAI_API_KEY`
- `OPENAI_MODEL`

The API key must never be:

- stored in evidence JSON
- stored in report prompts
- written to audit details
- returned in API responses
- written to task failure messages

Provider configuration must not be confused with authorization or a feature
flag.

## Retention findings

No dedicated application-level retention policy was identified for:

- incidents
- incident timelines
- incident metrics
- reliability alerts
- pipeline logs
- RCA evidence
- RCA reports
- audit records
- dead-letter events

Existing cleanup references relate primarily to:

- temporary pipeline workspaces
- stale-running pipeline detection
- incident correlation windows
- token expiration
- local or migration cleanup

These do not constitute a data-retention policy.

## Database deletion behavior

Existing models use combinations of:

- `CASCADE`
- `SET NULL`
- ORM `delete-orphan`

Examples include:

- incident child records cascading when an incident is deleted
- deployment references being set to null in some incident and alert records
- workload and revision records being deleted with their parent deployment

Future RCA models must define deletion behavior deliberately.

## Proposed RCA deletion contract

Recommended behavior:

### Incident deletion

When an incident is deleted:

- incident evidence should be deleted
- RCA reports should be deleted
- RCA feedback should be deleted

This can use database cascading if incident deletion is a supported operation.

### Deployment deletion

Deleting a deployment should not silently destroy the historical RCA report.

The report should retain a normalized evidence snapshot even if the live
deployment foreign key becomes null.

### User deletion

RCA feedback and report authorship should use `SET NULL` for user references
while retaining the historical content and timestamps.

### Audit records

Audit records should normally outlive operational records and should not be
cascade-deleted automatically without a defined compliance policy.

## Proposed retention controls

Sprint 8 should define configurable retention periods, for example:

- structured RCA evidence retention
- completed RCA report retention
- failed-job diagnostic retention
- raw log evidence retention
- audit-event retention

Potential environment configuration could include:

- `RCA_EVIDENCE_RETENTION_DAYS`
- `RCA_REPORT_RETENTION_DAYS`
- `RCA_FAILED_JOB_RETENTION_DAYS`
- `RCA_RAW_LOG_RETENTION_DAYS`

These are proposed controls only.

No retention setting should be considered implemented until corresponding
cleanup logic and tests exist.

## Minimum security requirements before RCA routes

Before RCA routes are enabled:

1. Protect every RCA route with explicit role dependencies.
2. Prevent self-assignment of privileged registration roles.
3. Require a secure production JWT secret.
4. Sanitize evidence before external model invocation.
5. Keep provider credentials out of persisted evidence.
6. Audit generation, retry, feedback and deletion actions.
7. Define evidence and report retention behavior.
8. Limit raw evidence returned to lower-privileged roles.
9. Do not expose model prompts directly through API responses.
10. Store sanitized failure messages rather than complete exceptions.

## Raw evidence files

- `raw/security_file_inventory.txt`
- `raw/auth_authorization_usage.txt`
- `raw/auth_security_implementation.txt`
- `raw/route_protection_usage.txt`
- `raw/sensitive_data_handling.txt`
- `raw/log_sanitizer_implementation.txt`
- `raw/audit_logging_usage.txt`
- `raw/retention_cleanup_usage.txt`
- `raw/database_deletion_relationships.txt`
