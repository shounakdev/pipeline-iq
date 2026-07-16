--
-- PostgreSQL database dump
--

\restrict 2f6w1ESuMkGhphLORZrJasChj6J7M5KPlibjW8xR8mQTIU1R2g7cPm0QHo33NU1

-- Dumped from database version 16.13 (Debian 16.13-1.pgdg13+1)
-- Dumped by pg_dump version 16.13 (Debian 16.13-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: error_budget_state; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.error_budget_state AS ENUM (
    'HEALTHY',
    'WARNING',
    'BREACHED',
    'EXHAUSTED'
);


ALTER TYPE public.error_budget_state OWNER TO postgres;

--
-- Name: incidentseverity; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.incidentseverity AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


ALTER TYPE public.incidentseverity OWNER TO postgres;

--
-- Name: incidentstatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.incidentstatus AS ENUM (
    'OPEN',
    'ACKNOWLEDGED',
    'RESOLVED',
    'FALSE_POSITIVE'
);


ALTER TYPE public.incidentstatus OWNER TO postgres;

--
-- Name: reliability_alert_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.reliability_alert_status AS ENUM (
    'OPEN',
    'ACKNOWLEDGED',
    'RESOLVED',
    'FALSE_POSITIVE'
);


ALTER TYPE public.reliability_alert_status OWNER TO postgres;

--
-- Name: reliability_alert_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.reliability_alert_type AS ENUM (
    'SLO_BREACH',
    'ERROR_BUDGET_BURN',
    'ERROR_BUDGET_EXHAUSTED',
    'LATENCY_BREACH',
    'AVAILABILITY_BREACH',
    'ERROR_RATE_BREACH'
);


ALTER TYPE public.reliability_alert_type OWNER TO postgres;

--
-- Name: reliability_severity; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.reliability_severity AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


ALTER TYPE public.reliability_severity OWNER TO postgres;

--
-- Name: servicehealthstatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.servicehealthstatus AS ENUM (
    'HEALTHY',
    'DEGRADED',
    'UNHEALTHY',
    'UNKNOWN'
);


ALTER TYPE public.servicehealthstatus OWNER TO postgres;

--
-- Name: slo_metric_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.slo_metric_type AS ENUM (
    'AVAILABILITY',
    'P95_LATENCY',
    'ERROR_RATE'
);


ALTER TYPE public.slo_metric_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: analysis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.analysis (
    id integer NOT NULL,
    pipeline_id character varying,
    failure_reason text,
    confidence double precision,
    suggestion text,
    final_status character varying,
    report_json text,
    created_at timestamp without time zone
);


ALTER TABLE public.analysis OWNER TO postgres;

--
-- Name: analysis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.analysis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.analysis_id_seq OWNER TO postgres;

--
-- Name: analysis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.analysis_id_seq OWNED BY public.analysis.id;


--
-- Name: audit_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_events (
    id character varying NOT NULL,
    actor_id character varying,
    action character varying NOT NULL,
    entity_type character varying,
    entity_id character varying,
    details text,
    created_at timestamp without time zone
);


ALTER TABLE public.audit_events OWNER TO postgres;

--
-- Name: consumer_checkpoints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consumer_checkpoints (
    id character varying NOT NULL,
    consumer_name character varying NOT NULL,
    topic character varying NOT NULL,
    partition integer NOT NULL,
    "offset" integer NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.consumer_checkpoints OWNER TO postgres;

--
-- Name: dead_letter_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dead_letter_events (
    id character varying NOT NULL,
    event_id character varying NOT NULL,
    event_type character varying,
    correlation_id character varying,
    service_id character varying,
    environment character varying,
    payload json,
    retry_count integer NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_retry_at timestamp with time zone,
    topic character varying,
    raw_event json,
    error_reason text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.dead_letter_events OWNER TO postgres;

--
-- Name: deployment_revisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deployment_revisions (
    id uuid NOT NULL,
    deployment_id uuid NOT NULL,
    revision character varying(100),
    image_tag character varying(255),
    commit_sha character varying(100),
    status character varying(50),
    created_at timestamp with time zone DEFAULT now(),
    deployed_at timestamp with time zone
);


ALTER TABLE public.deployment_revisions OWNER TO postgres;

--
-- Name: deployments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deployments (
    id uuid NOT NULL,
    service_id character varying(36) NOT NULL,
    pipeline_run_id character varying(36),
    environment_id character varying(36),
    commit_sha character varying(100),
    image_tag character varying(255) NOT NULL,
    deployment_version character varying(50),
    argo_sync_status character varying(50),
    kubernetes_rollout_status character varying(50),
    previous_revision character varying(100),
    namespace character varying(100),
    cluster_name character varying(100),
    service_name character varying(150),
    argo_application_name character varying(150),
    pod_count integer,
    restart_count integer,
    failure_reason text,
    created_at timestamp with time zone DEFAULT now(),
    deployed_at timestamp with time zone
);


ALTER TABLE public.deployments OWNER TO postgres;

--
-- Name: environments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.environments (
    id character varying NOT NULL,
    service_id character varying NOT NULL,
    name character varying NOT NULL,
    is_active boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.environments OWNER TO postgres;

--
-- Name: error_budget_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.error_budget_statuses (
    id character varying(36) NOT NULL,
    slo_definition_id character varying(36) NOT NULL,
    service_id character varying(36) NOT NULL,
    target_percentage double precision NOT NULL,
    allowed_failure_percentage double precision NOT NULL,
    consumed_percentage double precision DEFAULT '0'::double precision NOT NULL,
    remaining_percentage double precision DEFAULT '100'::double precision NOT NULL,
    burn_rate double precision DEFAULT '0'::double precision NOT NULL,
    status public.error_budget_state DEFAULT 'HEALTHY'::public.error_budget_state NOT NULL,
    window_minutes integer NOT NULL,
    evaluated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.error_budget_statuses OWNER TO postgres;

--
-- Name: event_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_records (
    id character varying NOT NULL,
    event_id character varying NOT NULL,
    event_type character varying NOT NULL,
    topic character varying NOT NULL,
    schema_version character varying,
    correlation_id character varying,
    service_id character varying,
    environment character varying,
    payload json NOT NULL,
    processing_status character varying NOT NULL,
    processed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    "timestamp" timestamp with time zone,
    raw_event json NOT NULL,
    processing_error text
);


ALTER TABLE public.event_records OWNER TO postgres;

--
-- Name: incident_alert_links; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incident_alert_links (
    id uuid NOT NULL,
    incident_id uuid NOT NULL,
    reliability_alert_id character varying(36) NOT NULL,
    linked_at timestamp with time zone DEFAULT now() NOT NULL,
    is_triggering_alert boolean DEFAULT false NOT NULL
);


ALTER TABLE public.incident_alert_links OWNER TO postgres;

--
-- Name: incident_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incident_assignments (
    id uuid NOT NULL,
    incident_id uuid NOT NULL,
    assigned_to_user_id character varying(36),
    assigned_by_user_id character varying(36),
    assignment_note text,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    unassigned_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.incident_assignments OWNER TO postgres;

--
-- Name: incident_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incident_comments (
    id uuid NOT NULL,
    incident_id uuid NOT NULL,
    author_user_id character varying(36),
    comment text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.incident_comments OWNER TO postgres;

--
-- Name: incident_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incident_events (
    id uuid NOT NULL,
    incident_id uuid NOT NULL,
    event_type character varying NOT NULL,
    message text,
    metadata json,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.incident_events OWNER TO postgres;

--
-- Name: incident_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incident_metrics (
    id uuid NOT NULL,
    incident_id uuid NOT NULL,
    metric_type character varying(100) NOT NULL,
    metric_name character varying(255) NOT NULL,
    value double precision NOT NULL,
    unit character varying(50),
    source character varying(100) DEFAULT 'UNKNOWN'::character varying NOT NULL,
    captured_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata_json jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.incident_metrics OWNER TO postgres;

--
-- Name: incident_timeline_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incident_timeline_events (
    id uuid NOT NULL,
    incident_id uuid NOT NULL,
    event_type character varying(100) NOT NULL,
    source character varying(100) DEFAULT 'SYSTEM'::character varying NOT NULL,
    message text,
    from_status public.incidentstatus,
    to_status public.incidentstatus,
    actor_user_id character varying(36),
    alert_id character varying(36),
    deployment_id uuid,
    metadata_json jsonb,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.incident_timeline_events OWNER TO postgres;

--
-- Name: incidents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incidents (
    id uuid NOT NULL,
    title character varying NOT NULL,
    description text,
    severity public.incidentseverity NOT NULL,
    status public.incidentstatus NOT NULL,
    service_id character varying NOT NULL,
    environment character varying NOT NULL,
    correlation_id character varying NOT NULL,
    triggered_by_event_id character varying,
    started_at timestamp without time zone NOT NULL,
    resolved_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.incidents OWNER TO postgres;

--
-- Name: kubernetes_workloads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kubernetes_workloads (
    id uuid NOT NULL,
    deployment_id uuid NOT NULL,
    workload_name character varying(150) NOT NULL,
    namespace character varying(100) NOT NULL,
    kind character varying(50) NOT NULL,
    desired_replicas integer,
    available_replicas integer,
    pod_count integer,
    restart_count integer,
    status character varying(50),
    failure_reason text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.kubernetes_workloads OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    id integer NOT NULL,
    pipeline_id character varying,
    log_text text NOT NULL,
    "timestamp" timestamp without time zone
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.logs_id_seq OWNER TO postgres;

--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logs_id_seq OWNED BY public.logs.id;


--
-- Name: outbox_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.outbox_events (
    id character varying NOT NULL,
    event_id character varying NOT NULL,
    topic character varying NOT NULL,
    event_type character varying NOT NULL,
    schema_version character varying NOT NULL,
    correlation_id character varying,
    service_id character varying,
    environment character varying,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count integer NOT NULL,
    last_error text,
    published_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.outbox_events OWNER TO postgres;

--
-- Name: pipeline_runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pipeline_runs (
    id character varying NOT NULL,
    service_id character varying,
    repo_id character varying,
    repo_url character varying NOT NULL,
    branch character varying,
    status character varying,
    stage character varying,
    failure_reason text,
    commit_sha character varying,
    commit_message text,
    build_status character varying,
    test_status character varying,
    sonar_status character varying,
    trivy_status character varying,
    coverage double precision,
    bugs integer,
    vulnerabilities integer,
    code_smells integer,
    duplicated_lines_density double precision,
    quality_gate character varying,
    sonar_report_url character varying,
    sonar_issues json NOT NULL,
    trivy_critical integer,
    trivy_high integer,
    trivy_medium integer,
    trivy_low integer,
    trivy_unknown integer,
    trivy_total integer,
    trivy_report json,
    risk_score double precision,
    risk_level character varying,
    risk_summary text,
    ai_summary text,
    recommendations json NOT NULL,
    logs json NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    duration_seconds double precision
);


ALTER TABLE public.pipeline_runs OWNER TO postgres;

--
-- Name: pipelines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pipelines (
    id character varying NOT NULL,
    repo_url text NOT NULL,
    branch character varying NOT NULL,
    status character varying NOT NULL,
    progress integer,
    error_message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    duration_seconds double precision,
    quality_score double precision,
    coverage double precision,
    bugs integer,
    vulnerabilities integer,
    code_smells integer,
    duplicated_lines_density double precision,
    quality_gate character varying,
    sonar_report_url text,
    stage character varying,
    failure_reason text,
    commit_sha character varying,
    commit_message text,
    build_status character varying,
    test_status character varying,
    sonar_status character varying,
    trivy_status character varying,
    sonar_issues json,
    trivy_critical integer,
    trivy_high integer,
    trivy_medium integer,
    trivy_low integer,
    trivy_unknown integer,
    trivy_total integer,
    trivy_report json,
    risk_score double precision,
    risk_level character varying,
    risk_summary text,
    ai_summary text,
    recommendations json
);


ALTER TABLE public.pipelines OWNER TO postgres;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    created_by character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: reliability_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reliability_alerts (
    id character varying(36) NOT NULL,
    service_id character varying(36) NOT NULL,
    slo_definition_id character varying(36) NOT NULL,
    alert_type public.reliability_alert_type NOT NULL,
    severity public.reliability_severity NOT NULL,
    triggered_value double precision NOT NULL,
    threshold_value double precision NOT NULL,
    deployment_id uuid,
    status public.reliability_alert_status DEFAULT 'OPEN'::public.reliability_alert_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    resolved_at timestamp with time zone
);


ALTER TABLE public.reliability_alerts OWNER TO postgres;

--
-- Name: repositories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repositories (
    id character varying NOT NULL,
    service_id character varying NOT NULL,
    provider character varying,
    repo_url text NOT NULL,
    default_branch character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.repositories OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: service_health_snapshots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_health_snapshots (
    id uuid NOT NULL,
    service_id character varying NOT NULL,
    service_name character varying NOT NULL,
    environment character varying NOT NULL,
    status public.servicehealthstatus NOT NULL,
    latency_ms double precision,
    error_rate double precision,
    cpu_usage double precision,
    memory_usage double precision,
    pod_restart_count integer,
    replica_count integer,
    available_replicas integer,
    source character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.service_health_snapshots OWNER TO postgres;

--
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.services (
    id character varying NOT NULL,
    project_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    service_type character varying,
    owner character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.services OWNER TO postgres;

--
-- Name: slo_definitions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slo_definitions (
    id character varying(36) NOT NULL,
    service_id character varying(36) NOT NULL,
    metric_type public.slo_metric_type NOT NULL,
    target_value double precision NOT NULL,
    window_minutes integer DEFAULT 60 NOT NULL,
    severity_on_breach public.reliability_severity DEFAULT 'HIGH'::public.reliability_severity NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.slo_definitions OWNER TO postgres;

--
-- Name: slo_measurements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slo_measurements (
    id character varying(36) NOT NULL,
    slo_definition_id character varying(36) NOT NULL,
    service_id character varying(36) NOT NULL,
    metric_type public.slo_metric_type NOT NULL,
    measured_value double precision NOT NULL,
    target_value double precision NOT NULL,
    is_breached boolean NOT NULL,
    window_minutes integer NOT NULL,
    source character varying(50) DEFAULT 'PROMETHEUS'::character varying NOT NULL,
    evaluated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.slo_measurements OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    user_id character varying NOT NULL,
    role_id character varying NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying NOT NULL,
    email character varying NOT NULL,
    password_hash character varying,
    full_name character varying,
    is_active boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: analysis id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis ALTER COLUMN id SET DEFAULT nextval('public.analysis_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public.logs_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
fbe13f728ba0
\.


--
-- Data for Name: analysis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.analysis (id, pipeline_id, failure_reason, confidence, suggestion, final_status, report_json, created_at) FROM stdin;
1	03505498-9850-46c5-9b43-2d5aeb2ac988	Pipeline finished with status SUCCESS. Quality gate: PASSED.	0.7	Fix any failed build or test command first.\nResolve critical/high security vulnerabilities.\nFix SonarQube quality gate failures.\nImprove test coverage if it is below threshold.\nRerun the pipeline after fixes.	PASS_WITH_WARNINGS	{"final_status": "PASS_WITH_WARNINGS", "overall_summary": "Pipeline finished with status SUCCESS. Quality gate: PASSED.", "log_summary": "The logs were analyzed using fallback logic. Check npm, build, test, and scanner warnings.", "sonarqube_summary": "Coverage: 0%, Bugs: 1.0, Vulnerabilities: 0, Code smells: 0, Quality gate: PASSED.", "priority_items": [{"priority": "HIGH", "issue": "Security vulnerabilities were detected.", "why_it_matters": "Critical or high vulnerabilities can expose the application to attacks.", "suggested_fix": "Run npm audit, identify affected packages, upgrade dependencies, and rerun the pipeline.", "helpful_link": "http://localhost:9000/dashboard?id=cicd-demo"}, {"priority": "MEDIUM", "issue": "Coverage is below recommended threshold: 0%.", "why_it_matters": "Low coverage increases risk of undetected bugs.", "suggested_fix": "Add tests for critical business logic and generate LCOV coverage before SonarQube scan.", "helpful_link": "http://localhost:9000/dashboard?id=cicd-demo"}, {"priority": "LOW", "issue": "Warnings or maintainability issues found. Bugs: 1.0, Code smells: 0.", "why_it_matters": "Warnings and code smells may reduce maintainability over time.", "suggested_fix": "Fix lint warnings, unused variables, React hook dependency warnings, and SonarQube issues.", "helpful_link": "http://localhost:9000/dashboard?id=cicd-demo"}], "how_to_pass": ["Fix any failed build or test command first.", "Resolve critical/high security vulnerabilities.", "Fix SonarQube quality gate failures.", "Improve test coverage if it is below threshold.", "Rerun the pipeline after fixes."], "confidence": 0.7}	2026-05-17 14:58:01.387878
2	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Pipeline finished with status SUCCESS. Quality gate: PASSED.	0.7	Fix any failed build or test command first.\nResolve critical/high security vulnerabilities.\nFix SonarQube quality gate failures.\nImprove test coverage if it is below threshold.\nRerun the pipeline after fixes.	PASS_WITH_WARNINGS	{"final_status": "PASS_WITH_WARNINGS", "overall_summary": "Pipeline finished with status SUCCESS. Quality gate: PASSED.", "log_summary": "The logs were analyzed using fallback logic. Check npm, build, test, and scanner warnings.", "sonarqube_summary": "Coverage: 0%, Bugs: 1.0, Vulnerabilities: 0, Code smells: 0, Quality gate: PASSED.", "priority_items": [{"priority": "HIGH", "issue": "Security vulnerabilities were detected.", "why_it_matters": "Critical or high vulnerabilities can expose the application to attacks.", "suggested_fix": "Run npm audit, identify affected packages, upgrade dependencies, and rerun the pipeline.", "helpful_link": "http://localhost:9000/dashboard?id=cicd-demo"}, {"priority": "MEDIUM", "issue": "Coverage is below recommended threshold: 0%.", "why_it_matters": "Low coverage increases risk of undetected bugs.", "suggested_fix": "Add tests for critical business logic and generate LCOV coverage before SonarQube scan.", "helpful_link": "http://localhost:9000/dashboard?id=cicd-demo"}, {"priority": "LOW", "issue": "Warnings or maintainability issues found. Bugs: 1.0, Code smells: 0.", "why_it_matters": "Warnings and code smells may reduce maintainability over time.", "suggested_fix": "Fix lint warnings, unused variables, React hook dependency warnings, and SonarQube issues.", "helpful_link": "http://localhost:9000/dashboard?id=cicd-demo"}], "how_to_pass": ["Fix any failed build or test command first.", "Resolve critical/high security vulnerabilities.", "Fix SonarQube quality gate failures.", "Improve test coverage if it is below threshold.", "Rerun the pipeline after fixes."], "confidence": 0.7}	2026-05-17 15:27:52.582411
3	bd502165-da51-42d7-bc10-ee67681015c9	Pipeline finished with status SUCCESS. Quality gate: PASSED.	0.7	Fix any failed build or test command first.\nResolve critical/high security vulnerabilities.\nFix SonarQube quality gate failures.\nImprove test coverage if it is below threshold.\nRerun the pipeline after fixes.	PASS_WITH_WARNINGS	{"final_status": "PASS_WITH_WARNINGS", "overall_summary": "Pipeline finished with status SUCCESS. Quality gate: PASSED.", "log_summary": "The logs were analyzed using fallback logic. Check npm, build, test, and scanner warnings.", "sonarqube_summary": "Coverage: 0%, Bugs: 0, Vulnerabilities: 0, Code smells: 0, Quality gate: PASSED.", "priority_items": [{"priority": "MEDIUM", "issue": "Coverage is below recommended threshold: 0%.", "why_it_matters": "Low coverage increases risk of undetected bugs.", "suggested_fix": "Add tests for critical business logic and generate LCOV coverage before SonarQube scan.", "helpful_link": "http://localhost:9000/dashboard?id=cicd-demo"}, {"priority": "LOW", "issue": "Warnings or maintainability issues found. Bugs: 0, Code smells: 0.", "why_it_matters": "Warnings and code smells may reduce maintainability over time.", "suggested_fix": "Fix lint warnings, unused variables, React hook dependency warnings, and SonarQube issues.", "helpful_link": "http://localhost:9000/dashboard?id=cicd-demo"}], "how_to_pass": ["Fix any failed build or test command first.", "Resolve critical/high security vulnerabilities.", "Fix SonarQube quality gate failures.", "Improve test coverage if it is below threshold.", "Rerun the pipeline after fixes."], "confidence": 0.7}	2026-05-17 15:34:17.572493
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_events (id, actor_id, action, entity_type, entity_id, details, created_at) FROM stdin;
\.


--
-- Data for Name: consumer_checkpoints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.consumer_checkpoints (id, consumer_name, topic, partition, "offset", updated_at) FROM stdin;
\.


--
-- Data for Name: dead_letter_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dead_letter_events (id, event_id, event_type, correlation_id, service_id, environment, payload, retry_count, status, created_at, last_retry_at, topic, raw_event, error_reason, updated_at) FROM stdin;
a36d2bc3-cd2b-4984-aa80-bb2bc581de8d	dlq_f64957c1-664a-40fb-a384-14fa5007b4bf	BAD_EVENT_WITHOUT_EVENT_ID	\N	\N	\N	{"broken": true}	0	OPEN	2026-06-28 11:30:45.777693+00	\N	kubernetes.events	{"event_type": "BAD_EVENT_WITHOUT_EVENT_ID", "payload": {"broken": true}}	Invalid event envelope. Missing fields: ['event_id', 'schema_version', 'correlation_id', 'timestamp']	2026-06-28 11:30:45.777693+00
ce05ec01-4ba6-4a66-a8ff-e32357c7c66a	evt_cb7236e5-a0a9-4fee-a9f1-f3d1eaec6c25	HIGH_ERROR_RATE	8c63a58b-210c-4019-bc7a-b655bfacddd2	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2"}	0	OPEN	2026-07-05 16:56:11.544808+00	\N	telemetry.alerts	{"event_id": "evt_cb7236e5-a0a9-4fee-a9f1-f3d1eaec6c25", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "correlation_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T20:37:49.952975+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.544808+00
8d515662-0ec6-4e51-be01-a307f8c61126	evt_025ab916-1b99-484e-ad87-59ec01d53b56	HIGH_LATENCY	8c63a58b-210c-4019-bc7a-b655bfacddd2	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2"}	0	OPEN	2026-07-05 16:56:11.655314+00	\N	telemetry.alerts	{"event_id": "evt_025ab916-1b99-484e-ad87-59ec01d53b56", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "correlation_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T20:37:49.953932+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.655314+00
8deaef74-9ba6-45af-9286-496f22747d44	evt_6691583b-86cc-4795-bacd-98513cf69210	POD_RESTART_SPIKE	8c63a58b-210c-4019-bc7a-b655bfacddd2	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2"}	0	OPEN	2026-07-05 16:56:11.672084+00	\N	telemetry.alerts	{"event_id": "evt_6691583b-86cc-4795-bacd-98513cf69210", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "correlation_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T20:37:49.953962+00:00", "payload": {"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.672084+00
4894c32d-38fb-4bc1-9e64-23e47d105006	evt_e7bca295-6596-49f2-abe4-a97372f2fb78	SERVICE_DEGRADED	8c63a58b-210c-4019-bc7a-b655bfacddd2	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2"}	0	OPEN	2026-07-05 16:56:11.689184+00	\N	telemetry.alerts	{"event_id": "evt_e7bca295-6596-49f2-abe4-a97372f2fb78", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "correlation_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T20:37:49.953979+00:00", "payload": {"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "8c63a58b-210c-4019-bc7a-b655bfacddd2"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.689184+00
ad9f4058-7b6b-4697-9658-b15c1257ad0a	evt_dcef17fb-1dd6-40c9-a9e2-e693a04978c6	HIGH_ERROR_RATE	21aaf1ee-dff3-4463-8fd1-65cbf1853f51	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}	0	OPEN	2026-07-05 16:56:11.706227+00	\N	telemetry.alerts	{"event_id": "evt_dcef17fb-1dd6-40c9-a9e2-e693a04978c6", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T21:06:16.892573+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.706227+00
80b9f50e-c7ad-46b2-befc-d2180f2b06f3	evt_bad15fe8-a1cc-443d-80a6-ae98be2f83a5	HIGH_LATENCY	21aaf1ee-dff3-4463-8fd1-65cbf1853f51	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}	0	OPEN	2026-07-05 16:56:11.722888+00	\N	telemetry.alerts	{"event_id": "evt_bad15fe8-a1cc-443d-80a6-ae98be2f83a5", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T21:06:16.911209+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.722888+00
069b7baa-b16c-4365-812b-de04324d1325	evt_bb5a0876-b512-44b7-980c-4b4fc9b1baab	POD_RESTART_SPIKE	21aaf1ee-dff3-4463-8fd1-65cbf1853f51	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}	0	OPEN	2026-07-05 16:56:11.739624+00	\N	telemetry.alerts	{"event_id": "evt_bb5a0876-b512-44b7-980c-4b4fc9b1baab", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T21:06:16.916696+00:00", "payload": {"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.739624+00
921cd0b9-52ec-443f-a9d1-a77a54ce476b	evt_fc9763db-c133-4d21-bc3f-4770c1239e56	SERVICE_DEGRADED	21aaf1ee-dff3-4463-8fd1-65cbf1853f51	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}	0	OPEN	2026-07-05 16:56:11.756072+00	\N	telemetry.alerts	{"event_id": "evt_fc9763db-c133-4d21-bc3f-4770c1239e56", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "severity": "MEDIUM", "correlation_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T21:06:16.919517+00:00", "payload": {"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.756072+00
a87f90c5-abf1-4575-a672-b208a5a76d7c	evt_7fd7dd56-e98d-4444-9826-98fa63749f99	HIGH_LATENCY	79a37362-9300-45a1-b2ef-d7ec3794764e	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "79a37362-9300-45a1-b2ef-d7ec3794764e"}	0	OPEN	2026-07-05 16:56:11.772166+00	\N	telemetry.alerts	{"event_id": "evt_7fd7dd56-e98d-4444-9826-98fa63749f99", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "79a37362-9300-45a1-b2ef-d7ec3794764e", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:37:37.404946+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "79a37362-9300-45a1-b2ef-d7ec3794764e"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.772166+00
abfad644-cec5-48c8-98e2-16758f0830f6	evt_92a960d9-feac-41de-84c8-7dd59f68031d	SERVICE_DOWN	79a37362-9300-45a1-b2ef-d7ec3794764e	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "79a37362-9300-45a1-b2ef-d7ec3794764e"}	0	OPEN	2026-07-05 16:56:11.7886+00	\N	telemetry.alerts	{"event_id": "evt_92a960d9-feac-41de-84c8-7dd59f68031d", "event_type": "SERVICE_DOWN", "schema_version": "1.0", "severity": "CRITICAL", "correlation_id": "79a37362-9300-45a1-b2ef-d7ec3794764e", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:37:37.427059+00:00", "payload": {"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "79a37362-9300-45a1-b2ef-d7ec3794764e"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.7886+00
9c32a8f3-7785-4f83-98de-c643ac228fa3	evt_fe913dba-05b3-4960-af9e-8add89c2b370	HIGH_ERROR_RATE	74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda"}	0	OPEN	2026-07-05 16:56:11.804959+00	\N	telemetry.alerts	{"event_id": "evt_fe913dba-05b3-4960-af9e-8add89c2b370", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:38:30.526414+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.804959+00
fa47bcf4-3a13-4766-926a-f6664bf7eb7f	evt_3ec08cd2-b6f1-49f0-b1fb-fde2d7f4cbc9	SERVICE_DOWN	74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda"}	0	OPEN	2026-07-05 16:56:11.821175+00	\N	telemetry.alerts	{"event_id": "evt_3ec08cd2-b6f1-49f0-b1fb-fde2d7f4cbc9", "event_type": "SERVICE_DOWN", "schema_version": "1.0", "severity": "CRITICAL", "correlation_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:38:30.532061+00:00", "payload": {"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.821175+00
10ba19c0-898d-4b73-b88e-e91399dc8b83	evt_9f705e94-54f7-4eed-b990-301dcf61e477	POD_RESTART_SPIKE	a0a4d25b-012f-40dd-801a-9e059380cac1	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"pod_restart_count": 7, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "a0a4d25b-012f-40dd-801a-9e059380cac1"}	0	OPEN	2026-07-05 16:56:11.836779+00	\N	telemetry.alerts	{"event_id": "evt_9f705e94-54f7-4eed-b990-301dcf61e477", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "a0a4d25b-012f-40dd-801a-9e059380cac1", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:40:43.333462+00:00", "payload": {"pod_restart_count": 7, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "a0a4d25b-012f-40dd-801a-9e059380cac1"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.836779+00
dadca6fc-e111-4738-a300-47219451fb8d	evt_ae0d0a2b-4435-4e6f-89cb-39c92c91d411	SERVICE_DEGRADED	a0a4d25b-012f-40dd-801a-9e059380cac1	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"available_replicas": 2, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "a0a4d25b-012f-40dd-801a-9e059380cac1"}	0	OPEN	2026-07-05 16:56:11.85163+00	\N	telemetry.alerts	{"event_id": "evt_ae0d0a2b-4435-4e6f-89cb-39c92c91d411", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "severity": "MEDIUM", "correlation_id": "a0a4d25b-012f-40dd-801a-9e059380cac1", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:40:43.340718+00:00", "payload": {"available_replicas": 2, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "a0a4d25b-012f-40dd-801a-9e059380cac1"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 16:56:11.85163+00
e573f033-faf0-4254-b7b6-f7744663d660	dlq_83435649-5bd7-4c97-86f8-3be41f3bf964	\N	\N	\N	\N	null	0	OPEN	2026-07-05 16:56:22.195353+00	\N	telemetry.alerts	{"bad": true}	Invalid event envelope. Missing fields: ['event_id', 'event_type', 'schema_version', 'correlation_id', 'timestamp', 'payload']	2026-07-05 16:56:22.195353+00
cc4403a0-b3ed-44d8-a1ac-eaad1b81ab00	dlq_003202e6-bcdd-4384-b1c0-600f02bc86cd	\N	\N	\N	\N	null	0	OPEN	2026-07-05 16:56:22.224048+00	\N	telemetry.alerts	{"raw": "\\\\q"}	Invalid JSON: Expecting value: line 1 column 1 (char 0)	2026-07-05 16:56:22.224048+00
33347717-65af-46ad-8663-6ee47bb5a09d	dlq_ec36e8be-17dc-4f85-887d-a9111a079d87	\N	\N	\N	\N	null	0	OPEN	2026-07-05 16:56:22.244156+00	\N	telemetry.alerts	{"raw": "not-json"}	Invalid JSON: Expecting value: line 1 column 1 (char 0)	2026-07-05 16:56:22.244156+00
2dc6c583-c837-4256-9036-73665400524f	dlq_a80611ff-05cb-4287-94cc-3d0a7a13fb6e	\N	\N	\N	\N	null	0	OPEN	2026-07-05 16:57:51.193755+00	\N	telemetry.alerts	{"raw": "scenario5-bad-json-1783270665"}	Invalid JSON: Expecting value: line 1 column 1 (char 0)	2026-07-05 16:57:51.193755+00
6b7ec1cb-d51a-40d0-bbd3-9380b9d20762	dlq_3f15193e-9b0f-41a0-a068-2f3c4b016dee	\N	\N	\N	\N	null	0	OPEN	2026-07-05 16:58:25.796836+00	\N	telemetry.alerts	{"raw": "scenario5-bad-json-1783270704"}	Invalid JSON: Expecting value: line 1 column 1 (char 0)	2026-07-05 16:58:25.796836+00
3a698d17-70f4-417d-820d-cb520c9124f9	evt_eb37f920-f5b0-4bc1-aef2-3dfcc17cfeae	HIGH_LATENCY	2ae251be-c681-4f94-82d7-ba1919f31981	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "2ae251be-c681-4f94-82d7-ba1919f31981"}	0	OPEN	2026-07-05 17:06:31.218272+00	\N	telemetry.alerts	{"event_id": "evt_eb37f920-f5b0-4bc1-aef2-3dfcc17cfeae", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "2ae251be-c681-4f94-82d7-ba1919f31981", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:06:29.700837+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "2ae251be-c681-4f94-82d7-ba1919f31981"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 17:06:31.218272+00
48d935bc-c3ef-44d1-9e9a-49fcf476c7bb	evt_76056b05-df98-4deb-ba70-d6be16fad31a	SERVICE_DOWN	2ae251be-c681-4f94-82d7-ba1919f31981	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "2ae251be-c681-4f94-82d7-ba1919f31981"}	0	OPEN	2026-07-05 17:06:31.242094+00	\N	telemetry.alerts	{"event_id": "evt_76056b05-df98-4deb-ba70-d6be16fad31a", "event_type": "SERVICE_DOWN", "schema_version": "1.0", "severity": "CRITICAL", "correlation_id": "2ae251be-c681-4f94-82d7-ba1919f31981", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:06:29.722990+00:00", "payload": {"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "2ae251be-c681-4f94-82d7-ba1919f31981"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 17:06:31.242094+00
be9786d9-cfed-4f9e-a4c8-5e629ffc6f98	evt_893dc7b6-a556-4997-950a-2072f849eea8	HIGH_ERROR_RATE	a6522068-03c8-46cd-93a4-741b1db36b7f	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "a6522068-03c8-46cd-93a4-741b1db36b7f"}	0	OPEN	2026-07-05 17:07:35.402563+00	\N	telemetry.alerts	{"event_id": "evt_893dc7b6-a556-4997-950a-2072f849eea8", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "a6522068-03c8-46cd-93a4-741b1db36b7f", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:07:35.278439+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "a6522068-03c8-46cd-93a4-741b1db36b7f"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 17:07:35.402563+00
43ee73ec-c1d2-4111-bb5c-9682a33ff31f	evt_f765ba6c-3acf-465f-aee6-28b45fe33ef0	SERVICE_DOWN	a6522068-03c8-46cd-93a4-741b1db36b7f	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "a6522068-03c8-46cd-93a4-741b1db36b7f"}	0	OPEN	2026-07-05 17:07:35.420531+00	\N	telemetry.alerts	{"event_id": "evt_f765ba6c-3acf-465f-aee6-28b45fe33ef0", "event_type": "SERVICE_DOWN", "schema_version": "1.0", "severity": "CRITICAL", "correlation_id": "a6522068-03c8-46cd-93a4-741b1db36b7f", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:07:35.286018+00:00", "payload": {"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "a6522068-03c8-46cd-93a4-741b1db36b7f"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 17:07:35.420531+00
b17d1db1-6527-4abe-b11b-0b7ef0450684	evt_0b9473db-d411-40e5-b9be-3ff68c1607b5	POD_RESTART_SPIKE	ef569b8b-3352-4a87-9f07-87249758ff99	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"pod_restart_count": 7, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "ef569b8b-3352-4a87-9f07-87249758ff99"}	0	OPEN	2026-07-05 17:17:11.262613+00	\N	telemetry.alerts	{"event_id": "evt_0b9473db-d411-40e5-b9be-3ff68c1607b5", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "ef569b8b-3352-4a87-9f07-87249758ff99", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:17:10.191675+00:00", "payload": {"pod_restart_count": 7, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "ef569b8b-3352-4a87-9f07-87249758ff99"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 17:17:11.262613+00
99d34ae6-758b-47f1-abbd-1a46da2f2777	evt_88dcf0cc-1934-4479-8f92-53f185e0df34	SERVICE_DEGRADED	ef569b8b-3352-4a87-9f07-87249758ff99	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"available_replicas": 2, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "ef569b8b-3352-4a87-9f07-87249758ff99"}	0	OPEN	2026-07-05 17:17:11.284837+00	\N	telemetry.alerts	{"event_id": "evt_88dcf0cc-1934-4479-8f92-53f185e0df34", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "severity": "MEDIUM", "correlation_id": "ef569b8b-3352-4a87-9f07-87249758ff99", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:17:10.205822+00:00", "payload": {"available_replicas": 2, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "ef569b8b-3352-4a87-9f07-87249758ff99"}}	type object 'Incident' has no attribute 'source_event_id'	2026-07-05 17:17:11.284837+00
f3840ffd-354f-43fa-8d33-34067b066611	dlq_fb53ed40-8685-4bbb-92f2-4e6d1d0e9873	\N	\N	\N	\N	null	0	OPEN	2026-07-05 17:18:23.598836+00	\N	telemetry.alerts	{"raw": "scenario5-final-bad-json-1783271902"}	Invalid JSON: Expecting value: line 1 column 1 (char 0)	2026-07-05 17:18:23.598836+00
44700bed-b72a-41c5-a4cc-ce608f9d69c2	evt_f5ec3291-c1c5-426f-b2e1-b60de99d7074	ERROR_BUDGET_EXHAUSTED	79a28492-b0d4-4098-94ce-70c4df2785cd:staging:AVAILABILITY	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"source": "platformiq-reliability", "severity": "HIGH", "burn_rate": 5.000000000000284, "rapid_burn": true, "is_breached": true, "metric_type": "AVAILABILITY", "service_name": "demo-service", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "measurement_id": "01917c13-827f-4224-a5a1-cb30fc86fcdc", "window_minutes": 60, "threshold_value": 99.9, "triggered_value": 99.5, "slo_definition_id": "4b572d35-cb52-47f2-9b91-f98577ade93a", "error_budget_status": "EXHAUSTED", "reliability_alert_id": "d0391e45-448f-45b0-b978-be94302328b7", "error_budget_consumed": 500.0000000000284, "error_budget_remaining": 0.0}	1	OPEN	2026-07-11 21:10:29.743341+00	\N	telemetry.alerts	{"event_id": "evt_f5ec3291-c1c5-426f-b2e1-b60de99d7074", "event_type": "ERROR_BUDGET_EXHAUSTED", "schema_version": "1.0", "correlation_id": "79a28492-b0d4-4098-94ce-70c4df2785cd:staging:AVAILABILITY", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "environment": "staging", "timestamp": "2026-07-11T21:10:18.381041+00:00", "payload": {"source": "platformiq-reliability", "severity": "HIGH", "burn_rate": 5.000000000000284, "rapid_burn": true, "is_breached": true, "metric_type": "AVAILABILITY", "service_name": "demo-service", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "measurement_id": "01917c13-827f-4224-a5a1-cb30fc86fcdc", "window_minutes": 60, "threshold_value": 99.9, "triggered_value": 99.5, "slo_definition_id": "4b572d35-cb52-47f2-9b91-f98577ade93a", "error_budget_status": "EXHAUSTED", "reliability_alert_id": "d0391e45-448f-45b0-b978-be94302328b7", "error_budget_consumed": 500.0000000000284, "error_budget_remaining": 0.0}}	Telemetry alert missing snapshot_id for event_id=evt_f5ec3291-c1c5-426f-b2e1-b60de99d7074	2026-07-11 21:25:58.079849+00
\.


--
-- Data for Name: deployment_revisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deployment_revisions (id, deployment_id, revision, image_tag, commit_sha, status, created_at, deployed_at) FROM stdin;
b860070d-e895-46ca-878f-7cf4f2eda946	f361e53b-71d4-4a78-b351-c06715180477	v1.0.0-sprint-4g	demo-service:manual-sprint-4g	manual-test-sha	UNKNOWN	2026-06-28 06:16:46.617744+00	2026-06-28 06:16:46.23189+00
61f3cb3d-5761-46cc-b727-f369676e4420	dacd606c-4046-4466-a268-fcae7f6d3940	v1.0.1-sprint-4g	demo-service:manual-sprint-4g-2	manual-test-sha-2	UNKNOWN	2026-06-28 06:24:37.350842+00	2026-06-28 06:24:37.105199+00
9d62bf7b-d5e9-4380-826f-d48fbc22127a	2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727	v1.0.2-sprint-4g-failed	demo-service:manual-sprint-4g-failed	manual-test-sha-failed	UNKNOWN	2026-06-28 06:26:12.53169+00	2026-06-28 06:26:12.530012+00
\.


--
-- Data for Name: deployments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deployments (id, service_id, pipeline_run_id, environment_id, commit_sha, image_tag, deployment_version, argo_sync_status, kubernetes_rollout_status, previous_revision, namespace, cluster_name, service_name, argo_application_name, pod_count, restart_count, failure_reason, created_at, deployed_at) FROM stdin;
f361e53b-71d4-4a78-b351-c06715180477	79a28492-b0d4-4098-94ce-70c4df2785cd	\N	\N	manual-test-sha	demo-service:manual-sprint-4g	v1.0.0-sprint-4g	UNKNOWN	UNKNOWN	\N	platformiq-demo	kind-platformiq	demo-service	demo-service-app	0	0	\N	2026-06-28 06:16:46.617744+00	2026-06-28 06:16:46.23189+00
dacd606c-4046-4466-a268-fcae7f6d3940	79a28492-b0d4-4098-94ce-70c4df2785cd	\N	\N	manual-test-sha-2	demo-service:manual-sprint-4g-2	v1.0.1-sprint-4g	SYNCED	HEALTHY	\N	platformiq-demo	kind-platformiq	demo-service	demo-service-app	1	0	\N	2026-06-28 06:24:37.350842+00	2026-06-28 06:24:37.105199+00
2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727	79a28492-b0d4-4098-94ce-70c4df2785cd	\N	\N	manual-test-sha-failed	demo-service:manual-sprint-4g-failed	v1.0.2-sprint-4g-failed	UNKNOWN	FAILED	\N	platformiq-demo	kind-platformiq	demo-service	demo-service-app	1	3	Manual Sprint 4G failure event test	2026-06-28 06:26:12.53169+00	2026-06-28 06:26:12.530012+00
\.


--
-- Data for Name: environments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.environments (id, service_id, name, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: error_budget_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.error_budget_statuses (id, slo_definition_id, service_id, target_percentage, allowed_failure_percentage, consumed_percentage, remaining_percentage, burn_rate, status, window_minutes, evaluated_at, created_at) FROM stdin;
9a432a47-0277-4c95-97ba-798ce8766684	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	500.0000000000284	0	5.000000000000284	EXHAUSTED	60	2026-07-11 21:10:18.324058+00	2026-07-11 21:10:18.324058+00
0991723f-b7d6-4c73-bb3f-fb7d0808bf06	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	500.0000000000284	0	5.000000000000284	EXHAUSTED	60	2026-07-11 21:24:30.35575+00	2026-07-11 21:24:30.35575+00
06468af8-eb7b-4f49-ad39-2b649a8ac84c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:00:12.35288+00	2026-07-12 09:00:12.35288+00
6de145c1-cefd-43e2-ba3a-0fa98196f6e2	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:00:47.89617+00	2026-07-12 09:00:47.89617+00
b73e16e7-ba31-41eb-98a9-408e54cbe7b0	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:01:47.896682+00	2026-07-12 09:01:47.896682+00
02cdd464-eaf8-4fb1-af2d-8f2e205f6269	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:02:47.89619+00	2026-07-12 09:02:47.89619+00
6751f95a-40c2-46d6-a8a1-83b4b23cff00	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:03:47.895791+00	2026-07-12 09:03:47.895791+00
4be928d4-2189-4868-a599-0bbf142a1bf9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:05:47.896325+00	2026-07-12 09:05:47.896325+00
193c99b0-38af-44fb-afe2-b8b3cfcecf7c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:06:48.034506+00	2026-07-12 09:06:48.034506+00
35690155-4497-43a8-aaea-bc62fe663d1b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 09:07:47.896278+00	2026-07-12 09:07:47.896278+00
ccbc8fb0-5b72-432e-a194-2eacd5583e2e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:08:47.899796+00	2026-07-12 09:08:47.899796+00
672f5d9e-bea4-4520-8d29-88cf13540a53	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:09:47.898302+00	2026-07-12 09:09:47.898302+00
3abf9629-5d9d-4b53-b36c-e9820c4d7b61	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 09:10:47.900869+00	2026-07-12 09:10:47.900869+00
470e1e34-910c-4c2b-94d9-98a3b2137798	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:11:47.944433+00	2026-07-12 09:11:47.944433+00
5f593ff3-b3a7-406c-a712-52bb6a674236	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:12:47.89699+00	2026-07-12 09:12:47.89699+00
679f8b15-139d-4c36-b212-98b84ee112ee	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:13:47.897446+00	2026-07-12 09:13:47.897446+00
4f80dff2-3470-4c26-bc7a-7bedff9f476f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:14:47.896461+00	2026-07-12 09:14:47.896461+00
aee2b9c5-1b4e-4d5c-b394-eaca0a24f91c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:17:10.489882+00	2026-07-12 09:17:10.489882+00
0e584c24-43a0-460b-90be-d54def765e56	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:18:10.046495+00	2026-07-12 09:18:10.046495+00
b9037bcc-b9dd-4964-8315-f1d57e703d4e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:19:10.062068+00	2026-07-12 09:19:10.062068+00
4f5a9992-d02c-42bd-b51a-e328653bf2ec	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 09:20:10.066138+00	2026-07-12 09:20:10.066138+00
e65a0573-57c5-4886-9053-6ba086e80b80	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:21:10.063149+00	2026-07-12 09:21:10.063149+00
9e4ace52-fea7-450a-85f7-f9f088063028	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:22:10.06382+00	2026-07-12 09:22:10.06382+00
85b8b1f8-c715-4ff4-bd26-71b73b051e46	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 09:23:10.100517+00	2026-07-12 09:23:10.100517+00
8a1dea3c-364f-4010-85aa-5eb4408052cb	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:24:10.064767+00	2026-07-12 09:24:10.064767+00
a57ebbed-46a2-418e-89b1-7869248363ec	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:25:10.063527+00	2026-07-12 09:25:10.063527+00
8cce9ceb-ca2a-4d03-8587-1ff6ca12b52a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:27:10.063935+00	2026-07-12 09:27:10.063935+00
65fa0ec4-7236-4e74-88c0-1f0a09475ad9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:28:10.063499+00	2026-07-12 09:28:10.063499+00
3b23e966-9b98-4409-b9e3-6895886e1ecd	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:29:10.063336+00	2026-07-12 09:29:10.063336+00
87323535-59c7-4f4d-ac43-dcb1109e7e9f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 09:30:10.063784+00	2026-07-12 09:30:10.063784+00
d3306640-5027-44e7-87a7-a8f4d2d7e4b1	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 09:31:10.064196+00	2026-07-12 09:31:10.064196+00
5be34787-8ded-4e4b-93ee-0e48dfd6c9c4	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:32:10.06373+00	2026-07-12 09:32:10.06373+00
23102376-61a3-46c1-8d2c-35bb9227d7ec	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:33:10.064128+00	2026-07-12 09:33:10.064128+00
4e8e3efa-8041-4bd4-b977-e853c9f178c6	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 09:34:10.063914+00	2026-07-12 09:34:10.063914+00
be202dc4-e444-43f9-9eb3-9b7a3689910d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 09:35:10.064089+00	2026-07-12 09:35:10.064089+00
ce3a3d98-5707-4d62-8870-e9f31363a409	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:38:10.063716+00	2026-07-12 09:38:10.063716+00
c896119a-42ff-44d5-a0fa-a03f63570a56	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:39:10.06443+00	2026-07-12 09:39:10.06443+00
e02ce883-2b97-4787-a423-bedcdde01deb	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:40:10.064014+00	2026-07-12 09:40:10.064014+00
b23a536b-878b-49f2-afb1-2f005318f2c9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:41:10.063418+00	2026-07-12 09:41:10.063418+00
217fc85e-0258-4b45-97a5-55d94cff6d03	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:42:10.064165+00	2026-07-12 09:42:10.064165+00
5cb81662-6ea5-4599-89e8-e6590cddce2d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 09:43:10.06414+00	2026-07-12 09:43:10.06414+00
3176bcb3-5b8b-4c12-98a1-b3bcc5dbc79d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:44:10.063859+00	2026-07-12 09:44:10.063859+00
1f6e7d2a-d4bc-4eed-9a59-139f9105549a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:45:10.064459+00	2026-07-12 09:45:10.064459+00
a609f115-a57e-454a-a227-5b1b5ce72e64	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:46:10.064066+00	2026-07-12 09:46:10.064066+00
fb900c2b-06f6-45e1-9cb0-6f6a4575c4a1	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:48:10.063966+00	2026-07-12 09:48:10.063966+00
8c7620c5-5df9-48a5-9813-e42f4fdc80fc	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:49:10.064235+00	2026-07-12 09:49:10.064235+00
ace6dd5e-35d0-424b-a346-9d62c618322a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:50:10.064076+00	2026-07-12 09:50:10.064076+00
9feb1a15-5a8d-4375-9cf1-1a2012ed154e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:51:10.065201+00	2026-07-12 09:51:10.065201+00
711ac4d4-e5d0-46c0-9972-e2646e5024bc	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:52:10.063734+00	2026-07-12 09:52:10.063734+00
63619ae5-56b0-4819-befe-34fd1f0c9f4b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:53:10.063695+00	2026-07-12 09:53:10.063695+00
cdd98366-090e-4063-b479-464bf2583615	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:54:10.063771+00	2026-07-12 09:54:10.063771+00
2cff1709-18fe-4183-ae16-25cde5f376e6	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:57:10.064543+00	2026-07-12 09:57:10.064543+00
13224f01-75df-409d-a169-239fb3b9cc67	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:58:10.064889+00	2026-07-12 09:58:10.064889+00
2ca11f74-495a-4e3b-9b29-eb09bc6c716c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 09:59:10.064436+00	2026-07-12 09:59:10.064436+00
69e7939b-4d13-4ceb-ab5a-181d880e7305	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:42:36.752942+00	2026-07-12 16:42:36.752942+00
b9988b9a-b481-4efc-8431-61326a41628d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:43:36.755871+00	2026-07-12 16:43:36.755871+00
bc57b66d-1dec-4446-8a05-22f92a0b565f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:44:36.753477+00	2026-07-12 16:44:36.753477+00
e7ac7f06-55db-4b35-a637-1e8f22426f04	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:45:36.752045+00	2026-07-12 16:45:36.752045+00
73eb4762-4531-4b55-8bb9-15fcc52b4176	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:46:36.753147+00	2026-07-12 16:46:36.753147+00
73ce7850-5ab5-4bff-8b77-25f3aa32e1ee	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:47:36.753214+00	2026-07-12 16:47:36.753214+00
287d9bb2-6fc5-4ce2-b0dc-5b66e4e2af43	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:48:36.771563+00	2026-07-12 16:48:36.771563+00
c7b91843-f3e7-44c2-9b1c-c739e7c86e6c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:49:36.757701+00	2026-07-12 16:49:36.757701+00
24c15648-235c-4579-b67b-edd27dd863e5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:50:36.756167+00	2026-07-12 16:50:36.756167+00
2721cf5e-2ec7-4811-8585-ae1098184d5b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:51:36.752592+00	2026-07-12 16:51:36.752592+00
de3e2e81-fd61-41a8-a21f-5c5666827216	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:52:36.752827+00	2026-07-12 16:52:36.752827+00
e0f1b6fc-e943-4890-9662-e1dfddc2c1e7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:53:36.752258+00	2026-07-12 16:53:36.752258+00
7c6cf42a-685b-4462-9526-29152d551405	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:54:36.752276+00	2026-07-12 16:54:36.752276+00
f246964b-d556-4706-ae4e-5459c5bf791b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:55:36.75245+00	2026-07-12 16:55:36.75245+00
fd2f3293-0066-4f92-bd81-087a6dd8a389	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:56:36.752638+00	2026-07-12 16:56:36.752638+00
fab606ab-5bda-48e3-b5f7-5c5339d8833d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:57:36.752556+00	2026-07-12 16:57:36.752556+00
2654e0f9-23fa-4d35-8faf-4a40e533e837	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:58:36.752499+00	2026-07-12 16:58:36.752499+00
039719ee-4821-4248-a60a-943886d21d56	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 16:59:36.753069+00	2026-07-12 16:59:36.753069+00
4cdeab7b-0e19-4600-80ec-4b818bd1aa96	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:00:36.752539+00	2026-07-12 17:00:36.752539+00
a85c87ac-c72b-47f1-9c25-ae6051a88b39	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:01:36.754933+00	2026-07-12 17:01:36.754933+00
dbed307f-46f0-41e4-85a7-53bd2d0e348a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:02:36.75288+00	2026-07-12 17:02:36.75288+00
3790765e-b087-47ec-8eb9-663d1a2303f5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 17:03:36.752591+00	2026-07-12 17:03:36.752591+00
942bb899-7a64-4d0f-920e-633bb40d5d7d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:04:36.756022+00	2026-07-12 17:04:36.756022+00
b9695f7e-d2cc-4e10-95f2-28b2d67574c7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 17:05:36.758305+00	2026-07-12 17:05:36.758305+00
023a5018-8c99-4935-abd0-bcbc92d6a54e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:06:36.752357+00	2026-07-12 17:06:36.752357+00
20eaef06-f9b7-4bc1-998c-8a10a0f654e9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:07:36.753788+00	2026-07-12 17:07:36.753788+00
8ae3233c-ac5f-4bbb-96c7-f635e5b8a34d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:08:36.754459+00	2026-07-12 17:08:36.754459+00
baa6dd6e-0711-4dfb-a02c-ffbd5dc55c18	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:09:36.753304+00	2026-07-12 17:09:36.753304+00
66ece2d0-a603-4056-bc45-3090572b0d60	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:10:36.762605+00	2026-07-12 17:10:36.762605+00
5bd8badc-7df8-4f31-a4b9-3e156fe40a68	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:11:36.753435+00	2026-07-12 17:11:36.753435+00
db1d435f-d7b2-4a8e-b87a-77473a1bd870	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 17:13:36.754946+00	2026-07-12 17:13:36.754946+00
555733b1-d0e2-4aac-9df0-91a13bd18fcc	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:14:36.753626+00	2026-07-12 17:14:36.753626+00
735dcd12-5e2a-410a-bda2-9c4128771c24	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:15:36.754041+00	2026-07-12 17:15:36.754041+00
e4030890-d2c5-4ffd-a006-96bf6ba05728	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:16:36.753217+00	2026-07-12 17:16:36.753217+00
75511bf3-bf55-4482-86b6-85d65c0d0589	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:17:36.752876+00	2026-07-12 17:17:36.752876+00
46bb2219-2dd7-4d1c-b7aa-8fd4aed894bc	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:18:36.753208+00	2026-07-12 17:18:36.753208+00
e258e82e-5b8a-47e9-8c19-09b9ecb3183b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:19:36.785052+00	2026-07-12 17:19:36.785052+00
2c85fdbe-caa1-4126-8d96-d2f7ce37b11d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:20:36.752894+00	2026-07-12 17:20:36.752894+00
afb446f8-a82f-463a-95e5-5c7c48226747	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:21:36.754233+00	2026-07-12 17:21:36.754233+00
a590789e-480b-4fa4-b095-83084b030ff7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:22:36.75334+00	2026-07-12 17:22:36.75334+00
d0562747-d355-481f-83dd-a5b261e7c593	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:23:36.753755+00	2026-07-12 17:23:36.753755+00
ea4c0520-036a-40a4-b25e-453e8e5aa888	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:24:36.753789+00	2026-07-12 17:24:36.753789+00
dc96b41b-8362-4b12-9943-c37309033e0d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:25:36.753249+00	2026-07-12 17:25:36.753249+00
0a30b0fb-e4f3-439f-85f5-1e79161e388a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:26:36.758579+00	2026-07-12 17:26:36.758579+00
9f1893dc-b5d8-45ee-bc6e-9940d9a00741	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:27:36.753402+00	2026-07-12 17:27:36.753402+00
34aa5e79-48ca-42e6-9f1c-e63f4ccbafa7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:28:36.753126+00	2026-07-12 17:28:36.753126+00
d201ef29-7411-43aa-afc1-93b361fb71b5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:29:36.753216+00	2026-07-12 17:29:36.753216+00
e015df8c-033c-4ac7-939c-e4f7cc6dfbd3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:30:36.753597+00	2026-07-12 17:30:36.753597+00
1c3845f3-5c35-433d-a02d-075a2a6286d8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:31:36.753654+00	2026-07-12 17:31:36.753654+00
78695197-3779-4803-bcc4-94a49ee417cd	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:32:36.754011+00	2026-07-12 17:32:36.754011+00
88b1b30c-f0ec-4db8-bcba-fbe763aec21d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:33:36.754943+00	2026-07-12 17:33:36.754943+00
10c8f95f-78c2-4e25-8fe1-c7dc58098c94	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:34:36.754888+00	2026-07-12 17:34:36.754888+00
f63a8c47-c5f4-42ab-ba63-fd5fd29d9abf	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:35:36.753547+00	2026-07-12 17:35:36.753547+00
e2b825b7-4b9a-4196-a2ce-9f7c4ea6d4b3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:36:36.753224+00	2026-07-12 17:36:36.753224+00
2e4d95cf-a904-4239-b806-614087ad0b30	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:37:36.753416+00	2026-07-12 17:37:36.753416+00
ac18deeb-92b5-4445-9b06-98ca3b8ec0bd	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:38:36.753726+00	2026-07-12 17:38:36.753726+00
d5b830bd-8f39-492e-b71b-d438cbce3c0d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:39:36.754006+00	2026-07-12 17:39:36.754006+00
c6252efb-c5ac-4695-aca8-6065e7c24842	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:40:36.763537+00	2026-07-12 17:40:36.763537+00
80710a8d-3f28-4f8b-907f-ce6330d44c78	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:41:36.753886+00	2026-07-12 17:41:36.753886+00
5d39ec5f-5e53-4c7f-9302-0bc7253f586c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 17:42:36.758652+00	2026-07-12 17:42:36.758652+00
9510c114-feff-409c-a29d-66a79c8c3a52	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 18:52:36.758911+00	2026-07-12 18:52:36.758911+00
4749289b-0556-4970-9077-eb8eb32d131d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 18:53:36.83279+00	2026-07-12 18:53:36.83279+00
59a67c96-9f73-4881-aa59-cf4c70138213	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 18:54:36.817018+00	2026-07-12 18:54:36.817018+00
89d65abd-03f7-4402-b95d-de7594f52789	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 18:55:36.758419+00	2026-07-12 18:55:36.758419+00
c5142038-bfed-4938-9752-cbf1edf79130	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 18:56:36.758059+00	2026-07-12 18:56:36.758059+00
b6c77861-5214-4fd9-854f-ee2024bdf5ea	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 18:57:36.767552+00	2026-07-12 18:57:36.767552+00
5f55dd4f-3c6f-48ae-aa60-541c28b9b055	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 18:58:36.764766+00	2026-07-12 18:58:36.764766+00
470ac655-c421-4579-8206-7c531a1de989	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 18:59:36.843672+00	2026-07-12 18:59:36.843672+00
6895a8b7-23fe-4a11-8c89-e3a275d6409f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:01:36.758759+00	2026-07-12 19:01:36.758759+00
3c81e0a2-d6d5-4ed9-81cb-73e929439806	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:02:36.758654+00	2026-07-12 19:02:36.758654+00
535c87a6-e4fb-4a73-864a-df505d32757a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 19:03:36.774351+00	2026-07-12 19:03:36.774351+00
cb994cf7-d8b7-45f3-96bd-e43555666c6e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:04:36.792747+00	2026-07-12 19:04:36.792747+00
6a08f2fe-3f24-481f-9a27-f94af18c0285	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:05:36.758607+00	2026-07-12 19:05:36.758607+00
a1d594de-1373-40e7-82fc-9e2a646be8bd	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:06:36.782921+00	2026-07-12 19:06:36.782921+00
ac24b123-e51e-45b4-9738-9528ed853ce1	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:07:36.761672+00	2026-07-12 19:07:36.761672+00
ec87a7b0-3d3a-4f7a-b5b6-882ae6b5d920	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:08:36.758252+00	2026-07-12 19:08:36.758252+00
ceb16366-6e70-461c-a3a3-c0a4a90dbf12	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:09:36.758846+00	2026-07-12 19:09:36.758846+00
e43f9de7-9abb-40a4-893d-3e1ecced86d0	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:10:36.786165+00	2026-07-12 19:10:36.786165+00
0b0def73-4fe5-4952-b39d-5cd1e4353e31	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:11:36.760591+00	2026-07-12 19:11:36.760591+00
7579e900-8969-42b6-afb3-c4b5de27da7e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:12:36.763726+00	2026-07-12 19:12:36.763726+00
3a4ba7bb-c362-4867-8181-44d01179eb4f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:13:36.759561+00	2026-07-12 19:13:36.759561+00
0f9f9a42-6a6d-4e29-a24f-59b30876744b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:14:36.758986+00	2026-07-12 19:14:36.758986+00
c1fd5684-0a15-48db-af7b-973a598b8a28	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:15:36.758303+00	2026-07-12 19:15:36.758303+00
a37f3007-ca7a-4467-9308-6ee1cc187fcf	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:16:36.772557+00	2026-07-12 19:16:36.772557+00
9152b2b6-bc04-4c88-abbf-032937496805	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:17:36.784487+00	2026-07-12 19:17:36.784487+00
48968869-1245-4f73-9375-00c58d96fb9d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:18:36.759548+00	2026-07-12 19:18:36.759548+00
0903d8d4-363e-45a9-a971-8d89403dacf7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:19:36.806962+00	2026-07-12 19:19:36.806962+00
7f45542d-5c4e-4301-ae16-9ae077ffa1a9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:20:36.761593+00	2026-07-12 19:20:36.761593+00
72f75c22-16c0-4daf-9de5-2bc5bd55f4a3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:21:36.759129+00	2026-07-12 19:21:36.759129+00
95c3ba1c-6c76-496d-9ea3-fa58de7b3ddc	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:22:36.758954+00	2026-07-12 19:22:36.758954+00
ae28f809-db19-4cda-bedb-20b5a2f94d0f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:23:36.761368+00	2026-07-12 19:23:36.761368+00
6f3a9b20-f9af-4e93-856e-50b0ab7edaac	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:24:36.798305+00	2026-07-12 19:24:36.798305+00
c5c50458-f43c-4f5d-87f8-9638d9914613	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:26:36.798865+00	2026-07-12 19:26:36.798865+00
3a187c2a-3370-413c-b082-7100808fc3e9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 19:27:36.758524+00	2026-07-12 19:27:36.758524+00
050610b4-8f6d-45ef-9261-7e296d7a8be9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:28:36.762708+00	2026-07-12 19:28:36.762708+00
07d461a1-a263-4d08-8fb6-c5349edbcc62	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:29:36.763142+00	2026-07-12 19:29:36.763142+00
83e0cb7d-8c7f-4e02-964f-94e1051a3d53	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 19:30:36.791027+00	2026-07-12 19:30:36.791027+00
d78dd848-8a66-441d-aa14-5cfd4995de03	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:31:36.830133+00	2026-07-12 19:31:36.830133+00
0365bda1-18c1-4a28-b88f-4ab7f4287ec0	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:33:36.772879+00	2026-07-12 19:33:36.772879+00
a2c75012-b89a-4ef2-b583-9808f2b183ac	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:34:36.761389+00	2026-07-12 19:34:36.761389+00
4344774b-1649-4f46-9499-1e57e9734564	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:35:36.791073+00	2026-07-12 19:35:36.791073+00
19c24030-f3c1-47b3-98f4-9de3fcc5ab54	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:36:36.759323+00	2026-07-12 19:36:36.759323+00
9dd34db6-c9b9-455c-9035-5004a979395b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:37:36.759259+00	2026-07-12 19:37:36.759259+00
f70c5064-1ab9-4d47-b3cf-ad0c9d5f15f7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:38:36.760431+00	2026-07-12 19:38:36.760431+00
cc5b7f93-9a7b-435d-8caf-279479eb5526	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:39:36.759583+00	2026-07-12 19:39:36.759583+00
89c403fd-6247-4168-8b36-26da641aaed3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:40:36.759571+00	2026-07-12 19:40:36.759571+00
4fbf957c-da30-4bb4-ad7b-711f8dd2951f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:41:36.759518+00	2026-07-12 19:41:36.759518+00
c8b55f4e-462d-4a36-a622-fef06ac8b2ef	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:42:36.774034+00	2026-07-12 19:42:36.774034+00
6c171ff2-db4c-474b-b099-044c598271b8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:43:36.759731+00	2026-07-12 19:43:36.759731+00
bdeb33db-c9e0-48e4-8807-d8e7598d62b8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:44:36.767131+00	2026-07-12 19:44:36.767131+00
9b035a92-0ce9-49b2-ae03-d78b5aec27cd	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:45:36.776266+00	2026-07-12 19:45:36.776266+00
2c4c15d2-364e-4e15-91d0-30573f7defc7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:46:36.760042+00	2026-07-12 19:46:36.760042+00
aa192da8-7a49-418c-9ae3-5eeac0685ade	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 19:47:36.764434+00	2026-07-12 19:47:36.764434+00
723180fd-c8fc-4eb1-9802-74e12111d2f8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:48:36.76201+00	2026-07-12 19:48:36.76201+00
21173b84-e36b-4168-8b48-d2234ad9fede	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	1.4210854715202812e-11	100	1.4210854715202812e-13	HEALTHY	60	2026-07-12 19:49:36.815966+00	2026-07-12 19:49:36.815966+00
c23e9616-96b2-43f8-9fbd-8fcb98cf0f6e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:50:36.760746+00	2026-07-12 19:50:36.760746+00
07840636-655a-4f04-84bc-2c39dc377c41	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:51:36.762094+00	2026-07-12 19:51:36.762094+00
589bc9fd-2b58-4b4b-9229-1097bfe70fc9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:52:36.761021+00	2026-07-12 19:52:36.761021+00
09882ee4-366e-415d-b93e-8c2fd3683c52	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	99.9	0.09999999999999432	0	100	0	HEALTHY	60	2026-07-12 19:54:36.760226+00	2026-07-12 19:54:36.760226+00
\.


--
-- Data for Name: event_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_records (id, event_id, event_type, topic, schema_version, correlation_id, service_id, environment, payload, processing_status, processed_at, created_at, "timestamp", raw_event, processing_error) FROM stdin;
c21e9310-7019-4e07-84c2-1b3bf5221a4e	evt_78dec550-ea50-42ef-a18b-62333eedd241	PIPELINE_STARTED	pipeline.events	1.0	manual-test-001	manual-service	local	{"source": "manual-test", "message": "Testing transactional outbox writer"}	PROCESSED	2026-06-28 10:05:02.009746+00	2026-06-28 10:05:02.004077+00	2026-06-27 18:54:19.855849+00	{"event_id": "evt_78dec550-ea50-42ef-a18b-62333eedd241", "event_type": "PIPELINE_STARTED", "schema_version": "1.0", "correlation_id": "manual-test-001", "service_id": "manual-service", "environment": "local", "timestamp": "2026-06-27T18:54:19.855849+00:00", "payload": {"source": "manual-test", "message": "Testing transactional outbox writer"}}	\N
7d890ea1-345e-4c7e-89e0-25e656cc9934	evt_5608218d-3d09-4834-a04c-27f261223063	PIPELINE_STARTED	pipeline.events	1.0	manual-test-4e-001	manual-service	local	{"source": "manual-test", "message": "Testing Sprint 4E outbox publisher"}	PROCESSED	2026-06-28 10:05:02.034307+00	2026-06-28 10:05:02.032691+00	2026-06-27 19:34:56.762734+00	{"event_id": "evt_5608218d-3d09-4834-a04c-27f261223063", "event_type": "PIPELINE_STARTED", "schema_version": "1.0", "correlation_id": "manual-test-4e-001", "service_id": "manual-service", "environment": "local", "timestamp": "2026-06-27T19:34:56.762734+00:00", "payload": {"source": "manual-test", "message": "Testing Sprint 4E outbox publisher"}}	\N
f092ada2-b029-440f-84b5-24f91f2fd1c9	evt_a97c04e6-2730-46cc-9dce-9ae14d739ba7	KUBERNETES_DEPLOYMENT_HEALTHY	kubernetes.events	1.0	payment-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "payment-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PROCESSED	2026-06-28 10:05:02.044827+00	2026-06-28 10:05:02.043213+00	2026-06-28 09:39:15.528517+00	{"event_id": "evt_a97c04e6-2730-46cc-9dce-9ae14d739ba7", "event_type": "KUBERNETES_DEPLOYMENT_HEALTHY", "schema_version": "1.0", "correlation_id": "payment-service", "service_id": null, "environment": "staging", "timestamp": "2026-06-28T09:39:15.528517+00:00", "payload": {"namespace": "platformiq-demo", "deployment_name": "payment-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}}	\N
91eeecb6-b71b-41fe-b139-92db5e296f53	evt_88153961-4361-4c2a-9afc-992ac00afe7a	KUBERNETES_DEPLOYMENT_HEALTHY	kubernetes.events	1.0	payment-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "payment-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PROCESSED	2026-06-28 10:05:02.055895+00	2026-06-28 10:05:02.054116+00	2026-06-28 09:59:05.015218+00	{"event_id": "evt_88153961-4361-4c2a-9afc-992ac00afe7a", "event_type": "KUBERNETES_DEPLOYMENT_HEALTHY", "schema_version": "1.0", "correlation_id": "payment-service", "service_id": null, "environment": "staging", "timestamp": "2026-06-28T09:59:05.015218+00:00", "payload": {"namespace": "platformiq-demo", "deployment_name": "payment-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}}	\N
92e69293-1c3f-4275-bb92-3a364bfec56c	evt_5c030e21-deb8-4d60-aa95-53251b50a6b6	KUBERNETES_DEPLOYMENT_HEALTHY	kubernetes.events	1.0	inventory-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "inventory-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PROCESSED	2026-06-28 10:05:02.067775+00	2026-06-28 10:05:02.06597+00	2026-06-28 09:39:15.528505+00	{"event_id": "evt_5c030e21-deb8-4d60-aa95-53251b50a6b6", "event_type": "KUBERNETES_DEPLOYMENT_HEALTHY", "schema_version": "1.0", "correlation_id": "inventory-service", "service_id": null, "environment": "staging", "timestamp": "2026-06-28T09:39:15.528505+00:00", "payload": {"namespace": "platformiq-demo", "deployment_name": "inventory-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}}	\N
d013ae04-daba-4596-83b0-2124a7a5e798	evt_561c2b14-f154-4dcc-a4e0-56e4921dc869	KUBERNETES_DEPLOYMENT_HEALTHY	kubernetes.events	1.0	order-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "order-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PROCESSED	2026-06-28 10:05:02.079382+00	2026-06-28 10:05:02.077165+00	2026-06-28 09:39:15.528512+00	{"event_id": "evt_561c2b14-f154-4dcc-a4e0-56e4921dc869", "event_type": "KUBERNETES_DEPLOYMENT_HEALTHY", "schema_version": "1.0", "correlation_id": "order-service", "service_id": null, "environment": "staging", "timestamp": "2026-06-28T09:39:15.528512+00:00", "payload": {"namespace": "platformiq-demo", "deployment_name": "order-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}}	\N
a27e1f20-0ae1-4838-bec5-83361dbd8032	evt_034a5fb8-5f45-4d0c-a26d-8bc31e20d7b2	KUBERNETES_DEPLOYMENT_HEALTHY	kubernetes.events	1.0	postgres	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "postgres", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PROCESSED	2026-06-28 10:05:02.089886+00	2026-06-28 10:05:02.088275+00	2026-06-28 09:39:15.528522+00	{"event_id": "evt_034a5fb8-5f45-4d0c-a26d-8bc31e20d7b2", "event_type": "KUBERNETES_DEPLOYMENT_HEALTHY", "schema_version": "1.0", "correlation_id": "postgres", "service_id": null, "environment": "staging", "timestamp": "2026-06-28T09:39:15.528522+00:00", "payload": {"namespace": "platformiq-demo", "deployment_name": "postgres", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}}	\N
f6ef8a31-b12c-42ef-94da-25a4143aa965	evt_66d85b6e-3dd3-4fee-9b6e-dd3ab16bdce1	KUBERNETES_DEPLOYMENT_HEALTHY	kubernetes.events	1.0	inventory-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "inventory-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PROCESSED	2026-06-28 10:05:02.100262+00	2026-06-28 10:05:02.099015+00	2026-06-28 09:59:05.015188+00	{"event_id": "evt_66d85b6e-3dd3-4fee-9b6e-dd3ab16bdce1", "event_type": "KUBERNETES_DEPLOYMENT_HEALTHY", "schema_version": "1.0", "correlation_id": "inventory-service", "service_id": null, "environment": "staging", "timestamp": "2026-06-28T09:59:05.015188+00:00", "payload": {"namespace": "platformiq-demo", "deployment_name": "inventory-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}}	\N
f95dc33d-c539-41dd-8aff-53dfe2ede50a	evt_87eea227-53c4-4007-a306-7d4dc4997520	KUBERNETES_DEPLOYMENT_HEALTHY	kubernetes.events	1.0	order-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "order-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PROCESSED	2026-06-28 10:05:02.113071+00	2026-06-28 10:05:02.110342+00	2026-06-28 09:59:05.015205+00	{"event_id": "evt_87eea227-53c4-4007-a306-7d4dc4997520", "event_type": "KUBERNETES_DEPLOYMENT_HEALTHY", "schema_version": "1.0", "correlation_id": "order-service", "service_id": null, "environment": "staging", "timestamp": "2026-06-28T09:59:05.015205+00:00", "payload": {"namespace": "platformiq-demo", "deployment_name": "order-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}}	\N
2d46aa67-1d95-4764-8689-fb6060ec4ebc	evt_b125770f-2bd5-4564-b139-76925c7de230	KUBERNETES_DEPLOYMENT_HEALTHY	kubernetes.events	1.0	postgres	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "postgres", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PROCESSED	2026-06-28 10:05:02.12536+00	2026-06-28 10:05:02.123572+00	2026-06-28 09:59:05.01523+00	{"event_id": "evt_b125770f-2bd5-4564-b139-76925c7de230", "event_type": "KUBERNETES_DEPLOYMENT_HEALTHY", "schema_version": "1.0", "correlation_id": "postgres", "service_id": null, "environment": "staging", "timestamp": "2026-06-28T09:59:05.015230+00:00", "payload": {"namespace": "platformiq-demo", "deployment_name": "postgres", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}}	\N
7f924376-55c4-40a4-80c3-7ff367c18255	evt_45f17721-a3a6-4a05-bf56-f8629b490f34	DEPLOYMENT_STARTED	deployment.events	1.0	2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"image_tag": "demo-service:manual-sprint-4g-failed", "namespace": "platformiq-demo", "cluster_name": "kind-platformiq", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "pipeline_run_id": null, "deployment_version": "v1.0.2-sprint-4g-failed", "argo_application_name": "demo-service-app"}	PROCESSED	2026-06-28 10:05:02.137327+00	2026-06-28 10:05:02.135393+00	2026-06-28 06:26:12.537474+00	{"event_id": "evt_45f17721-a3a6-4a05-bf56-f8629b490f34", "event_type": "DEPLOYMENT_STARTED", "schema_version": "1.0", "correlation_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "environment": "staging", "timestamp": "2026-06-28T06:26:12.537474+00:00", "payload": {"image_tag": "demo-service:manual-sprint-4g-failed", "namespace": "platformiq-demo", "cluster_name": "kind-platformiq", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "pipeline_run_id": null, "deployment_version": "v1.0.2-sprint-4g-failed", "argo_application_name": "demo-service-app"}}	\N
44ba8d2c-f308-486f-a1d9-984c1300c69d	evt_65b9aefa-9106-4db0-a227-283fa10c84b4	DEPLOYMENT_FAILED	deployment.events	1.0	2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"image_tag": "demo-service:manual-sprint-4g-failed", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "failure_reason": "Manual Sprint 4G failure event test", "pipeline_run_id": null, "argo_sync_status": "UNKNOWN", "kubernetes_rollout_status": "FAILED"}	PROCESSED	2026-06-28 10:05:02.149471+00	2026-06-28 10:05:02.147451+00	2026-06-28 06:26:54.119615+00	{"event_id": "evt_65b9aefa-9106-4db0-a227-283fa10c84b4", "event_type": "DEPLOYMENT_FAILED", "schema_version": "1.0", "correlation_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "environment": "staging", "timestamp": "2026-06-28T06:26:54.119615+00:00", "payload": {"image_tag": "demo-service:manual-sprint-4g-failed", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "failure_reason": "Manual Sprint 4G failure event test", "pipeline_run_id": null, "argo_sync_status": "UNKNOWN", "kubernetes_rollout_status": "FAILED"}}	\N
8e0bbabf-8ffe-4b79-91a2-02a6a2e0eb0e	evt_4cf89470-df0d-4ac7-8731-78ce90b88bae	DEPLOYMENT_STARTED	deployment.events	1.0	dacd606c-4046-4466-a268-fcae7f6d3940	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"image_tag": "demo-service:manual-sprint-4g-2", "namespace": "platformiq-demo", "cluster_name": "kind-platformiq", "deployment_id": "dacd606c-4046-4466-a268-fcae7f6d3940", "pipeline_run_id": null, "deployment_version": "v1.0.1-sprint-4g", "argo_application_name": "demo-service-app"}	PROCESSED	2026-06-28 10:05:02.160215+00	2026-06-28 10:05:02.158828+00	2026-06-28 06:24:37.366734+00	{"event_id": "evt_4cf89470-df0d-4ac7-8731-78ce90b88bae", "event_type": "DEPLOYMENT_STARTED", "schema_version": "1.0", "correlation_id": "dacd606c-4046-4466-a268-fcae7f6d3940", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "environment": "staging", "timestamp": "2026-06-28T06:24:37.366734+00:00", "payload": {"image_tag": "demo-service:manual-sprint-4g-2", "namespace": "platformiq-demo", "cluster_name": "kind-platformiq", "deployment_id": "dacd606c-4046-4466-a268-fcae7f6d3940", "pipeline_run_id": null, "deployment_version": "v1.0.1-sprint-4g", "argo_application_name": "demo-service-app"}}	\N
dd6a12df-68c0-419e-a31f-285cf87d18d3	evt_50f841bb-2d13-4a28-810e-0a8e2b530907	DEPLOYMENT_COMPLETED	deployment.events	1.0	dacd606c-4046-4466-a268-fcae7f6d3940	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"image_tag": "demo-service:manual-sprint-4g-2", "pod_count": 1, "deployment_id": "dacd606c-4046-4466-a268-fcae7f6d3940", "restart_count": 0, "pipeline_run_id": null, "argo_sync_status": "SYNCED", "kubernetes_rollout_status": "HEALTHY"}	PROCESSED	2026-06-28 10:05:02.171171+00	2026-06-28 10:05:02.169416+00	2026-06-28 06:25:31.902463+00	{"event_id": "evt_50f841bb-2d13-4a28-810e-0a8e2b530907", "event_type": "DEPLOYMENT_COMPLETED", "schema_version": "1.0", "correlation_id": "dacd606c-4046-4466-a268-fcae7f6d3940", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "environment": "staging", "timestamp": "2026-06-28T06:25:31.902463+00:00", "payload": {"image_tag": "demo-service:manual-sprint-4g-2", "pod_count": 1, "deployment_id": "dacd606c-4046-4466-a268-fcae7f6d3940", "restart_count": 0, "pipeline_run_id": null, "argo_sync_status": "SYNCED", "kubernetes_rollout_status": "HEALTHY"}}	\N
9d871cdb-7d81-4801-a67f-69dd0d18c3f0	evt_duplicate_test_001	KUBERNETES_DEPLOYMENT_UNHEALTHY	kubernetes.events	1.0	release_duplicate_test_001	payment-service	staging	{"namespace": "platformiq-demo", "deployment_name": "payment-service", "desired_replicas": 1, "available_replicas": 0}	PROCESSED	2026-06-28 11:28:31.016566+00	2026-06-28 11:28:30.979953+00	2026-06-28 10:30:00+00	{"event_id": "evt_duplicate_test_001", "event_type": "KUBERNETES_DEPLOYMENT_UNHEALTHY", "schema_version": "1.0", "correlation_id": "release_duplicate_test_001", "service_id": "payment-service", "environment": "staging", "timestamp": "2026-06-28T10:30:00Z", "payload": {"namespace": "platformiq-demo", "deployment_name": "payment-service", "desired_replicas": 1, "available_replicas": 0}}	\N
4dffffd2-c744-4caf-b849-e676b7fa5666	evt_22f17a71-9816-46d2-b4f8-72e31d19e608	HIGH_ERROR_RATE	telemetry.alerts	1.0	9ef922ed-b91d-4fe0-8306-92334f9abd75	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75"}	PROCESSED	2026-07-04 19:46:36.349423+00	2026-07-04 19:46:36.339863+00	2026-07-04 19:29:14.843518+00	{"event_id": "evt_22f17a71-9816-46d2-b4f8-72e31d19e608", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "correlation_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:29:14.843518+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75"}}	\N
8349d2f8-ed0b-4f8c-9ebd-28818fa30e4c	evt_1509c37e-a1e0-4915-9702-fe5ad041dd6b	HIGH_LATENCY	telemetry.alerts	1.0	9ef922ed-b91d-4fe0-8306-92334f9abd75	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75"}	PROCESSED	2026-07-04 19:46:36.370998+00	2026-07-04 19:46:36.369138+00	2026-07-04 19:29:14.843595+00	{"event_id": "evt_1509c37e-a1e0-4915-9702-fe5ad041dd6b", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "correlation_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:29:14.843595+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75"}}	\N
22514046-3edf-4752-9952-3676e4dad135	evt_171a28fa-107f-4ab2-8485-1ef6ae68d39c	POD_RESTART_SPIKE	telemetry.alerts	1.0	9ef922ed-b91d-4fe0-8306-92334f9abd75	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75"}	PROCESSED	2026-07-04 19:46:36.379715+00	2026-07-04 19:46:36.378497+00	2026-07-04 19:29:14.843615+00	{"event_id": "evt_171a28fa-107f-4ab2-8485-1ef6ae68d39c", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "correlation_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:29:14.843615+00:00", "payload": {"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75"}}	\N
c77892cf-1633-4369-b38c-c5e0bd91c494	evt_45146324-7eed-4ef4-ac30-a933f25bba25	SERVICE_DEGRADED	telemetry.alerts	1.0	9ef922ed-b91d-4fe0-8306-92334f9abd75	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75"}	PROCESSED	2026-07-04 19:46:36.390482+00	2026-07-04 19:46:36.389153+00	2026-07-04 19:29:14.84363+00	{"event_id": "evt_45146324-7eed-4ef4-ac30-a933f25bba25", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "correlation_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:29:14.843630+00:00", "payload": {"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "9ef922ed-b91d-4fe0-8306-92334f9abd75"}}	\N
1a5a3bca-d775-4d3f-921a-2ac4ed44d022	evt_f6609b5b-4532-410a-abe8-290a97998e84	HIGH_ERROR_RATE	telemetry.alerts	1.0	30727914-9514-44b4-b61a-a159dfb7d5fe	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "30727914-9514-44b4-b61a-a159dfb7d5fe"}	PROCESSED	2026-07-04 19:46:36.400291+00	2026-07-04 19:46:36.399199+00	2026-07-04 19:30:36.49195+00	{"event_id": "evt_f6609b5b-4532-410a-abe8-290a97998e84", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "correlation_id": "30727914-9514-44b4-b61a-a159dfb7d5fe", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:30:36.491950+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "30727914-9514-44b4-b61a-a159dfb7d5fe"}}	\N
2cbb0e3e-b3e9-4d5d-960d-844789bfe6d1	evt_366c4a60-1e52-473a-ba1d-91ad04bb27b9	HIGH_LATENCY	telemetry.alerts	1.0	30727914-9514-44b4-b61a-a159dfb7d5fe	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "30727914-9514-44b4-b61a-a159dfb7d5fe"}	PROCESSED	2026-07-04 19:46:36.409668+00	2026-07-04 19:46:36.408555+00	2026-07-04 19:30:36.493243+00	{"event_id": "evt_366c4a60-1e52-473a-ba1d-91ad04bb27b9", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "correlation_id": "30727914-9514-44b4-b61a-a159dfb7d5fe", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:30:36.493243+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "30727914-9514-44b4-b61a-a159dfb7d5fe"}}	\N
56243f0f-3d26-4862-8b8e-e2a18db3be4c	evt_bb35a837-7da2-40d1-b79d-4b724e8b67d4	POD_RESTART_SPIKE	telemetry.alerts	1.0	30727914-9514-44b4-b61a-a159dfb7d5fe	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "30727914-9514-44b4-b61a-a159dfb7d5fe"}	PROCESSED	2026-07-04 19:46:36.419241+00	2026-07-04 19:46:36.418002+00	2026-07-04 19:30:36.493283+00	{"event_id": "evt_bb35a837-7da2-40d1-b79d-4b724e8b67d4", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "correlation_id": "30727914-9514-44b4-b61a-a159dfb7d5fe", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:30:36.493283+00:00", "payload": {"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "30727914-9514-44b4-b61a-a159dfb7d5fe"}}	\N
90b8c1d0-aa77-4cdb-a20d-0007e731d5f6	evt_902de7ef-4fce-4aba-8157-f242f499a0d2	SERVICE_DEGRADED	telemetry.alerts	1.0	30727914-9514-44b4-b61a-a159dfb7d5fe	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "30727914-9514-44b4-b61a-a159dfb7d5fe"}	PROCESSED	2026-07-04 19:46:36.428896+00	2026-07-04 19:46:36.427974+00	2026-07-04 19:30:36.493317+00	{"event_id": "evt_902de7ef-4fce-4aba-8157-f242f499a0d2", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "correlation_id": "30727914-9514-44b4-b61a-a159dfb7d5fe", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:30:36.493317+00:00", "payload": {"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "30727914-9514-44b4-b61a-a159dfb7d5fe"}}	\N
03675420-0bd6-485b-a907-325e8ce0fdd9	evt_d7001190-34fb-4972-927e-1bcaff4a6676	HIGH_ERROR_RATE	telemetry.alerts	1.0	cb20df76-b631-42d3-8bad-38e346a01425	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "cb20df76-b631-42d3-8bad-38e346a01425"}	PROCESSED	2026-07-04 19:46:36.437599+00	2026-07-04 19:46:36.436946+00	2026-07-04 19:34:54.377021+00	{"event_id": "evt_d7001190-34fb-4972-927e-1bcaff4a6676", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "correlation_id": "cb20df76-b631-42d3-8bad-38e346a01425", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:34:54.377021+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "cb20df76-b631-42d3-8bad-38e346a01425"}}	\N
f9ed032b-1697-4e20-8dd0-081ce347bbe7	evt_a8039550-80f8-4691-b073-f4a03384ddac	HIGH_LATENCY	telemetry.alerts	1.0	cb20df76-b631-42d3-8bad-38e346a01425	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "cb20df76-b631-42d3-8bad-38e346a01425"}	PROCESSED	2026-07-04 19:46:36.4463+00	2026-07-04 19:46:36.445543+00	2026-07-04 19:34:54.378644+00	{"event_id": "evt_a8039550-80f8-4691-b073-f4a03384ddac", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "correlation_id": "cb20df76-b631-42d3-8bad-38e346a01425", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:34:54.378644+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "cb20df76-b631-42d3-8bad-38e346a01425"}}	\N
5105d2aa-1eb3-4389-b0f1-ffe3beb9101d	evt_f6416822-246f-4359-bfb4-b1150c0fd2de	POD_RESTART_SPIKE	telemetry.alerts	1.0	cb20df76-b631-42d3-8bad-38e346a01425	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "cb20df76-b631-42d3-8bad-38e346a01425"}	PROCESSED	2026-07-04 19:46:36.454979+00	2026-07-04 19:46:36.454253+00	2026-07-04 19:34:54.378697+00	{"event_id": "evt_f6416822-246f-4359-bfb4-b1150c0fd2de", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "correlation_id": "cb20df76-b631-42d3-8bad-38e346a01425", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:34:54.378697+00:00", "payload": {"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "cb20df76-b631-42d3-8bad-38e346a01425"}}	\N
5f6c35f3-2f10-45f5-b910-83e3a067caad	evt_8203d9a3-fe40-406b-a92d-f667a280bc0a	SERVICE_DEGRADED	telemetry.alerts	1.0	cb20df76-b631-42d3-8bad-38e346a01425	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "cb20df76-b631-42d3-8bad-38e346a01425"}	PROCESSED	2026-07-04 19:46:36.464152+00	2026-07-04 19:46:36.46291+00	2026-07-04 19:34:54.378727+00	{"event_id": "evt_8203d9a3-fe40-406b-a92d-f667a280bc0a", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "correlation_id": "cb20df76-b631-42d3-8bad-38e346a01425", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T19:34:54.378727+00:00", "payload": {"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "cb20df76-b631-42d3-8bad-38e346a01425"}}	\N
780c49ce-7f57-443f-9ff6-5497859bdcc7	evt_b5317110-e826-41e2-97ea-2369e0009131	HIGH_ERROR_RATE	telemetry.alerts	1.0	beaf4b73-f649-4a8a-89ef-03a90200d26d	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d"}	PROCESSED	2026-07-04 20:00:25.720232+00	2026-07-04 20:00:25.707218+00	2026-07-04 20:00:17.956504+00	{"event_id": "evt_b5317110-e826-41e2-97ea-2369e0009131", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "correlation_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T20:00:17.956504+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d"}}	\N
e7d4a759-b90b-456a-ad56-af0a8e687e31	evt_32656963-db43-4d5d-95d3-c022e86cb01a	HIGH_LATENCY	telemetry.alerts	1.0	beaf4b73-f649-4a8a-89ef-03a90200d26d	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d"}	PROCESSED	2026-07-04 20:00:25.743503+00	2026-07-04 20:00:25.741404+00	2026-07-04 20:00:17.956626+00	{"event_id": "evt_32656963-db43-4d5d-95d3-c022e86cb01a", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "correlation_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T20:00:17.956626+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d"}}	\N
ec7cd20a-0387-47e8-a678-db10f2de24df	evt_efcaf642-c163-4129-819f-5206e082f018	POD_RESTART_SPIKE	telemetry.alerts	1.0	beaf4b73-f649-4a8a-89ef-03a90200d26d	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d"}	PROCESSED	2026-07-04 20:00:25.754265+00	2026-07-04 20:00:25.752619+00	2026-07-04 20:00:17.956658+00	{"event_id": "evt_efcaf642-c163-4129-819f-5206e082f018", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "correlation_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T20:00:17.956658+00:00", "payload": {"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d"}}	\N
ba4b9820-87df-42de-83bb-a8d921affe34	evt_980e6f7e-de47-448b-b5cc-22e41d0f866c	SERVICE_DEGRADED	telemetry.alerts	1.0	beaf4b73-f649-4a8a-89ef-03a90200d26d	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d"}	PROCESSED	2026-07-04 20:00:25.765153+00	2026-07-04 20:00:25.763725+00	2026-07-04 20:00:17.956678+00	{"event_id": "evt_980e6f7e-de47-448b-b5cc-22e41d0f866c", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "correlation_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T20:00:17.956678+00:00", "payload": {"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "beaf4b73-f649-4a8a-89ef-03a90200d26d"}}	\N
faa6b49a-a28a-4dda-baf9-179cd8a176b3	evt_f5ec3291-c1c5-426f-b2e1-b60de99d7074	ERROR_BUDGET_EXHAUSTED	telemetry.alerts	1.0	79a28492-b0d4-4098-94ce-70c4df2785cd:staging:AVAILABILITY	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"source": "platformiq-reliability", "severity": "HIGH", "burn_rate": 5.000000000000284, "rapid_burn": true, "is_breached": true, "metric_type": "AVAILABILITY", "service_name": "demo-service", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "measurement_id": "01917c13-827f-4224-a5a1-cb30fc86fcdc", "window_minutes": 60, "threshold_value": 99.9, "triggered_value": 99.5, "slo_definition_id": "4b572d35-cb52-47f2-9b91-f98577ade93a", "error_budget_status": "EXHAUSTED", "reliability_alert_id": "d0391e45-448f-45b0-b978-be94302328b7", "error_budget_consumed": 500.0000000000284, "error_budget_remaining": 0.0}	PROCESSED	2026-07-11 21:29:10.361392+00	2026-07-11 21:29:10.339958+00	2026-07-11 21:10:18.381041+00	{"event_id": "evt_f5ec3291-c1c5-426f-b2e1-b60de99d7074", "event_type": "ERROR_BUDGET_EXHAUSTED", "schema_version": "1.0", "correlation_id": "79a28492-b0d4-4098-94ce-70c4df2785cd:staging:AVAILABILITY", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "environment": "staging", "timestamp": "2026-07-11T21:10:18.381041+00:00", "payload": {"source": "platformiq-reliability", "severity": "HIGH", "burn_rate": 5.000000000000284, "rapid_burn": true, "is_breached": true, "metric_type": "AVAILABILITY", "service_name": "demo-service", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "measurement_id": "01917c13-827f-4224-a5a1-cb30fc86fcdc", "window_minutes": 60, "threshold_value": 99.9, "triggered_value": 99.5, "slo_definition_id": "4b572d35-cb52-47f2-9b91-f98577ade93a", "error_budget_status": "EXHAUSTED", "reliability_alert_id": "d0391e45-448f-45b0-b978-be94302328b7", "error_budget_consumed": 500.0000000000284, "error_budget_remaining": 0.0}}	\N
\.


--
-- Data for Name: incident_alert_links; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incident_alert_links (id, incident_id, reliability_alert_id, linked_at, is_triggering_alert) FROM stdin;
\.


--
-- Data for Name: incident_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incident_assignments (id, incident_id, assigned_to_user_id, assigned_by_user_id, assignment_note, assigned_at, unassigned_at, is_active) FROM stdin;
\.


--
-- Data for Name: incident_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incident_comments (id, incident_id, author_user_id, comment, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: incident_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incident_events (id, incident_id, event_type, message, metadata, created_at) FROM stdin;
d0c25e87-dfcc-4069-8722-8faa0d27bcee	3fca917c-04e0-4db4-adfb-87e2588dcb09	INCIDENT_CREATED	Incident created from telemetry alert.	{"event_id": "evt_dcef17fb-1dd6-40c9-a9e2-e693a04978c6", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T21:06:16.892573+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}}	2026-07-04 21:06:16.899066
187d0076-5ada-488f-953a-efe77d28afa3	3fca917c-04e0-4db4-adfb-87e2588dcb09	INCIDENT_ALERT_ATTACHED	Additional telemetry alert attached to existing incident.	{"event_id": "evt_bad15fe8-a1cc-443d-80a6-ae98be2f83a5", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T21:06:16.911209+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}}	2026-07-04 21:06:16.911818
5511eb1b-705a-4ba6-ac8d-dd3acc7f8b4f	3fca917c-04e0-4db4-adfb-87e2588dcb09	INCIDENT_ALERT_ATTACHED	Additional telemetry alert attached to existing incident.	{"event_id": "evt_bb5a0876-b512-44b7-980c-4b4fc9b1baab", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T21:06:16.916696+00:00", "payload": {"pod_restart_count": 6, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}}	2026-07-04 21:06:16.917355
0e0f55f1-1799-4746-a518-ce8b7fcbf2c2	3fca917c-04e0-4db4-adfb-87e2588dcb09	INCIDENT_ALERT_ATTACHED	Additional telemetry alert attached to existing incident.	{"event_id": "evt_fc9763db-c133-4d21-bc3f-4770c1239e56", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "severity": "MEDIUM", "correlation_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-04T21:06:16.919517+00:00", "payload": {"available_replicas": 1, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "21aaf1ee-dff3-4463-8fd1-65cbf1853f51"}}	2026-07-04 21:06:16.920028
0e637306-3c2d-4a31-a87d-a998cdcbaf04	3fca917c-04e0-4db4-adfb-87e2588dcb09	INCIDENT_ACKNOWLEDGED	Incident acknowledged	{}	2026-07-04 21:12:29.934952
65f8b530-5beb-408f-9fd8-8ca26b2f1c23	3fca917c-04e0-4db4-adfb-87e2588dcb09	INCIDENT_RESOLVED	Incident resolved	{}	2026-07-04 21:12:36.234452
4dc85f9a-85f9-4e52-8cab-9ae5de7f7f35	a7db2d9c-c7a3-42df-90ea-d848ba238f7b	INCIDENT_CREATED	Incident created from telemetry alert.	{"event_id": "evt_7fd7dd56-e98d-4444-9826-98fa63749f99", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "79a37362-9300-45a1-b2ef-d7ec3794764e", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:37:37.404946+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "79a37362-9300-45a1-b2ef-d7ec3794764e"}}	2026-07-05 16:37:37.414205
8c681b5b-80c4-4b25-bf5e-66f740d2d754	a7db2d9c-c7a3-42df-90ea-d848ba238f7b	INCIDENT_ALERT_ATTACHED	Additional telemetry alert attached to existing incident.	{"event_id": "evt_92a960d9-feac-41de-84c8-7dd59f68031d", "event_type": "SERVICE_DOWN", "schema_version": "1.0", "severity": "CRITICAL", "correlation_id": "79a37362-9300-45a1-b2ef-d7ec3794764e", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:37:37.427059+00:00", "payload": {"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "79a37362-9300-45a1-b2ef-d7ec3794764e"}}	2026-07-05 16:37:37.428717
2dbd276f-2266-48e8-beca-a82bce5a5186	1c8430b7-3fba-4f49-8e84-acdac4da8e5d	INCIDENT_CREATED	Incident created from telemetry alert.	{"event_id": "evt_fe913dba-05b3-4960-af9e-8add89c2b370", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:38:30.526414+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda"}}	2026-07-05 16:38:30.527683
2504bc00-247f-4066-94b0-0a9bcfea278c	1c8430b7-3fba-4f49-8e84-acdac4da8e5d	INCIDENT_ALERT_ATTACHED	Additional telemetry alert attached to existing incident.	{"event_id": "evt_3ec08cd2-b6f1-49f0-b1fb-fde2d7f4cbc9", "event_type": "SERVICE_DOWN", "schema_version": "1.0", "severity": "CRITICAL", "correlation_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:38:30.532061+00:00", "payload": {"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda"}}	2026-07-05 16:38:30.533072
67f2b56a-700e-49d3-83f9-349733bfbaea	caef74be-7b67-4764-9b93-71a6aea5edeb	INCIDENT_CREATED	Incident created from telemetry alert.	{"event_id": "evt_9f705e94-54f7-4eed-b990-301dcf61e477", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "a0a4d25b-012f-40dd-801a-9e059380cac1", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:40:43.333462+00:00", "payload": {"pod_restart_count": 7, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "a0a4d25b-012f-40dd-801a-9e059380cac1"}}	2026-07-05 16:40:43.335865
7a825db2-5b18-4b63-a83d-a81f27cdf558	caef74be-7b67-4764-9b93-71a6aea5edeb	INCIDENT_ALERT_ATTACHED	Additional telemetry alert attached to existing incident.	{"event_id": "evt_ae0d0a2b-4435-4e6f-89cb-39c92c91d411", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "severity": "MEDIUM", "correlation_id": "a0a4d25b-012f-40dd-801a-9e059380cac1", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T16:40:43.340718+00:00", "payload": {"available_replicas": 2, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "a0a4d25b-012f-40dd-801a-9e059380cac1"}}	2026-07-05 16:40:43.342209
046bd781-5630-489a-83a3-50e63d58938e	f39c9a20-6fe5-46f8-af80-220082025abf	INCIDENT_CREATED	Incident created from telemetry alert.	{"event_id": "evt_eb37f920-f5b0-4bc1-aef2-3dfcc17cfeae", "event_type": "HIGH_LATENCY", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "2ae251be-c681-4f94-82d7-ba1919f31981", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:06:29.700837+00:00", "payload": {"latency_ms": 2300.0, "threshold_ms": 1000, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "2ae251be-c681-4f94-82d7-ba1919f31981"}}	2026-07-05 17:06:29.709137
2efea15c-0605-42a5-a1f3-f1f399375c04	f39c9a20-6fe5-46f8-af80-220082025abf	INCIDENT_ALERT_ATTACHED	Additional telemetry alert attached to existing incident.	{"event_id": "evt_76056b05-df98-4deb-ba70-d6be16fad31a", "event_type": "SERVICE_DOWN", "schema_version": "1.0", "severity": "CRITICAL", "correlation_id": "2ae251be-c681-4f94-82d7-ba1919f31981", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:06:29.722990+00:00", "payload": {"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "2ae251be-c681-4f94-82d7-ba1919f31981"}}	2026-07-05 17:06:29.724107
040a9735-27f2-4670-951c-9650b00bf7cc	f0fff6a0-aa8e-4bd4-be53-4af20d913a8d	INCIDENT_CREATED	Incident created from telemetry alert.	{"event_id": "evt_893dc7b6-a556-4997-950a-2072f849eea8", "event_type": "HIGH_ERROR_RATE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "a6522068-03c8-46cd-93a4-741b1db36b7f", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:07:35.278439+00:00", "payload": {"error_rate": 18.4, "threshold_percent": 5, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "a6522068-03c8-46cd-93a4-741b1db36b7f"}}	2026-07-05 17:07:35.279875
29b6bccf-4e8d-4bc7-83e5-7a92dd66bfbc	f0fff6a0-aa8e-4bd4-be53-4af20d913a8d	INCIDENT_ALERT_ATTACHED	Additional telemetry alert attached to existing incident.	{"event_id": "evt_f765ba6c-3acf-465f-aee6-28b45fe33ef0", "event_type": "SERVICE_DOWN", "schema_version": "1.0", "severity": "CRITICAL", "correlation_id": "a6522068-03c8-46cd-93a4-741b1db36b7f", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:07:35.286018+00:00", "payload": {"status": "UNHEALTHY", "severity": "CRITICAL", "source": "platformiq-observability", "snapshot_id": "a6522068-03c8-46cd-93a4-741b1db36b7f"}}	2026-07-05 17:07:35.287609
ce6a2c44-e1d1-4583-9199-fa717056c522	46ec3341-d948-4749-8bae-1e7f989d2f50	INCIDENT_CREATED	Incident created from telemetry alert.	{"event_id": "evt_0b9473db-d411-40e5-b9be-3ff68c1607b5", "event_type": "POD_RESTART_SPIKE", "schema_version": "1.0", "severity": "HIGH", "correlation_id": "ef569b8b-3352-4a87-9f07-87249758ff99", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:17:10.191675+00:00", "payload": {"pod_restart_count": 7, "threshold": 3, "severity": "HIGH", "source": "platformiq-observability", "snapshot_id": "ef569b8b-3352-4a87-9f07-87249758ff99"}}	2026-07-05 17:17:10.197243
4373703d-5c7c-4f7f-8ed6-9d8d41defb94	46ec3341-d948-4749-8bae-1e7f989d2f50	INCIDENT_ALERT_ATTACHED	Additional telemetry alert attached to existing incident.	{"event_id": "evt_88dcf0cc-1934-4479-8f92-53f185e0df34", "event_type": "SERVICE_DEGRADED", "schema_version": "1.0", "severity": "MEDIUM", "correlation_id": "ef569b8b-3352-4a87-9f07-87249758ff99", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "service_name": "payment-service", "environment": "staging", "timestamp": "2026-07-05T17:17:10.205822+00:00", "payload": {"available_replicas": 2, "replica_count": 3, "severity": "MEDIUM", "source": "platformiq-observability", "snapshot_id": "ef569b8b-3352-4a87-9f07-87249758ff99"}}	2026-07-05 17:17:10.206818
4dcffe79-ea74-46d4-b4b1-bea6d131864f	46ec3341-d948-4749-8bae-1e7f989d2f50	INCIDENT_ACKNOWLEDGED	Incident acknowledged	{}	2026-07-05 18:23:14.309506
419c46a1-276d-46a0-922e-d5e34ad33051	46ec3341-d948-4749-8bae-1e7f989d2f50	INCIDENT_RESOLVED	Incident resolved	{}	2026-07-05 18:23:16.271965
880cb3f9-621f-4a41-95b5-b672d7eb32c0	caef74be-7b67-4764-9b93-71a6aea5edeb	INCIDENT_ACKNOWLEDGED	Incident acknowledged	{}	2026-07-05 18:23:36.729816
8da86f27-ff6a-4789-ada7-53ef4d8b2e63	caef74be-7b67-4764-9b93-71a6aea5edeb	INCIDENT_RESOLVED	Incident resolved	{}	2026-07-05 18:23:37.48733
39e31ea5-696b-4b1f-9013-8fed1726ca99	f39c9a20-6fe5-46f8-af80-220082025abf	INCIDENT_RESOLVED	Incident resolved	{}	2026-07-05 18:24:13.221774
159c6bca-9523-4b37-ab1e-2b9d17fbaad1	1c8430b7-3fba-4f49-8e84-acdac4da8e5d	INCIDENT_ACKNOWLEDGED	Incident acknowledged	{}	2026-07-05 18:24:55.581408
5b1ad559-c225-444a-82a8-b72592b6dae0	1c8430b7-3fba-4f49-8e84-acdac4da8e5d	INCIDENT_RESOLVED	Incident resolved	{}	2026-07-05 18:25:02.168825
add50a18-179d-419d-b225-e6c09244e631	a7db2d9c-c7a3-42df-90ea-d848ba238f7b	INCIDENT_ACKNOWLEDGED	Incident acknowledged	{}	2026-07-11 15:18:35.072358
61fc12cc-1584-4105-afff-869c730ecbc6	a7db2d9c-c7a3-42df-90ea-d848ba238f7b	INCIDENT_RESOLVED	Incident resolved	{}	2026-07-11 15:18:36.902197
65654359-c46b-4c86-96eb-df7b830c5f43	c96510c1-4c91-4c0d-bbab-c8eb19dc5f8b	INCIDENT_CREATED	Incident created from telemetry alert.	{"event_id": "evt_f5ec3291-c1c5-426f-b2e1-b60de99d7074", "event_type": "ERROR_BUDGET_EXHAUSTED", "schema_version": "1.0", "correlation_id": "79a28492-b0d4-4098-94ce-70c4df2785cd:staging:AVAILABILITY", "service_id": "79a28492-b0d4-4098-94ce-70c4df2785cd", "environment": "staging", "timestamp": "2026-07-11T21:10:18.381041+00:00", "payload": {"source": "platformiq-reliability", "severity": "HIGH", "burn_rate": 5.000000000000284, "rapid_burn": true, "is_breached": true, "metric_type": "AVAILABILITY", "service_name": "demo-service", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "measurement_id": "01917c13-827f-4224-a5a1-cb30fc86fcdc", "window_minutes": 60, "threshold_value": 99.9, "triggered_value": 99.5, "slo_definition_id": "4b572d35-cb52-47f2-9b91-f98577ade93a", "error_budget_status": "EXHAUSTED", "reliability_alert_id": "d0391e45-448f-45b0-b978-be94302328b7", "error_budget_consumed": 500.0000000000284, "error_budget_remaining": 0.0}}	2026-07-11 21:29:10.350774
\.


--
-- Data for Name: incident_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incident_metrics (id, incident_id, metric_type, metric_name, value, unit, source, captured_at, metadata_json, created_at) FROM stdin;
\.


--
-- Data for Name: incident_timeline_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incident_timeline_events (id, incident_id, event_type, source, message, from_status, to_status, actor_user_id, alert_id, deployment_id, metadata_json, occurred_at, created_at) FROM stdin;
\.


--
-- Data for Name: incidents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incidents (id, title, description, severity, status, service_id, environment, correlation_id, triggered_by_event_id, started_at, resolved_at, created_at, updated_at) FROM stdin;
f39c9a20-6fe5-46f8-af80-220082025abf	payment-service high latency in staging	Incident created from telemetry alert HIGH_LATENCY for payment-service in staging.	HIGH	RESOLVED	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	2ae251be-c681-4f94-82d7-ba1919f31981	evt_eb37f920-f5b0-4bc1-aef2-3dfcc17cfeae	2026-07-05 17:06:29.709137	2026-07-05 18:24:13.21474	2026-07-05 17:06:29.709137	2026-07-05 18:24:13.21474
1c8430b7-3fba-4f49-8e84-acdac4da8e5d	payment-service high error rate in staging	Incident created from telemetry alert HIGH_ERROR_RATE for payment-service in staging.	HIGH	RESOLVED	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda	evt_fe913dba-05b3-4960-af9e-8add89c2b370	2026-07-05 16:38:30.527683	2026-07-05 18:25:02.168325	2026-07-05 16:38:30.527683	2026-07-05 18:25:02.168325
3fca917c-04e0-4db4-adfb-87e2588dcb09	payment-service high error rate in staging	Incident created from telemetry alert HIGH_ERROR_RATE for payment-service in staging.	HIGH	RESOLVED	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	21aaf1ee-dff3-4463-8fd1-65cbf1853f51	evt_dcef17fb-1dd6-40c9-a9e2-e693a04978c6	2026-07-04 21:06:16.899066	2026-07-04 21:12:36.233524	2026-07-04 21:06:16.899066	2026-07-04 21:12:36.233524
f0fff6a0-aa8e-4bd4-be53-4af20d913a8d	payment-service high error rate in staging	Incident created from telemetry alert HIGH_ERROR_RATE for payment-service in staging.	HIGH	OPEN	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	a6522068-03c8-46cd-93a4-741b1db36b7f	evt_893dc7b6-a556-4997-950a-2072f849eea8	2026-07-05 17:07:35.279875	\N	2026-07-05 17:07:35.279875	2026-07-05 17:07:35.287609
a7db2d9c-c7a3-42df-90ea-d848ba238f7b	payment-service high latency in staging	Incident created from telemetry alert HIGH_LATENCY for payment-service in staging.	HIGH	RESOLVED	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	79a37362-9300-45a1-b2ef-d7ec3794764e	evt_7fd7dd56-e98d-4444-9826-98fa63749f99	2026-07-05 16:37:37.414205	2026-07-11 15:18:36.901495	2026-07-05 16:37:37.414205	2026-07-11 15:18:36.901495
46ec3341-d948-4749-8bae-1e7f989d2f50	payment-service pod restart spike in staging	Incident created from telemetry alert POD_RESTART_SPIKE for payment-service in staging.	HIGH	RESOLVED	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	ef569b8b-3352-4a87-9f07-87249758ff99	evt_0b9473db-d411-40e5-b9be-3ff68c1607b5	2026-07-05 17:17:10.197243	2026-07-05 18:23:16.269775	2026-07-05 17:17:10.197243	2026-07-05 18:23:16.269775
caef74be-7b67-4764-9b93-71a6aea5edeb	payment-service pod restart spike in staging	Incident created from telemetry alert POD_RESTART_SPIKE for payment-service in staging.	HIGH	RESOLVED	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	a0a4d25b-012f-40dd-801a-9e059380cac1	evt_9f705e94-54f7-4eed-b990-301dcf61e477	2026-07-05 16:40:43.335865	2026-07-05 18:23:37.485538	2026-07-05 16:40:43.335865	2026-07-05 18:23:37.485538
c96510c1-4c91-4c0d-bbab-c8eb19dc5f8b	demo-service error budget exhausted in staging	Incident created from telemetry alert error budget exhausted for demo-service in staging.	HIGH	OPEN	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	79a28492-b0d4-4098-94ce-70c4df2785cd:staging:AVAILABILITY	evt_f5ec3291-c1c5-426f-b2e1-b60de99d7074	2026-07-11 21:29:10.350774	\N	2026-07-11 21:29:10.350774	2026-07-11 21:29:10.350774
\.


--
-- Data for Name: kubernetes_workloads; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kubernetes_workloads (id, deployment_id, workload_name, namespace, kind, desired_replicas, available_replicas, pod_count, restart_count, status, failure_reason, created_at) FROM stdin;
9fb71d0e-608b-44d0-b002-07e885284bac	dacd606c-4046-4466-a268-fcae7f6d3940	demo-service	platformiq-demo	Deployment	1	1	1	0	HEALTHY	\N	2026-06-28 06:25:31.895094+00
9bd2ea19-d6a0-4894-b80c-2887084bab6b	2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727	demo-service	platformiq-demo	Deployment	1	0	1	3	FAILED	Manual Sprint 4G failure event test	2026-06-28 06:26:54.108847+00
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, pipeline_id, log_text, "timestamp") FROM stdin;
1	03505498-9850-46c5-9b43-2d5aeb2ac988	Pipeline started.	2026-05-17 14:55:45.703431
2	03505498-9850-46c5-9b43-2d5aeb2ac988	Repository: https://github.com/shounakdev/meetup	2026-05-17 14:55:45.714703
3	03505498-9850-46c5-9b43-2d5aeb2ac988	Branch: main	2026-05-17 14:55:45.719882
4	03505498-9850-46c5-9b43-2d5aeb2ac988	Starting real Node.js pipeline execution...	2026-05-17 14:58:00.982836
5	03505498-9850-46c5-9b43-2d5aeb2ac988	Repo: https://github.com/shounakdev/meetup	2026-05-17 14:58:01.02696
6	03505498-9850-46c5-9b43-2d5aeb2ac988	Branch: main	2026-05-17 14:58:01.032009
7	03505498-9850-46c5-9b43-2d5aeb2ac988	$ git clone https://github.com/shounakdev/meetup repo	2026-05-17 14:58:01.03734
8	03505498-9850-46c5-9b43-2d5aeb2ac988	Cloning into 'repo'...	2026-05-17 14:58:01.043142
9	03505498-9850-46c5-9b43-2d5aeb2ac988	$ git checkout main	2026-05-17 14:58:01.048737
10	03505498-9850-46c5-9b43-2d5aeb2ac988	Your branch is up to date with 'origin/main'.\nAlready on 'main'	2026-05-17 14:58:01.054154
11	03505498-9850-46c5-9b43-2d5aeb2ac988	$ npm ci	2026-05-17 14:58:01.059837
12	03505498-9850-46c5-9b43-2d5aeb2ac988	added 429 packages, and audited 430 packages in 26s\n\n148 packages are looking for funding\n  run `npm fund` for details\n\n15 vulnerabilities (7 moderate, 7 high, 1 critical)\n\nTo address issues that do not require attention, run:\n  npm audit fix\n\nTo address all issues, run:\n  npm audit fix --force\n\nRun `npm audit` for details.\nnpm WARN deprecated q@1.5.1: You or someone you depend on is using Q, the JavaScript Promise library that gave JavaScript developers strong feelings about promises. They can almost certainly migrate to the native JavaScript promise now. Thank you literally everyone for joining me in this bet against the odds. Be excellent to each other.\nnpm WARN deprecated \nnpm WARN deprecated (For a CapTP with native promises, see @endo/eventual-send and @endo/captp)	2026-05-17 14:58:01.065395
13	03505498-9850-46c5-9b43-2d5aeb2ac988	$ npm test	2026-05-17 14:58:01.07092
14	03505498-9850-46c5-9b43-2d5aeb2ac988	> meetup@0.1.0 test\n> echo "No tests configured yet" && exit 0\n\nNo tests configured yet	2026-05-17 14:58:01.076522
15	03505498-9850-46c5-9b43-2d5aeb2ac988	$ npm run build	2026-05-17 14:58:01.081376
16	03505498-9850-46c5-9b43-2d5aeb2ac988	> meetup@0.1.0 build\n> next build\n\nAttention: Next.js now collects completely anonymous telemetry regarding usage.\nThis information is used to shape Next.js' roadmap and prioritize features.\nYou can learn more, including how to opt-out if you'd not like to participate in this anonymous program, by visiting the following URL:\nhttps://nextjs.org/telemetry\n\n   ▲ Next.js 15.4.5\n\n   Creating an optimized production build ...\n ✓ Compiled successfully in 12.0s\n   Linting and checking validity of types ...\n\n./pages/index.tsx\n32:9  Warning: Custom fonts not added in `pages/_document.js` will only load for a single page. This is discouraged. See: https://nextjs.org/docs/messages/no-page-custom-font  @next/next/no-page-custom-font\n\n./pages/room/[id].tsx\n25:9  Warning: 'screenVideoRef' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n76:10  Warning: 'showPhotoOptions' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n76:28  Warning: 'setShowPhotoOptions' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n82:10  Warning: 'signalingState' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n144:11  Warning: 'maxY' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n476:6  Warning: React Hook useCallback has a missing dependency: 'iceServers'. Either include it or remove the dependency array.  react-hooks/exhaustive-deps\n1289:6  Warning: React Hook useEffect has a missing dependency: 'mediaLoading'. Either include it or remove the dependency array.  react-hooks/exhaustive-deps\n1710:9  Warning: Custom fonts not added in `pages/_document.js` will only load for a single page. This is discouraged. See: https://nextjs.org/docs/messages/no-page-custom-font  @next/next/no-page-custom-font\n2774:29  Warning: Using `<img>` could result in slower LCP and higher bandwidth. Consider using `<Image />` from `next/image` or a custom image loader to automatically optimize images. This may incur additional usage or cost from your provider. See: https://nextjs.org/docs/messages/no-img-element  @next/next/no-img-element\n2789:29  Warning: Using `<img>` could result in slower LCP and higher bandwidth. Consider using `<Image />` from `next/image` or a custom image loader to automatically optimize images. This may incur additional usage or cost from your provider. See: https://nextjs.org/docs/messages/no-img-element  @next/next/no-img-element\n2976:27  Warning: Using `<img>` could result in slower LCP and higher bandwidth. Consider using `<Image />` from `next/image` or a custom image loader to automatically optimize images. This may incur additional usage or cost from your provider. See: https://nextjs.org/docs/messages/no-img-element  @next/next/no-img-element\n3343:17  Warning: Using `<img>` could result in slower LCP and higher bandwidth. Consider using `<Image />` from `next/image` or a custom image loader to automatically optimize images. This may incur additional usage or cost from your provider. See: https://nextjs.org/docs/messages/no-img-element  @next/next/no-img-element\n\ninfo  - Need to disable some ESLint rules? Learn more here: https://nextjs.org/docs/app/api-reference/config/eslint#disabling-rules\n   Collecting page data ...\n   Generating static pages (0/5) ...\n   Generating static pages (1/5) \n   Generating static pages (2/5) \n   Generating static pages (3/5) \n ✓ Generating static pages (5/5)\n   Finalizing page optimization ...\n   Collecting build traces ...\n\n\nRoute (pages)                                Size  First Load JS\n┌ ○ / (960 ms)                            5.58 kB        98.6 kB\n├ ○ /404                                    180 B        93.2 kB\n├ ƒ /api/cleanup                              0 B          93 kB\n├ ƒ /api/upload                               0 B          93 kB\n└ ○ /room/[id] (1044 ms)                  33.3 kB         126 kB\n+ First Load JS shared by all               93 kB\n  ├ chunks/framework-7c95b8e5103c9e90.js  57.7 kB\n  ├ chunks/main-aec60416f522f94c.js       33.6 kB\n  └ other shared chunks (total)           1.77 kB\n\n○  (Static)   prerendered as static content\nƒ  (Dynamic)  server-rendered on demand	2026-05-17 14:58:01.087057
17	03505498-9850-46c5-9b43-2d5aeb2ac988	$ npx @sonar/scan -Dsonar.projectKey=cicd-demo -Dsonar.projectName=cicd-demo -Dsonar.sources=. -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=squ_c8bc14cc7c6b033151fb701c7d4d6bf014e31847 -Dsonar.sourceEncoding=UTF-8 -Dsonar.exclusions=node_modules/**,.next/**,dist/**,build/**,coverage/** -Dsonar.qualitygate.wait=true -Dsonar.qualitygate.timeout=300	2026-05-17 14:58:01.096988
18	03505498-9850-46c5-9b43-2d5aeb2ac988	[INFO]  Bootstrapper: Retrieving info from "package.json" file\n[WARN]  Bootstrapper: Property "sonar.login" is deprecated and will be removed in a future version. Please use "sonar.token" instead.\n[INFO]  Bootstrapper: Platform: linux x64\n[INFO]  Bootstrapper: Server URL: http://sonarqube:9000\n[INFO]  Bootstrapper: Version: 4.3.6\n[INFO]  Bootstrapper: SonarQube server version: 9.9.8\n[INFO]  Bootstrapper: JRE provisioning is NOT supported\n[INFO]  Bootstrapper: Falling back on using sonar-scanner-cli\n[INFO]  Bootstrapper: Starting analysis\n14:57:18.592 INFO  Scanner configuration file: /root/.sonar/native-sonar-scanner/sonar-scanner-6.2.1.4610-linux-x64/conf/sonar-scanner.properties\n14:57:18.604 INFO  Project root configuration file: NONE\n14:57:18.657 INFO  SonarScanner CLI 6.2.1.4610\n14:57:18.662 INFO  Java 17.0.12 Eclipse Adoptium (64-bit)\n14:57:18.664 INFO  Linux 6.2.0-33-generic amd64\n14:57:18.697 INFO  User cache: /root/.sonar/cache\n14:57:20.579 INFO  Communicating with SonarQube Server 9.9.8.100196\n14:57:21.836 INFO  Load global settings\n14:57:22.221 INFO  Load global settings (done) | time=388ms\n14:57:22.228 INFO  Server id: D6762DAA-AZ4RpIW1bPZMPBuam19Y\n14:57:22.243 INFO  User cache: /root/.sonar/cache\n14:57:22.256 INFO  Load/download plugins\n14:57:22.257 INFO  Load plugins index\n14:57:22.423 INFO  Load plugins index (done) | time=165ms\n14:57:22.633 INFO  Load/download plugins (done) | time=377ms\n14:57:24.022 INFO  Process project properties\n14:57:24.042 INFO  Process project properties (done) | time=20ms\n14:57:24.050 INFO  Execute project builders\n14:57:24.054 INFO  Execute project builders (done) | time=5ms\n14:57:24.063 INFO  Project key: cicd-demo\n14:57:24.064 INFO  Base dir: /tmp/tmping7eb8z/repo\n14:57:24.064 INFO  Working dir: /tmp/tmping7eb8z/repo/.scannerwork\n14:57:24.096 INFO  Load project settings for component key: 'cicd-demo'\n14:57:24.248 INFO  Load project settings for component key: 'cicd-demo' (done) | time=152ms\n14:57:24.755 INFO  Load quality profiles\n14:57:25.010 INFO  Load quality profiles (done) | time=255ms\n14:57:25.024 INFO  Load active rules\n14:57:30.028 INFO  Load active rules (done) | time=5004ms\n14:57:30.046 INFO  Load analysis cache\n14:57:30.102 INFO  Load analysis cache | time=56ms\n14:57:30.280 INFO  Load project repositories\n14:57:30.349 INFO  Load project repositories (done) | time=69ms\n14:57:30.450 INFO  Indexing files...\n14:57:30.451 INFO  Project configuration:\n14:57:30.453 INFO    Excluded sources: node_modules/**, .next/**, dist/**, build/**, coverage/**\n14:57:32.061 INFO  23 files indexed\n14:57:32.062 INFO  21172 files ignored because of inclusion/exclusion patterns\n14:57:32.062 INFO  1 file ignored because of scm ignore settings\n14:57:32.065 INFO  Quality profile for css: Sonar way\n14:57:32.065 INFO  Quality profile for js: Sonar way\n14:57:32.065 INFO  Quality profile for json: Sonar way\n14:57:32.066 INFO  Quality profile for ts: Sonar way\n14:57:32.066 INFO  ------------- Run sensors on module cicd-demo\n14:57:32.301 INFO  Load metrics repository\n14:57:32.381 INFO  Load metrics repository (done) | time=80ms\n14:57:35.952 INFO  Sensor JaCoCo XML Report Importer [jacoco]\n14:57:35.956 INFO  'sonar.coverage.jacoco.xmlReportPaths' is not defined. Using default locations: target/site/jacoco/jacoco.xml,target/site/jacoco-it/jacoco.xml,build/reports/jacoco/test/jacocoTestReport.xml\n14:57:35.958 INFO  No report imported, no coverage information will be imported by JaCoCo XML Report Importer\n14:57:35.958 INFO  Sensor JaCoCo XML Report Importer [jacoco] (done) | time=6ms\n14:57:35.959 INFO  Sensor IaC CloudFormation Sensor [iac]\n14:57:36.098 INFO  0 source files to be analyzed\n14:57:36.175 INFO  0/0 source files have been analyzed\n14:57:36.175 INFO  Sensor IaC CloudFormation Sensor [iac] (done) | time=217ms\n14:57:36.176 INFO  Sensor IaC Kubernetes Sensor [iac]\n14:57:36.259 INFO  0 source files to be analyzed\n14:57:36.347 INFO  0/0 source files have been analyzed\n14:57:36.347 INFO  Sensor IaC Kubernetes Sensor [iac] (done) | time=171ms\n14:57:36.348 INFO  Sensor JavaScript analysis [javascript]\n14:57:44.718 WARN  Node.js version 20 is not recommended, you might experience issues. Please use a recommended version of Node.js [16, 18]\n14:57:44.748 INFO  3 source files to be analyzed\n14:57:51.333 INFO  3/3 source files have been analyzed\n14:57:51.334 INFO  Hit the cache for 0 out of 3\n14:57:51.338 INFO  Miss the cache for 3 out of 3: ANALYSIS_MODE_INELIGIBLE [3/3]\n14:57:51.339 INFO  Sensor JavaScript analysis [javascript] (done) | time=14991ms\n14:57:51.339 INFO  Sensor TypeScript analysis [javascript]\n14:57:51.403 INFO  Found 1 tsconfig.json file(s): [/tmp/tmping7eb8z/repo/tsconfig.json]\n14:57:51.404 INFO  8 source files to be analyzed\n14:57:51.404 INFO  Creating TypeScript program\n14:57:51.404 INFO  TypeScript configuration file /tmp/tmping7eb8z/repo/tsconfig.json\n[ERROR] Bootstrapper: 14:57:51.425 ERROR Error: Argument for '--moduleResolution' option must be: 'node', 'classic', 'node16', 'nodenext'.\n\n[ERROR] Bootstrapper: 14:57:51.425 ERROR     at createProgramOptions (/tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/lib/services/program/program.js:106:15)\n14:57:51.426 ERROR     at createProgram (/tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/lib/services/program/program.js:132:28)\n14:57:51.426 ERROR     at default_1 (/tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/lib/routing/on-create-program.js:10:57)\n14:57:51.426 ERROR     at Layer.handle [as handle_request] (/tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/layer.js:95:5)\n14:57:51.426 ERROR     at next (/tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/route.js:144:13)\n14:57:51.426 ERROR     at Route.dispatch (/tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/route.js:114:3)\n14:57:51.426 ERROR     at Layer.handle [as handle_request] (/tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/layer.js:95:5)\n14:57:51.426 ERROR     at /tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/index.js:284:15\n14:57:51.426 ERROR     at Function.process_params (/tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/index.js:346:12)\n14:57:51.426 ERROR     at next (/tmp/tmping7eb8z/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/index.js:280:10)\n\n[ERROR] Bootstrapper: 14:57:51.429 ERROR Failed to create program: Argument for '--moduleResolution' option must be: 'node', 'classic', 'node16', 'nodenext'.\n\n14:57:51.429 INFO  Creating TypeScript program (done) | time=25ms\n14:57:51.429 INFO  Skipped 8 file(s) because they were not part of any tsconfig.json (enable debug logs to see the full list)\n14:57:51.431 INFO  8/8 source files have been analyzed\n14:57:51.431 INFO  Hit the cache for 0 out of 0\n14:57:51.432 INFO  Miss the cache for 0 out of 0\n14:57:51.432 INFO  Sensor TypeScript analysis [javascript] (done) | time=93ms\n14:57:51.432 INFO  Sensor CSS Rules [javascript]\n14:57:51.446 INFO  1 source file to be analyzed\n14:57:51.648 INFO  1/1 source file has been analyzed\n14:57:51.649 INFO  Hit the cache for 0 out of 0\n14:57:51.649 INFO  Miss the cache for 0 out of 0\n14:57:51.650 INFO  Sensor CSS Rules [javascript] (done) | time=218ms\n14:57:51.650 INFO  Sensor CSS Metrics [javascript]\n14:57:51.673 INFO  Sensor CSS Metrics [javascript] (done) | time=23ms\n14:57:51.673 INFO  Sensor C# Project Type Information [csharp]\n14:57:51.674 INFO  Sensor C# Project Type Information [csharp] (done) | time=1ms\n14:57:51.675 INFO  Sensor C# Analysis Log [csharp]\n14:57:51.697 INFO  Sensor C# Analysis Log [csharp] (done) | time=22ms\n14:57:51.697 INFO  Sensor C# Properties [csharp]\n14:57:51.697 INFO  Sensor C# Properties [csharp] (done) | time=0ms\n14:57:51.697 INFO  Sensor HTML [web]\n14:57:51.702 INFO  Sensor HTML [web] (done) | time=5ms\n14:57:51.702 INFO  Sensor TextAndSecretsSensor [text]\n14:57:51.721 INFO  15 source files to be analyzed\n14:57:52.279 INFO  15/15 source files have been analyzed\n14:57:52.280 INFO  Sensor TextAndSecretsSensor [text] (done) | time=578ms\n14:57:52.280 INFO  Sensor VB.NET Project Type Information [vbnet]\n14:57:52.282 INFO  Sensor VB.NET Project Type Information [vbnet] (done) | time=2ms\n14:57:52.282 INFO  Sensor VB.NET Analysis Log [vbnet]\n14:57:52.312 INFO  Sensor VB.NET Analysis Log [vbnet] (done) | time=29ms\n14:57:52.312 INFO  Sensor VB.NET Properties [vbnet]\n14:57:52.312 INFO  Sensor VB.NET Properties [vbnet] (done) | time=0ms\n14:57:52.312 INFO  Sensor IaC Docker Sensor [iac]\n14:57:52.314 INFO  0 source files to be analyzed\n14:57:52.396 INFO  0/0 source files have been analyzed\n14:57:52.397 INFO  Sensor IaC Docker Sensor [iac] (done) | time=85ms\n14:57:52.407 INFO  ------------- Run sensors on project\n14:57:52.576 INFO  Sensor Analysis Warnings import [csharp]\n14:57:52.579 INFO  Sensor Analysis Warnings import [csharp] (done) | time=3ms\n14:57:52.579 INFO  Sensor Zero Coverage Sensor\n14:57:52.603 INFO  Sensor Zero Coverage Sensor (done) | time=24ms\n14:57:52.638 INFO  CPD Executor 2 files had no CPD blocks\n14:57:52.639 INFO  CPD Executor Calculating CPD for 1 file\n14:57:52.666 INFO  CPD Executor CPD calculation finished (done) | time=25ms\n14:57:52.863 INFO  Analysis report generated in 189ms, dir size=287.2 kB\n14:57:52.919 INFO  Analysis report compressed in 54ms, zip size=66.4 kB\n14:57:52.993 INFO  Analysis report uploaded in 73ms\n14:57:52.997 INFO  ------------- Check Quality Gate status\n14:57:52.998 INFO  Waiting for the analysis report to be processed (max 300s)\n14:57:58.164 INFO  QUALITY GATE STATUS: PASSED - View details on http://sonarqube:9000/dashboard?id=cicd-demo\n14:57:59.554 INFO  Analysis total time: 36.621 s\n14:57:59.557 INFO  EXECUTION SUCCESS\n14:57:59.559 INFO  Total time: 41.046s\n[INFO]  Bootstrapper: SonarScanner CLI finished successfully	2026-05-17 14:58:01.101192
19	03505498-9850-46c5-9b43-2d5aeb2ac988	Pipeline completed successfully.	2026-05-17 14:58:01.118578
20	03505498-9850-46c5-9b43-2d5aeb2ac988	Fetching SonarQube report...	2026-05-17 14:58:01.124087
21	03505498-9850-46c5-9b43-2d5aeb2ac988	SonarQube quality gate: PASSED	2026-05-17 14:58:01.354827
22	03505498-9850-46c5-9b43-2d5aeb2ac988	Coverage: 0.0	2026-05-17 14:58:01.360639
23	03505498-9850-46c5-9b43-2d5aeb2ac988	Bugs: 1	2026-05-17 14:58:01.365316
24	03505498-9850-46c5-9b43-2d5aeb2ac988	Vulnerabilities: 0	2026-05-17 14:58:01.370679
25	03505498-9850-46c5-9b43-2d5aeb2ac988	Code smells: 0	2026-05-17 14:58:01.375711
26	03505498-9850-46c5-9b43-2d5aeb2ac988	AI DevOps summary generated: PASS_WITH_WARNINGS	2026-05-17 14:58:01.394974
27	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Pipeline started.	2026-05-17 15:25:48.034903
28	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Repository: https://github.com/shounakdev/meetup	2026-05-17 15:25:48.051917
29	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Branch: cicd_test	2026-05-17 15:25:48.062871
30	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Starting real Node.js pipeline execution...	2026-05-17 15:27:52.144575
31	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Repo: https://github.com/shounakdev/meetup	2026-05-17 15:27:52.201118
32	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Branch: cicd_test	2026-05-17 15:27:52.207866
33	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	$ git clone https://github.com/shounakdev/meetup repo	2026-05-17 15:27:52.214917
34	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Cloning into 'repo'...	2026-05-17 15:27:52.222768
35	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	$ git checkout cicd_test	2026-05-17 15:27:52.229282
36	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	branch 'cicd_test' set up to track 'origin/cicd_test'.\nSwitched to a new branch 'cicd_test'	2026-05-17 15:27:52.235444
37	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	$ npm ci	2026-05-17 15:27:52.242585
38	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	added 429 packages, and audited 430 packages in 34s\n\n148 packages are looking for funding\n  run `npm fund` for details\n\n15 vulnerabilities (7 moderate, 7 high, 1 critical)\n\nTo address issues that do not require attention, run:\n  npm audit fix\n\nTo address all issues, run:\n  npm audit fix --force\n\nRun `npm audit` for details.\nnpm WARN deprecated q@1.5.1: You or someone you depend on is using Q, the JavaScript Promise library that gave JavaScript developers strong feelings about promises. They can almost certainly migrate to the native JavaScript promise now. Thank you literally everyone for joining me in this bet against the odds. Be excellent to each other.\nnpm WARN deprecated \nnpm WARN deprecated (For a CapTP with native promises, see @endo/eventual-send and @endo/captp)	2026-05-17 15:27:52.247622
39	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	$ npm test	2026-05-17 15:27:52.253505
40	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	> meetup@0.1.0 test\n> echo "No tests configured yet" && exit 0\n\nNo tests configured yet	2026-05-17 15:27:52.258899
41	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	$ npm run build	2026-05-17 15:27:52.263889
42	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	> meetup@0.1.0 build\n> next build\n\nAttention: Next.js now collects completely anonymous telemetry regarding usage.\nThis information is used to shape Next.js' roadmap and prioritize features.\nYou can learn more, including how to opt-out if you'd not like to participate in this anonymous program, by visiting the following URL:\nhttps://nextjs.org/telemetry\n\n   ▲ Next.js 15.4.5\n\n   Creating an optimized production build ...\n ✓ Compiled successfully in 8.0s\n   Linting and checking validity of types ...\n\n./pages/index.tsx\n32:9  Warning: Custom fonts not added in `pages/_document.js` will only load for a single page. This is discouraged. See: https://nextjs.org/docs/messages/no-page-custom-font  @next/next/no-page-custom-font\n\n./pages/room/[id].tsx\n25:9  Warning: 'screenVideoRef' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n76:10  Warning: 'showPhotoOptions' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n76:28  Warning: 'setShowPhotoOptions' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n82:10  Warning: 'signalingState' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n144:11  Warning: 'maxY' is assigned a value but never used.  @typescript-eslint/no-unused-vars\n476:6  Warning: React Hook useCallback has a missing dependency: 'iceServers'. Either include it or remove the dependency array.  react-hooks/exhaustive-deps\n1289:6  Warning: React Hook useEffect has a missing dependency: 'mediaLoading'. Either include it or remove the dependency array.  react-hooks/exhaustive-deps\n1710:9  Warning: Custom fonts not added in `pages/_document.js` will only load for a single page. This is discouraged. See: https://nextjs.org/docs/messages/no-page-custom-font  @next/next/no-page-custom-font\n2774:29  Warning: Using `<img>` could result in slower LCP and higher bandwidth. Consider using `<Image />` from `next/image` or a custom image loader to automatically optimize images. This may incur additional usage or cost from your provider. See: https://nextjs.org/docs/messages/no-img-element  @next/next/no-img-element\n2789:29  Warning: Using `<img>` could result in slower LCP and higher bandwidth. Consider using `<Image />` from `next/image` or a custom image loader to automatically optimize images. This may incur additional usage or cost from your provider. See: https://nextjs.org/docs/messages/no-img-element  @next/next/no-img-element\n2976:27  Warning: Using `<img>` could result in slower LCP and higher bandwidth. Consider using `<Image />` from `next/image` or a custom image loader to automatically optimize images. This may incur additional usage or cost from your provider. See: https://nextjs.org/docs/messages/no-img-element  @next/next/no-img-element\n3343:17  Warning: Using `<img>` could result in slower LCP and higher bandwidth. Consider using `<Image />` from `next/image` or a custom image loader to automatically optimize images. This may incur additional usage or cost from your provider. See: https://nextjs.org/docs/messages/no-img-element  @next/next/no-img-element\n\ninfo  - Need to disable some ESLint rules? Learn more here: https://nextjs.org/docs/app/api-reference/config/eslint#disabling-rules\n   Collecting page data ...\n   Generating static pages (0/5) ...\n   Generating static pages (1/5) \n   Generating static pages (2/5) \n   Generating static pages (3/5) \n ✓ Generating static pages (5/5)\n   Finalizing page optimization ...\n   Collecting build traces ...\n\n\nRoute (pages)                                Size  First Load JS\n┌ ○ / (646 ms)                            5.58 kB        98.6 kB\n├ ○ /404                                    180 B        93.2 kB\n├ ƒ /api/cleanup                              0 B          93 kB\n├ ƒ /api/upload                               0 B          93 kB\n└ ○ /room/[id] (732 ms)                   33.3 kB         126 kB\n+ First Load JS shared by all               93 kB\n  ├ chunks/framework-7c95b8e5103c9e90.js  57.7 kB\n  ├ chunks/main-aec60416f522f94c.js       33.6 kB\n  └ other shared chunks (total)           1.77 kB\n\n○  (Static)   prerendered as static content\nƒ  (Dynamic)  server-rendered on demand	2026-05-17 15:27:52.270706
43	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	$ npx @sonar/scan -Dsonar.projectKey=cicd-demo -Dsonar.projectName=cicd-demo -Dsonar.sources=. -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=squ_c8bc14cc7c6b033151fb701c7d4d6bf014e31847 -Dsonar.sourceEncoding=UTF-8 -Dsonar.exclusions=node_modules/**,.next/**,dist/**,build/**,coverage/** -Dsonar.qualitygate.wait=true -Dsonar.qualitygate.timeout=300	2026-05-17 15:27:52.281029
44	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	[INFO]  Bootstrapper: Retrieving info from "package.json" file\n[WARN]  Bootstrapper: Property "sonar.login" is deprecated and will be removed in a future version. Please use "sonar.token" instead.\n[INFO]  Bootstrapper: Platform: linux x64\n[INFO]  Bootstrapper: Server URL: http://sonarqube:9000\n[INFO]  Bootstrapper: Version: 4.3.6\n[INFO]  Bootstrapper: SonarQube server version: 9.9.8\n[INFO]  Bootstrapper: JRE provisioning is NOT supported\n[INFO]  Bootstrapper: Falling back on using sonar-scanner-cli\n[INFO]  Bootstrapper: Starting analysis\n15:27:18.560 INFO  Scanner configuration file: /root/.sonar/native-sonar-scanner/sonar-scanner-6.2.1.4610-linux-x64/conf/sonar-scanner.properties\n15:27:18.565 INFO  Project root configuration file: NONE\n15:27:18.585 INFO  SonarScanner CLI 6.2.1.4610\n15:27:18.587 INFO  Java 17.0.12 Eclipse Adoptium (64-bit)\n15:27:18.588 INFO  Linux 6.2.0-33-generic amd64\n15:27:18.605 INFO  User cache: /root/.sonar/cache\n15:27:19.500 INFO  Communicating with SonarQube Server 9.9.8.100196\n15:27:20.080 INFO  Load global settings\n15:27:20.324 INFO  Load global settings (done) | time=246ms\n15:27:20.327 INFO  Server id: D6762DAA-AZ4RpIW1bPZMPBuam19Y\n15:27:20.332 INFO  User cache: /root/.sonar/cache\n15:27:20.337 INFO  Load/download plugins\n15:27:20.337 INFO  Load plugins index\n15:27:20.435 INFO  Load plugins index (done) | time=98ms\n15:27:20.558 INFO  Load/download plugins (done) | time=221ms\n15:27:21.242 INFO  Process project properties\n15:27:21.254 INFO  Process project properties (done) | time=12ms\n15:27:21.259 INFO  Execute project builders\n15:27:21.261 INFO  Execute project builders (done) | time=3ms\n15:27:21.266 INFO  Project key: cicd-demo\n15:27:21.266 INFO  Base dir: /tmp/tmpn92l61xy/repo\n15:27:21.266 INFO  Working dir: /tmp/tmpn92l61xy/repo/.scannerwork\n15:27:21.281 INFO  Load project settings for component key: 'cicd-demo'\n15:27:21.372 INFO  Load project settings for component key: 'cicd-demo' (done) | time=92ms\n15:27:21.550 INFO  Load quality profiles\n15:27:21.710 INFO  Load quality profiles (done) | time=160ms\n15:27:21.718 INFO  Load active rules\n15:27:25.178 INFO  Load active rules (done) | time=3459ms\n15:27:25.191 INFO  Load analysis cache\n15:27:25.232 INFO  Load analysis cache | time=41ms\n15:27:25.371 INFO  Load project repositories\n15:27:25.426 INFO  Load project repositories (done) | time=55ms\n15:27:25.496 INFO  Indexing files...\n15:27:25.497 INFO  Project configuration:\n15:27:25.497 INFO    Excluded sources: node_modules/**, .next/**, dist/**, build/**, coverage/**\n15:27:26.477 INFO  23 files indexed\n15:27:26.477 INFO  21172 files ignored because of inclusion/exclusion patterns\n15:27:26.477 INFO  1 file ignored because of scm ignore settings\n15:27:26.479 INFO  Quality profile for css: Sonar way\n15:27:26.479 INFO  Quality profile for js: Sonar way\n15:27:26.479 INFO  Quality profile for json: Sonar way\n15:27:26.479 INFO  Quality profile for ts: Sonar way\n15:27:26.479 INFO  ------------- Run sensors on module cicd-demo\n15:27:26.584 INFO  Load metrics repository\n15:27:26.646 INFO  Load metrics repository (done) | time=62ms\n15:27:28.342 INFO  Sensor JaCoCo XML Report Importer [jacoco]\n15:27:28.344 INFO  'sonar.coverage.jacoco.xmlReportPaths' is not defined. Using default locations: target/site/jacoco/jacoco.xml,target/site/jacoco-it/jacoco.xml,build/reports/jacoco/test/jacocoTestReport.xml\n15:27:28.345 INFO  No report imported, no coverage information will be imported by JaCoCo XML Report Importer\n15:27:28.345 INFO  Sensor JaCoCo XML Report Importer [jacoco] (done) | time=3ms\n15:27:28.345 INFO  Sensor IaC CloudFormation Sensor [iac]\n15:27:28.419 INFO  0 source files to be analyzed\n15:27:28.455 INFO  0/0 source files have been analyzed\n15:27:28.456 INFO  Sensor IaC CloudFormation Sensor [iac] (done) | time=111ms\n15:27:28.456 INFO  Sensor IaC Kubernetes Sensor [iac]\n15:27:28.503 INFO  0 source files to be analyzed\n15:27:28.528 INFO  0/0 source files have been analyzed\n15:27:28.529 INFO  Sensor IaC Kubernetes Sensor [iac] (done) | time=73ms\n15:27:28.529 INFO  Sensor JavaScript analysis [javascript]\n15:27:34.977 WARN  Node.js version 20 is not recommended, you might experience issues. Please use a recommended version of Node.js [16, 18]\n15:27:34.997 INFO  3 source files to be analyzed\n15:27:38.932 INFO  3/3 source files have been analyzed\n15:27:38.933 INFO  Hit the cache for 0 out of 3\n15:27:38.938 INFO  Miss the cache for 3 out of 3: ANALYSIS_MODE_INELIGIBLE [3/3]\n15:27:38.938 INFO  Sensor JavaScript analysis [javascript] (done) | time=10409ms\n15:27:38.939 INFO  Sensor TypeScript analysis [javascript]\n15:27:39.010 INFO  Found 1 tsconfig.json file(s): [/tmp/tmpn92l61xy/repo/tsconfig.json]\n15:27:39.012 INFO  8 source files to be analyzed\n15:27:39.012 INFO  Creating TypeScript program\n15:27:39.012 INFO  TypeScript configuration file /tmp/tmpn92l61xy/repo/tsconfig.json\n[ERROR] Bootstrapper: 15:27:39.039 ERROR Error: Argument for '--moduleResolution' option must be: 'node', 'classic', 'node16', 'nodenext'.\n15:27:39.039 ERROR     at createProgramOptions (/tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/lib/services/program/program.js:106:15)\n15:27:39.039 ERROR     at createProgram (/tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/lib/services/program/program.js:132:28)\n15:27:39.040 ERROR     at default_1 (/tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/lib/routing/on-create-program.js:10:57)\n15:27:39.040 ERROR     at Layer.handle [as handle_request] (/tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/layer.js:95:5)\n15:27:39.040 ERROR     at next (/tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/route.js:144:13)\n15:27:39.040 ERROR     at Route.dispatch (/tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/route.js:114:3)\n15:27:39.040 ERROR     at Layer.handle [as handle_request] (/tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/layer.js:95:5)\n15:27:39.040 ERROR     at /tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/index.js:284:15\n15:27:39.040 ERROR     at Function.process_params (/tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/index.js:346:12)\n15:27:39.040 ERROR     at next (/tmp/tmpn92l61xy/repo/.scannerwork/.sonartmp/eslint-bridge-bundle/package/node_modules/express/lib/router/index.js:280:10)\n\n[ERROR] Bootstrapper: 15:27:39.044 ERROR Failed to create program: Argument for '--moduleResolution' option must be: 'node', 'classic', 'node16', 'nodenext'.\n\n15:27:39.045 INFO  Creating TypeScript program (done) | time=33ms\n15:27:39.045 INFO  Skipped 8 file(s) because they were not part of any tsconfig.json (enable debug logs to see the full list)\n15:27:39.047 INFO  8/8 source files have been analyzed\n15:27:39.048 INFO  Hit the cache for 0 out of 0\n15:27:39.048 INFO  Miss the cache for 0 out of 0\n15:27:39.048 INFO  Sensor TypeScript analysis [javascript] (done) | time=109ms\n15:27:39.048 INFO  Sensor CSS Rules [javascript]\n15:27:39.065 INFO  1 source file to be analyzed\n15:27:39.301 INFO  1/1 source file has been analyzed\n15:27:39.302 INFO  Hit the cache for 0 out of 0\n15:27:39.302 INFO  Miss the cache for 0 out of 0\n15:27:39.302 INFO  Sensor CSS Rules [javascript] (done) | time=254ms\n15:27:39.302 INFO  Sensor CSS Metrics [javascript]\n15:27:39.321 INFO  Sensor CSS Metrics [javascript] (done) | time=19ms\n15:27:39.321 INFO  Sensor C# Project Type Information [csharp]\n15:27:39.323 INFO  Sensor C# Project Type Information [csharp] (done) | time=2ms\n15:27:39.323 INFO  Sensor C# Analysis Log [csharp]\n15:27:39.344 INFO  Sensor C# Analysis Log [csharp] (done) | time=21ms\n15:27:39.344 INFO  Sensor C# Properties [csharp]\n15:27:39.344 INFO  Sensor C# Properties [csharp] (done) | time=0ms\n15:27:39.345 INFO  Sensor HTML [web]\n15:27:39.348 INFO  Sensor HTML [web] (done) | time=4ms\n15:27:39.348 INFO  Sensor TextAndSecretsSensor [text]\n15:27:39.358 INFO  15 source files to be analyzed\n15:27:39.712 INFO  15/15 source files have been analyzed\n15:27:39.713 INFO  Sensor TextAndSecretsSensor [text] (done) | time=365ms\n15:27:39.713 INFO  Sensor VB.NET Project Type Information [vbnet]\n15:27:39.714 INFO  Sensor VB.NET Project Type Information [vbnet] (done) | time=1ms\n15:27:39.715 INFO  Sensor VB.NET Analysis Log [vbnet]\n15:27:39.734 INFO  Sensor VB.NET Analysis Log [vbnet] (done) | time=19ms\n15:27:39.735 INFO  Sensor VB.NET Properties [vbnet]\n15:27:39.735 INFO  Sensor VB.NET Properties [vbnet] (done) | time=0ms\n15:27:39.735 INFO  Sensor IaC Docker Sensor [iac]\n15:27:39.736 INFO  0 source files to be analyzed\n15:27:39.801 INFO  0/0 source files have been analyzed\n15:27:39.801 INFO  Sensor IaC Docker Sensor [iac] (done) | time=66ms\n15:27:39.811 INFO  ------------- Run sensors on project\n15:27:39.909 INFO  Sensor Analysis Warnings import [csharp]\n15:27:39.910 INFO  Sensor Analysis Warnings import [csharp] (done) | time=1ms\n15:27:39.910 INFO  Sensor Zero Coverage Sensor\n15:27:39.920 INFO  Sensor Zero Coverage Sensor (done) | time=10ms\n15:27:39.934 INFO  CPD Executor 2 files had no CPD blocks\n15:27:39.935 INFO  CPD Executor Calculating CPD for 1 file\n15:27:39.946 INFO  CPD Executor CPD calculation finished (done) | time=11ms\n15:27:40.058 INFO  Analysis report generated in 106ms, dir size=287.2 kB\n15:27:40.104 INFO  Analysis report compressed in 46ms, zip size=66.4 kB\n15:27:40.161 INFO  Analysis report uploaded in 56ms\n15:27:40.163 INFO  ------------- Check Quality Gate status\n15:27:40.164 INFO  Waiting for the analysis report to be processed (max 300s)\n15:27:50.304 INFO  QUALITY GATE STATUS: PASSED - View details on http://sonarqube:9000/dashboard?id=cicd-demo\n15:27:50.955 INFO  Analysis total time: 30.263 s\n15:27:50.957 INFO  EXECUTION SUCCESS\n15:27:50.958 INFO  Total time: 32.444s\n[INFO]  Bootstrapper: SonarScanner CLI finished successfully	2026-05-17 15:27:52.287954
45	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Pipeline completed successfully.	2026-05-17 15:27:52.309693
46	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Fetching SonarQube report...	2026-05-17 15:27:52.317081
47	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	SonarQube quality gate: PASSED	2026-05-17 15:27:52.54679
48	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Coverage: 0.0	2026-05-17 15:27:52.55291
49	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Bugs: 1	2026-05-17 15:27:52.55856
50	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Vulnerabilities: 0	2026-05-17 15:27:52.563829
51	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	Code smells: 0	2026-05-17 15:27:52.5695
52	2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	AI DevOps summary generated: PASS_WITH_WARNINGS	2026-05-17 15:27:52.58798
53	bd502165-da51-42d7-bc10-ee67681015c9	Pipeline started.	2026-05-17 15:33:14.462857
54	bd502165-da51-42d7-bc10-ee67681015c9	Repository: https://github.com/shounakdev/passbook-ui	2026-05-17 15:33:14.475386
55	bd502165-da51-42d7-bc10-ee67681015c9	Branch: cisd_test	2026-05-17 15:33:14.485563
56	bd502165-da51-42d7-bc10-ee67681015c9	Starting real Node.js pipeline execution...	2026-05-17 15:34:17.266423
57	bd502165-da51-42d7-bc10-ee67681015c9	Repo: https://github.com/shounakdev/passbook-ui	2026-05-17 15:34:17.28418
58	bd502165-da51-42d7-bc10-ee67681015c9	Branch: cisd_test	2026-05-17 15:34:17.288908
59	bd502165-da51-42d7-bc10-ee67681015c9	$ git clone https://github.com/shounakdev/passbook-ui repo	2026-05-17 15:34:17.293548
60	bd502165-da51-42d7-bc10-ee67681015c9	Cloning into 'repo'...	2026-05-17 15:34:17.29752
61	bd502165-da51-42d7-bc10-ee67681015c9	$ git checkout cisd_test	2026-05-17 15:34:17.301395
62	bd502165-da51-42d7-bc10-ee67681015c9	branch 'cisd_test' set up to track 'origin/cisd_test'.\nSwitched to a new branch 'cisd_test'	2026-05-17 15:34:17.30564
63	bd502165-da51-42d7-bc10-ee67681015c9	$ npm ci	2026-05-17 15:34:17.309511
64	bd502165-da51-42d7-bc10-ee67681015c9	added 168 packages, and audited 169 packages in 10s\n\n36 packages are looking for funding\n  run `npm fund` for details\n\n11 vulnerabilities (5 moderate, 6 high)\n\nTo address all issues, run:\n  npm audit fix\n\nRun `npm audit` for details.	2026-05-17 15:34:17.313083
65	bd502165-da51-42d7-bc10-ee67681015c9	$ npm test	2026-05-17 15:34:17.319182
66	bd502165-da51-42d7-bc10-ee67681015c9	> passbook-ui@0.0.0 test\n> echo "No tests configured yet" && exit 0\n\nNo tests configured yet	2026-05-17 15:34:17.324964
67	bd502165-da51-42d7-bc10-ee67681015c9	$ npm run build	2026-05-17 15:34:17.330025
68	bd502165-da51-42d7-bc10-ee67681015c9	> passbook-ui@0.0.0 build\n> vite build\n\nvite v7.1.3 building for production...\ntransforming...\n✓ 191 modules transformed.\nrendering chunks...\ncomputing gzip size...\ndist/index.html                   0.46 kB │ gzip:   0.30 kB\ndist/assets/index-Dtn62Xmo.css    0.91 kB │ gzip:   0.50 kB\ndist/assets/index-B-2BIjzq.js   527.85 kB │ gzip: 182.18 kB\n✓ built in 5.09s\n\n(!) Some chunks are larger than 500 kB after minification. Consider:\n- Using dynamic import() to code-split the application\n- Use build.rollupOptions.output.manualChunks to improve chunking: https://rollupjs.org/configuration-options/#output-manualchunks\n- Adjust chunk size limit for this warning via build.chunkSizeWarningLimit.	2026-05-17 15:34:17.335193
69	bd502165-da51-42d7-bc10-ee67681015c9	$ npx @sonar/scan -Dsonar.projectKey=cicd-demo -Dsonar.projectName=cicd-demo -Dsonar.sources=. -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=squ_c8bc14cc7c6b033151fb701c7d4d6bf014e31847 -Dsonar.sourceEncoding=UTF-8 -Dsonar.exclusions=node_modules/**,.next/**,dist/**,build/**,coverage/** -Dsonar.qualitygate.wait=true -Dsonar.qualitygate.timeout=300	2026-05-17 15:34:17.341159
70	bd502165-da51-42d7-bc10-ee67681015c9	[INFO]  Bootstrapper: Retrieving info from "package.json" file\n[WARN]  Bootstrapper: Property "sonar.login" is deprecated and will be removed in a future version. Please use "sonar.token" instead.\n[INFO]  Bootstrapper: Platform: linux x64\n[INFO]  Bootstrapper: Server URL: http://sonarqube:9000\n[INFO]  Bootstrapper: Version: 4.3.6\n[INFO]  Bootstrapper: SonarQube server version: 9.9.8\n[INFO]  Bootstrapper: JRE provisioning is NOT supported\n[INFO]  Bootstrapper: Falling back on using sonar-scanner-cli\n[INFO]  Bootstrapper: Starting analysis\n15:33:40.046 INFO  Scanner configuration file: /root/.sonar/native-sonar-scanner/sonar-scanner-6.2.1.4610-linux-x64/conf/sonar-scanner.properties\n15:33:40.056 INFO  Project root configuration file: NONE\n15:33:40.090 INFO  SonarScanner CLI 6.2.1.4610\n15:33:40.093 INFO  Java 17.0.12 Eclipse Adoptium (64-bit)\n15:33:40.095 INFO  Linux 6.2.0-33-generic amd64\n15:33:40.119 INFO  User cache: /root/.sonar/cache\n15:33:41.535 INFO  Communicating with SonarQube Server 9.9.8.100196\n15:33:42.607 INFO  Load global settings\n15:33:42.863 INFO  Load global settings (done) | time=261ms\n15:33:42.870 INFO  Server id: D6762DAA-AZ4RpIW1bPZMPBuam19Y\n15:33:42.882 INFO  User cache: /root/.sonar/cache\n15:33:42.893 INFO  Load/download plugins\n15:33:42.894 INFO  Load plugins index\n15:33:42.988 INFO  Load plugins index (done) | time=94ms\n15:33:43.186 INFO  Load/download plugins (done) | time=293ms\n15:33:44.394 INFO  Process project properties\n15:33:44.410 INFO  Process project properties (done) | time=16ms\n15:33:44.415 INFO  Execute project builders\n15:33:44.418 INFO  Execute project builders (done) | time=3ms\n15:33:44.424 INFO  Project key: cicd-demo\n15:33:44.424 INFO  Base dir: /tmp/tmpd3g9xfal/repo\n15:33:44.424 INFO  Working dir: /tmp/tmpd3g9xfal/repo/.scannerwork\n15:33:44.441 INFO  Load project settings for component key: 'cicd-demo'\n15:33:44.504 INFO  Load project settings for component key: 'cicd-demo' (done) | time=63ms\n15:33:44.878 INFO  Load quality profiles\n15:33:45.065 INFO  Load quality profiles (done) | time=187ms\n15:33:45.077 INFO  Load active rules\n15:33:48.796 INFO  Load active rules (done) | time=3719ms\n15:33:48.809 INFO  Load analysis cache\n15:33:48.847 INFO  Load analysis cache | time=38ms\n15:33:48.994 INFO  Load project repositories\n15:33:49.046 INFO  Load project repositories (done) | time=51ms\n15:33:49.129 INFO  Indexing files...\n15:33:49.130 INFO  Project configuration:\n15:33:49.132 INFO    Excluded sources: node_modules/**, .next/**, dist/**, build/**, coverage/**\n15:33:49.889 INFO  15 files indexed\n15:33:49.890 INFO  5484 files ignored because of inclusion/exclusion patterns\n15:33:49.890 INFO  0 files ignored because of scm ignore settings\n15:33:49.893 INFO  Quality profile for css: Sonar way\n15:33:49.894 INFO  Quality profile for js: Sonar way\n15:33:49.894 INFO  Quality profile for json: Sonar way\n15:33:49.894 INFO  Quality profile for web: Sonar way\n15:33:49.894 INFO  ------------- Run sensors on module cicd-demo\n15:33:50.134 INFO  Load metrics repository\n15:33:50.206 INFO  Load metrics repository (done) | time=72ms\n15:33:53.789 INFO  Sensor JaCoCo XML Report Importer [jacoco]\n15:33:53.792 INFO  'sonar.coverage.jacoco.xmlReportPaths' is not defined. Using default locations: target/site/jacoco/jacoco.xml,target/site/jacoco-it/jacoco.xml,build/reports/jacoco/test/jacocoTestReport.xml\n15:33:53.794 INFO  No report imported, no coverage information will be imported by JaCoCo XML Report Importer\n15:33:53.795 INFO  Sensor JaCoCo XML Report Importer [jacoco] (done) | time=6ms\n15:33:53.795 INFO  Sensor IaC CloudFormation Sensor [iac]\n15:33:53.892 INFO  0 source files to be analyzed\n15:33:53.944 INFO  0/0 source files have been analyzed\n15:33:53.944 INFO  Sensor IaC CloudFormation Sensor [iac] (done) | time=149ms\n15:33:53.945 INFO  Sensor IaC Kubernetes Sensor [iac]\n15:33:53.998 INFO  0 source files to be analyzed\n15:33:54.048 INFO  0/0 source files have been analyzed\n15:33:54.048 INFO  Sensor IaC Kubernetes Sensor [iac] (done) | time=103ms\n15:33:54.049 INFO  Sensor JavaScript analysis [javascript]\n15:34:01.651 WARN  Node.js version 20 is not recommended, you might experience issues. Please use a recommended version of Node.js [16, 18]\n15:34:01.693 INFO  7 source files to be analyzed\n15:34:08.210 INFO  7/7 source files have been analyzed\n15:34:08.211 INFO  Hit the cache for 0 out of 7\n15:34:08.214 INFO  Miss the cache for 7 out of 7: ANALYSIS_MODE_INELIGIBLE [7/7]\n15:34:08.215 INFO  Sensor JavaScript analysis [javascript] (done) | time=14166ms\n15:34:08.215 INFO  Sensor TypeScript analysis [javascript]\n15:34:08.216 INFO  No input files found for analysis\n15:34:08.217 INFO  Hit the cache for 0 out of 0\n15:34:08.217 INFO  Miss the cache for 0 out of 0\n15:34:08.217 INFO  Sensor TypeScript analysis [javascript] (done) | time=2ms\n15:34:08.217 INFO  Sensor CSS Rules [javascript]\n15:34:08.232 INFO  3 source files to be analyzed\n15:34:08.719 INFO  3/3 source files have been analyzed\n15:34:08.720 INFO  Hit the cache for 0 out of 0\n15:34:08.720 INFO  Miss the cache for 0 out of 0\n15:34:08.721 INFO  Sensor CSS Rules [javascript] (done) | time=504ms\n15:34:08.721 INFO  Sensor CSS Metrics [javascript]\n15:34:08.764 INFO  Sensor CSS Metrics [javascript] (done) | time=43ms\n15:34:08.765 INFO  Sensor C# Project Type Information [csharp]\n15:34:08.766 INFO  Sensor C# Project Type Information [csharp] (done) | time=1ms\n15:34:08.767 INFO  Sensor C# Analysis Log [csharp]\n15:34:08.813 INFO  Sensor C# Analysis Log [csharp] (done) | time=46ms\n15:34:08.814 INFO  Sensor C# Properties [csharp]\n15:34:08.814 INFO  Sensor C# Properties [csharp] (done) | time=0ms\n15:34:08.814 INFO  Sensor HTML [web]\n15:34:08.864 INFO  Sensor HTML [web] (done) | time=50ms\n15:34:08.864 INFO  Sensor TextAndSecretsSensor [text]\n15:34:08.878 INFO  12 source files to be analyzed\n15:34:09.031 INFO  12/12 source files have been analyzed\n15:34:09.032 INFO  Sensor TextAndSecretsSensor [text] (done) | time=168ms\n15:34:09.032 INFO  Sensor VB.NET Project Type Information [vbnet]\n15:34:09.034 INFO  Sensor VB.NET Project Type Information [vbnet] (done) | time=2ms\n15:34:09.035 INFO  Sensor VB.NET Analysis Log [vbnet]\n15:34:09.069 INFO  Sensor VB.NET Analysis Log [vbnet] (done) | time=34ms\n15:34:09.070 INFO  Sensor VB.NET Properties [vbnet]\n15:34:09.070 INFO  Sensor VB.NET Properties [vbnet] (done) | time=0ms\n15:34:09.070 INFO  Sensor IaC Docker Sensor [iac]\n15:34:09.071 INFO  0 source files to be analyzed\n15:34:09.150 INFO  0/0 source files have been analyzed\n15:34:09.150 INFO  Sensor IaC Docker Sensor [iac] (done) | time=80ms\n15:34:09.164 INFO  ------------- Run sensors on project\n15:34:09.313 INFO  Sensor Analysis Warnings import [csharp]\n15:34:09.315 INFO  Sensor Analysis Warnings import [csharp] (done) | time=2ms\n15:34:09.316 INFO  Sensor Zero Coverage Sensor\n15:34:09.330 INFO  Sensor Zero Coverage Sensor (done) | time=14ms\n15:34:09.333 INFO  SCM Publisher SCM provider for this project is: git\n15:34:09.336 INFO  SCM Publisher 10 source files to be analyzed\n15:34:09.608 INFO  SCM Publisher 10/10 source files have been analyzed (done) | time=271ms\n15:34:09.620 INFO  CPD Executor 1 file had no CPD blocks\n15:34:09.620 INFO  CPD Executor Calculating CPD for 7 files\n15:34:09.651 INFO  CPD Executor CPD calculation finished (done) | time=29ms\n15:34:09.815 INFO  Analysis report generated in 155ms, dir size=159.9 kB\n15:34:09.873 INFO  Analysis report compressed in 58ms, zip size=48.0 kB\n15:34:09.943 INFO  Analysis report uploaded in 68ms\n15:34:09.947 INFO  ------------- Check Quality Gate status\n15:34:09.949 INFO  Waiting for the analysis report to be processed (max 300s)\n15:34:15.071 INFO  QUALITY GATE STATUS: PASSED - View details on http://sonarqube:9000/dashboard?id=cicd-demo\n15:34:16.348 INFO  Analysis total time: 32.856 s\n15:34:16.350 INFO  EXECUTION SUCCESS\n15:34:16.351 INFO  Total time: 36.396s\n[INFO]  Bootstrapper: SonarScanner CLI finished successfully	2026-05-17 15:34:17.346586
71	bd502165-da51-42d7-bc10-ee67681015c9	Pipeline completed successfully.	2026-05-17 15:34:17.360006
72	bd502165-da51-42d7-bc10-ee67681015c9	Fetching SonarQube report...	2026-05-17 15:34:17.364276
73	bd502165-da51-42d7-bc10-ee67681015c9	SonarQube quality gate: PASSED	2026-05-17 15:34:17.538842
74	bd502165-da51-42d7-bc10-ee67681015c9	Coverage: 0.0	2026-05-17 15:34:17.544481
75	bd502165-da51-42d7-bc10-ee67681015c9	Bugs: 0	2026-05-17 15:34:17.549559
76	bd502165-da51-42d7-bc10-ee67681015c9	Vulnerabilities: 0	2026-05-17 15:34:17.5552
77	bd502165-da51-42d7-bc10-ee67681015c9	Code smells: 0	2026-05-17 15:34:17.560436
78	bd502165-da51-42d7-bc10-ee67681015c9	AI DevOps summary generated: PASS_WITH_WARNINGS	2026-05-17 15:34:17.578781
\.


--
-- Data for Name: outbox_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.outbox_events (id, event_id, topic, event_type, schema_version, correlation_id, service_id, environment, payload, status, retry_count, last_error, published_at, created_at, updated_at) FROM stdin;
420a42ed-5be2-47c5-bdb8-7333ad03cc20	evt_78dec550-ea50-42ef-a18b-62333eedd241	pipeline.events	PIPELINE_STARTED	1.0	manual-test-001	manual-service	local	{"source": "manual-test", "message": "Testing transactional outbox writer"}	PUBLISHED	0	\N	2026-06-27 18:54:28.550085+00	2026-06-27 18:54:19.855849+00	2026-06-27 18:54:28.550103+00
9bfbe9f8-ac2d-431e-ad59-e1686e2154c3	evt_5608218d-3d09-4834-a04c-27f261223063	pipeline.events	PIPELINE_STARTED	1.0	manual-test-4e-001	manual-service	local	{"source": "manual-test", "message": "Testing Sprint 4E outbox publisher"}	PUBLISHED	0	\N	2026-06-27 19:35:02.648117+00	2026-06-27 19:34:56.762734+00	2026-06-27 19:35:02.648137+00
d5b24ff9-e4fc-44b9-94e1-319f4830da29	evt_4cf89470-df0d-4ac7-8731-78ce90b88bae	deployment.events	DEPLOYMENT_STARTED	1.0	dacd606c-4046-4466-a268-fcae7f6d3940	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"image_tag": "demo-service:manual-sprint-4g-2", "namespace": "platformiq-demo", "cluster_name": "kind-platformiq", "deployment_id": "dacd606c-4046-4466-a268-fcae7f6d3940", "pipeline_run_id": null, "deployment_version": "v1.0.1-sprint-4g", "argo_application_name": "demo-service-app"}	PUBLISHED	0	\N	2026-06-28 06:24:44.337248+00	2026-06-28 06:24:37.366734+00	2026-06-28 06:24:44.337263+00
79ca6585-2a7b-4bc6-b60f-ddc41247c2a0	evt_50f841bb-2d13-4a28-810e-0a8e2b530907	deployment.events	DEPLOYMENT_COMPLETED	1.0	dacd606c-4046-4466-a268-fcae7f6d3940	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"image_tag": "demo-service:manual-sprint-4g-2", "pod_count": 1, "deployment_id": "dacd606c-4046-4466-a268-fcae7f6d3940", "restart_count": 0, "pipeline_run_id": null, "argo_sync_status": "SYNCED", "kubernetes_rollout_status": "HEALTHY"}	PUBLISHED	0	\N	2026-06-28 06:25:33.771677+00	2026-06-28 06:25:31.902463+00	2026-06-28 06:25:33.771693+00
d2688a3d-fa41-4a70-bf07-484ff125a727	evt_45f17721-a3a6-4a05-bf56-f8629b490f34	deployment.events	DEPLOYMENT_STARTED	1.0	2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"image_tag": "demo-service:manual-sprint-4g-failed", "namespace": "platformiq-demo", "cluster_name": "kind-platformiq", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "pipeline_run_id": null, "deployment_version": "v1.0.2-sprint-4g-failed", "argo_application_name": "demo-service-app"}	PUBLISHED	0	\N	2026-06-28 06:26:13.732006+00	2026-06-28 06:26:12.537474+00	2026-06-28 06:26:13.732024+00
e3bc4ea3-a5e5-4764-a375-dc118c37f32e	evt_65b9aefa-9106-4db0-a227-283fa10c84b4	deployment.events	DEPLOYMENT_FAILED	1.0	2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"image_tag": "demo-service:manual-sprint-4g-failed", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "failure_reason": "Manual Sprint 4G failure event test", "pipeline_run_id": null, "argo_sync_status": "UNKNOWN", "kubernetes_rollout_status": "FAILED"}	PUBLISHED	0	\N	2026-06-28 06:27:03.699858+00	2026-06-28 06:26:54.119615+00	2026-06-28 06:27:03.699865+00
f3961408-e456-4d0f-9f7c-87e07c00b779	evt_5c030e21-deb8-4d60-aa95-53251b50a6b6	kubernetes.events	KUBERNETES_DEPLOYMENT_HEALTHY	1.0	inventory-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "inventory-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PUBLISHED	0	\N	2026-06-28 09:39:25.675359+00	2026-06-28 09:39:15.528505+00	2026-06-28 09:39:25.675384+00
f1478e7c-a6a2-4e30-a050-a4d9b977a45c	evt_561c2b14-f154-4dcc-a4e0-56e4921dc869	kubernetes.events	KUBERNETES_DEPLOYMENT_HEALTHY	1.0	order-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "order-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PUBLISHED	0	\N	2026-06-28 09:39:25.68798+00	2026-06-28 09:39:15.528512+00	2026-06-28 09:39:25.687988+00
ce17ccab-7d94-4d03-af6c-264a295ff9ee	evt_a97c04e6-2730-46cc-9dce-9ae14d739ba7	kubernetes.events	KUBERNETES_DEPLOYMENT_HEALTHY	1.0	payment-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "payment-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PUBLISHED	0	\N	2026-06-28 09:39:25.69345+00	2026-06-28 09:39:15.528517+00	2026-06-28 09:39:25.693459+00
eadb20c2-f309-49ac-84e7-c59b1460eac0	evt_034a5fb8-5f45-4d0c-a26d-8bc31e20d7b2	kubernetes.events	KUBERNETES_DEPLOYMENT_HEALTHY	1.0	postgres	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "postgres", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PUBLISHED	0	\N	2026-06-28 09:39:25.698692+00	2026-06-28 09:39:15.528522+00	2026-06-28 09:39:25.698699+00
23e42248-6202-41be-b92c-dd29ac9fde54	evt_66d85b6e-3dd3-4fee-9b6e-dd3ab16bdce1	kubernetes.events	KUBERNETES_DEPLOYMENT_HEALTHY	1.0	inventory-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "inventory-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PUBLISHED	0	\N	2026-06-28 09:59:11.211815+00	2026-06-28 09:59:05.015188+00	2026-06-28 09:59:11.211836+00
d0fb10bc-38ff-482a-81e3-4ca265769654	evt_87eea227-53c4-4007-a306-7d4dc4997520	kubernetes.events	KUBERNETES_DEPLOYMENT_HEALTHY	1.0	order-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "order-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PUBLISHED	0	\N	2026-06-28 09:59:11.227647+00	2026-06-28 09:59:05.015205+00	2026-06-28 09:59:11.227659+00
a66c79b5-9e22-465b-865f-ff3b8180129c	evt_88153961-4361-4c2a-9afc-992ac00afe7a	kubernetes.events	KUBERNETES_DEPLOYMENT_HEALTHY	1.0	payment-service	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "payment-service", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PUBLISHED	0	\N	2026-06-28 09:59:11.233718+00	2026-06-28 09:59:05.015218+00	2026-06-28 09:59:11.233725+00
cf63e52a-1fa0-48dc-a512-cc1445f45ca5	evt_b125770f-2bd5-4564-b139-76925c7de230	kubernetes.events	KUBERNETES_DEPLOYMENT_HEALTHY	1.0	postgres	\N	staging	{"namespace": "platformiq-demo", "deployment_name": "postgres", "desired_replicas": 1, "available_replicas": 1, "previous_available_replicas": null}	PUBLISHED	0	\N	2026-06-28 09:59:11.237829+00	2026-06-28 09:59:05.01523+00	2026-06-28 09:59:11.237835+00
eb01d6c1-3ced-447f-b4bb-0b08bd56e21b	evt_f5ec3291-c1c5-426f-b2e1-b60de99d7074	telemetry.alerts	ERROR_BUDGET_EXHAUSTED	1.0	79a28492-b0d4-4098-94ce-70c4df2785cd:staging:AVAILABILITY	79a28492-b0d4-4098-94ce-70c4df2785cd	staging	{"source": "platformiq-reliability", "severity": "HIGH", "burn_rate": 5.000000000000284, "rapid_burn": true, "is_breached": true, "metric_type": "AVAILABILITY", "service_name": "demo-service", "deployment_id": "2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727", "measurement_id": "01917c13-827f-4224-a5a1-cb30fc86fcdc", "window_minutes": 60, "threshold_value": 99.9, "triggered_value": 99.5, "slo_definition_id": "4b572d35-cb52-47f2-9b91-f98577ade93a", "error_budget_status": "EXHAUSTED", "reliability_alert_id": "d0391e45-448f-45b0-b978-be94302328b7", "error_budget_consumed": 500.0000000000284, "error_budget_remaining": 0.0}	PUBLISHED	0	\N	2026-07-11 21:10:29.567767+00	2026-07-11 21:10:18.381041+00	2026-07-11 21:10:29.567785+00
\.


--
-- Data for Name: pipeline_runs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pipeline_runs (id, service_id, repo_id, repo_url, branch, status, stage, failure_reason, commit_sha, commit_message, build_status, test_status, sonar_status, trivy_status, coverage, bugs, vulnerabilities, code_smells, duplicated_lines_density, quality_gate, sonar_report_url, sonar_issues, trivy_critical, trivy_high, trivy_medium, trivy_low, trivy_unknown, trivy_total, trivy_report, risk_score, risk_level, risk_summary, ai_summary, recommendations, logs, created_at, started_at, finished_at, duration_seconds) FROM stdin;
\.


--
-- Data for Name: pipelines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pipelines (id, repo_url, branch, status, progress, error_message, created_at, updated_at, started_at, finished_at, duration_seconds, quality_score, coverage, bugs, vulnerabilities, code_smells, duplicated_lines_density, quality_gate, sonar_report_url, stage, failure_reason, commit_sha, commit_message, build_status, test_status, sonar_status, trivy_status, sonar_issues, trivy_critical, trivy_high, trivy_medium, trivy_low, trivy_unknown, trivy_total, trivy_report, risk_score, risk_level, risk_summary, ai_summary, recommendations) FROM stdin;
03505498-9850-46c5-9b43-2d5aeb2ac988	https://github.com/shounakdev/meetup	main	SUCCESS	100	\N	2026-05-17 14:55:45.500672	2026-05-17 14:58:01.344299	2026-05-17 14:55:45.633055	2026-05-17 14:58:01.105633	135.472578	\N	0	1	0	0	0	PASSED	http://localhost:9000/dashboard?id=cicd-demo	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2cf7748b-a166-4a9f-b2c1-5fdf19a355e9	https://github.com/shounakdev/meetup	cicd_test	SUCCESS	100	\N	2026-05-17 15:25:47.602579	2026-05-17 15:27:52.537573	2026-05-17 15:25:47.874143	2026-05-17 15:27:52.292126	124.417983	\N	0	1	0	0	0	PASSED	http://localhost:9000/dashboard?id=cicd-demo	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
bd502165-da51-42d7-bc10-ee67681015c9	https://github.com/shounakdev/passbook-ui	cisd_test	SUCCESS	100	\N	2026-05-17 15:33:14.316122	2026-05-17 15:34:17.528581	2026-05-17 15:33:14.44128	2026-05-17 15:34:17.350476	62.909196	\N	0	0	0	0	0	PASSED	http://localhost:9000/dashboard?id=cicd-demo	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, name, description, created_by, created_at) FROM stdin;
7f19107c-f297-4f6e-bde5-67f9b06e4d68	Sprint 4G Test Project	Manual test project for deployment events	\N	2026-06-28 06:15:46.960925
\.


--
-- Data for Name: reliability_alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reliability_alerts (id, service_id, slo_definition_id, alert_type, severity, triggered_value, threshold_value, deployment_id, status, created_at, resolved_at) FROM stdin;
d0391e45-448f-45b0-b978-be94302328b7	79a28492-b0d4-4098-94ce-70c4df2785cd	4b572d35-cb52-47f2-9b91-f98577ade93a	ERROR_BUDGET_EXHAUSTED	HIGH	99.5	99.9	2d1f11ac-dac7-4a9f-a8e0-e62a0bb77727	OPEN	2026-07-11 21:10:18.324058+00	\N
\.


--
-- Data for Name: repositories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repositories (id, service_id, provider, repo_url, default_branch, created_at) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, created_at) FROM stdin;
\.


--
-- Data for Name: service_health_snapshots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service_health_snapshots (id, service_id, service_name, environment, status, latency_ms, error_rate, cpu_usage, memory_usage, pod_restart_count, replica_count, available_replicas, source, created_at) FROM stdin;
5ac06feb-13a7-457f-b4f0-3e4a36b5b435	79a28492-b0d4-4098-94ce-70c4df2785cd	demo-service	staging	HEALTHY	120	0.5	35	42	0	3	3	manual-test	2026-07-04 19:03:35.211888+00
60b25acd-9082-4420-b9ac-3a7767a61999	79a28492-b0d4-4098-94ce-70c4df2785cd	demo-service	staging	DEGRADED	1400	7.2	65	70	2	3	2	manual-test	2026-07-04 19:05:03.500727+00
552e4b79-8d8f-4e85-9f7f-67a0554a35c9	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	2300	18.4	\N	\N	6	3	1	manual	2026-07-04 19:20:22.437517+00
9ef922ed-b91d-4fe0-8306-92334f9abd75	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	2300	18.4	\N	\N	6	3	1	manual	2026-07-04 19:29:14.814884+00
30727914-9514-44b4-b61a-a159dfb7d5fe	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	2300	18.4	\N	\N	6	3	1	manual	2026-07-04 19:30:36.485545+00
cb20df76-b631-42d3-8bad-38e346a01425	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	2300	18.4	\N	\N	6	3	1	manual	2026-07-04 19:34:54.36512+00
beaf4b73-f649-4a8a-89ef-03a90200d26d	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	2300	18.4	\N	\N	6	3	1	manual	2026-07-04 20:00:17.917786+00
8c63a58b-210c-4019-bc7a-b655bfacddd2	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	2300	18.4	\N	\N	6	3	1	manual	2026-07-04 20:37:49.872966+00
17340f66-30cc-490c-8fc5-fcfa1f0c60dc	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	2300	18.4	\N	\N	6	3	1	manual	2026-07-04 20:59:02.340627+00
5cb22d43-e71f-4a4e-b70e-8ea5b8f6b32d	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	2300	18.4	\N	\N	6	3	1	manual	2026-07-04 21:00:35.504012+00
21aaf1ee-dff3-4463-8fd1-65cbf1853f51	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	2300	18.4	\N	\N	6	3	1	manual	2026-07-04 21:06:16.858604+00
9b85798d-1049-4b9b-a0c3-ccdae72f1199	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	HEALTHY	120	0.2	\N	\N	0	3	3	manual	2026-07-05 16:36:13.018593+00
79a37362-9300-45a1-b2ef-d7ec3794764e	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	UNHEALTHY	2300	1.2	\N	\N	0	3	3	manual	2026-07-05 16:37:37.401823+00
74e66a5f-6c49-40ea-b5b3-3ed9e0ec6eda	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	UNHEALTHY	300	18.4	\N	\N	0	3	3	manual	2026-07-05 16:38:30.51762+00
a0a4d25b-012f-40dd-801a-9e059380cac1	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	250	0.5	\N	\N	7	3	2	manual	2026-07-05 16:40:43.326782+00
87d2971f-a9e2-4f98-ade6-462261183b3f	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	HEALTHY	120	0.2	\N	\N	0	3	3	manual	2026-07-05 17:06:20.543711+00
2ae251be-c681-4f94-82d7-ba1919f31981	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	UNHEALTHY	2300	1.2	\N	\N	0	3	3	manual	2026-07-05 17:06:29.697899+00
a6522068-03c8-46cd-93a4-741b1db36b7f	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	UNHEALTHY	300	18.4	\N	\N	0	3	3	manual	2026-07-05 17:07:35.275289+00
ef569b8b-3352-4a87-9f07-87249758ff99	79a28492-b0d4-4098-94ce-70c4df2785cd	payment-service	staging	DEGRADED	250	0.5	\N	\N	7	3	2	manual	2026-07-05 17:17:10.177766+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, project_id, name, description, service_type, owner, created_at) FROM stdin;
79a28492-b0d4-4098-94ce-70c4df2785cd	7f19107c-f297-4f6e-bde5-67f9b06e4d68	demo-service	Manual test service for deployment events	\N	\N	2026-06-28 06:15:46.965236
\.


--
-- Data for Name: slo_definitions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slo_definitions (id, service_id, metric_type, target_value, window_minutes, severity_on_breach, enabled, created_at, updated_at) FROM stdin;
4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.9	60	HIGH	t	2026-07-11 17:52:24.890296+00	2026-07-11 17:52:24.890296+00
3aae207e-2d34-4fb8-89a1-3c70eac24655	79a28492-b0d4-4098-94ce-70c4df2785cd	P95_LATENCY	500	60	MEDIUM	t	2026-07-11 17:52:30.117248+00	2026-07-11 17:52:30.117248+00
\.


--
-- Data for Name: slo_measurements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slo_measurements (id, slo_definition_id, service_id, metric_type, measured_value, target_value, is_breached, window_minutes, source, evaluated_at, created_at) FROM stdin;
9d54b398-5e68-4692-8f9f-215a6615d58b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	0	99.9	t	60	PROMETHEUS	2026-07-11 20:19:00.081965+00	2026-07-11 20:19:00.081965+00
753fe389-6d41-42da-aaac-80c1284636f7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	87.28570074896606	99.9	t	60	PROMETHEUS	2026-07-11 20:23:07.656848+00	2026-07-11 20:23:07.656848+00
1dde53c7-5fa1-49c6-972d-e0e5e1f24697	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	87.49560147970604	99.9	t	60	PROMETHEUS	2026-07-11 20:31:02.386594+00	2026-07-11 20:31:02.386594+00
9e879e16-e688-4794-b9ed-922d3716f9e5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.5	99.9	t	60	PROMETHEUS	2026-07-11 20:54:20.113607+00	2026-07-11 20:54:20.113607+00
01917c13-827f-4224-a5a1-cb30fc86fcdc	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.5	99.9	t	60	PROMETHEUS	2026-07-11 21:10:18.324058+00	2026-07-11 21:10:18.324058+00
3861eaf9-d454-4083-b40c-74f7b7166c8c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.5	99.9	t	60	PROMETHEUS	2026-07-11 21:24:30.35575+00	2026-07-11 21:24:30.35575+00
734829b3-1c00-4d70-8982-be001de12193	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:00:12.35288+00	2026-07-12 09:00:12.35288+00
c063c3df-981a-487f-be3b-2bea1d2fed1f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:00:47.89617+00	2026-07-12 09:00:47.89617+00
969aece2-42b2-40a7-914e-059eb6baa681	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:01:47.896682+00	2026-07-12 09:01:47.896682+00
7592baac-01a3-437f-9bb3-819b6798847d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:02:47.89619+00	2026-07-12 09:02:47.89619+00
439f6fcd-77b5-4ae0-9802-4ee9eb74da98	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:03:47.895791+00	2026-07-12 09:03:47.895791+00
b3fc5468-f897-4afe-9e68-fc163c7dabcb	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:05:47.896325+00	2026-07-12 09:05:47.896325+00
63d744ef-7eba-44fb-942c-f034fda82cd8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:06:48.034506+00	2026-07-12 09:06:48.034506+00
06fcaeb2-2dc1-4c62-a798-2f5ef1ec2eb4	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 09:07:47.896278+00	2026-07-12 09:07:47.896278+00
5d224394-4991-4818-b76d-ace6f45f8b1c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:08:47.899796+00	2026-07-12 09:08:47.899796+00
6c94489f-6da1-46fe-80f1-4ea951c2f226	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:09:47.898302+00	2026-07-12 09:09:47.898302+00
c6f75681-7b21-408c-9b50-0180d96eced4	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 09:10:47.900869+00	2026-07-12 09:10:47.900869+00
9847ddf1-9c32-4f6b-9a2f-013d03cb432a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:11:47.944433+00	2026-07-12 09:11:47.944433+00
fdfb5ae2-731f-4977-b1cc-ae0eb2990894	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:12:47.89699+00	2026-07-12 09:12:47.89699+00
c6514693-aedf-4033-a319-b94d709ca2ae	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:13:47.897446+00	2026-07-12 09:13:47.897446+00
a05df240-6d08-4a65-9a88-a2b46d3b3617	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:14:47.896461+00	2026-07-12 09:14:47.896461+00
2e9d3ff9-e13e-4ccf-8dca-dc3bebf5c447	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:17:10.489882+00	2026-07-12 09:17:10.489882+00
1fc6b1c7-de3f-4f91-9e85-4d42a7f99630	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:18:10.046495+00	2026-07-12 09:18:10.046495+00
c60a9b1c-37a6-4375-8177-8fe2b8ea82e5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:19:10.062068+00	2026-07-12 09:19:10.062068+00
3363fb30-64bd-49c9-87d1-ac33efdf33e3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 09:20:10.066138+00	2026-07-12 09:20:10.066138+00
c69801a1-d81f-4f5f-9875-ea24fa80e757	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:21:10.063149+00	2026-07-12 09:21:10.063149+00
9be91cab-0276-4ce0-9392-7a36b31b0c1d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:22:10.06382+00	2026-07-12 09:22:10.06382+00
cddd09e9-00f2-48a4-9350-913ed342576a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 09:23:10.100517+00	2026-07-12 09:23:10.100517+00
10d26deb-e52c-4b89-8184-459362f522f3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:24:10.064767+00	2026-07-12 09:24:10.064767+00
b5c29b08-39d2-4197-af0b-215a29a50644	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:25:10.063527+00	2026-07-12 09:25:10.063527+00
113cc416-6144-4b2d-925e-33414e3081d9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:27:10.063935+00	2026-07-12 09:27:10.063935+00
d242eb09-a243-4b16-a5c5-2fc1b1a0125f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:28:10.063499+00	2026-07-12 09:28:10.063499+00
b73fb78f-bd5f-4d21-8722-ba672fba6078	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:29:10.063336+00	2026-07-12 09:29:10.063336+00
11b80f0f-0535-48ff-85da-6c6fcb17b5df	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 09:30:10.063784+00	2026-07-12 09:30:10.063784+00
2afea6c2-1ae7-4929-a45d-4a8a855c5102	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 09:31:10.064196+00	2026-07-12 09:31:10.064196+00
cfed701b-a7b6-4fdc-ae7c-4412e95e2f9e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:32:10.06373+00	2026-07-12 09:32:10.06373+00
0f0574bb-67aa-4f00-9c4a-55c21ccbacfc	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:33:10.064128+00	2026-07-12 09:33:10.064128+00
3836cf93-f8c4-42c8-9227-90e3a7c8a115	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 09:34:10.063914+00	2026-07-12 09:34:10.063914+00
7c69978b-e1eb-471f-bb3f-707d4d2d369d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 09:35:10.064089+00	2026-07-12 09:35:10.064089+00
b2e98c66-3880-42a3-b975-ee896dc5c293	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:38:10.063716+00	2026-07-12 09:38:10.063716+00
8e602f99-2ea1-4a90-b8d8-068fdc0f9dc3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:39:10.06443+00	2026-07-12 09:39:10.06443+00
57538520-16d1-4740-b982-a9fa7945c63d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:40:10.064014+00	2026-07-12 09:40:10.064014+00
27d8b4a2-e77f-46de-84a2-dab78ef5a490	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:41:10.063418+00	2026-07-12 09:41:10.063418+00
b87eb8fe-93ef-4585-b7b8-90bd61cc348a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:42:10.064165+00	2026-07-12 09:42:10.064165+00
20da447d-6f7e-41a5-8aad-db85dd57fcc8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 09:43:10.06414+00	2026-07-12 09:43:10.06414+00
02fa794c-0192-476d-a04b-4502b84376f5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:44:10.063859+00	2026-07-12 09:44:10.063859+00
1d558d47-4b62-43d0-8cd0-4fdb7636c1d5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:45:10.064459+00	2026-07-12 09:45:10.064459+00
dfcc97d2-3091-4bd7-8a9e-31d18e496a04	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:46:10.064066+00	2026-07-12 09:46:10.064066+00
62f11b8f-8c7f-4405-b04b-c3b8ca437b17	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:48:10.063966+00	2026-07-12 09:48:10.063966+00
7e867aa2-b1b9-497d-82a5-05c62399781e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:49:10.064235+00	2026-07-12 09:49:10.064235+00
e69b32d4-95f0-4aeb-8b24-225ed3b6af43	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:50:10.064076+00	2026-07-12 09:50:10.064076+00
907f4087-945d-4e14-b00e-1015534914d5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:51:10.065201+00	2026-07-12 09:51:10.065201+00
7c9771af-9ae8-4a2c-aa9b-55ed26fa7063	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:52:10.063734+00	2026-07-12 09:52:10.063734+00
143f1f1c-2036-46a7-8a45-4614e951e1cd	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:53:10.063695+00	2026-07-12 09:53:10.063695+00
342b746a-da77-45af-ab39-55efe439d3c0	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:54:10.063771+00	2026-07-12 09:54:10.063771+00
16a139dd-f177-4c73-a84e-9203089dcf96	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:57:10.064543+00	2026-07-12 09:57:10.064543+00
24e2b28e-8005-4618-9a0f-b15b6ef6d58a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:58:10.064889+00	2026-07-12 09:58:10.064889+00
ba91dc1b-90c7-4895-bfe1-a6575b7ba212	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 09:59:10.064436+00	2026-07-12 09:59:10.064436+00
8e449d45-e506-4a8e-8db8-3b582c804caa	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:42:36.752942+00	2026-07-12 16:42:36.752942+00
7b9bc0e9-8a97-44d6-9264-8694cd071f03	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:43:36.755871+00	2026-07-12 16:43:36.755871+00
f00cef37-d942-4152-8782-943c6e0ccbaf	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:44:36.753477+00	2026-07-12 16:44:36.753477+00
f022be8a-af32-43de-96aa-99e0428cdeca	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:45:36.752045+00	2026-07-12 16:45:36.752045+00
5286aa0a-4c3d-4e33-8b96-1a41081fc343	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:46:36.753147+00	2026-07-12 16:46:36.753147+00
22a4c292-f15e-44ac-ae96-fe53f93c7109	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:47:36.753214+00	2026-07-12 16:47:36.753214+00
d6ae2f21-c430-499a-a895-27972e7e1792	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:48:36.771563+00	2026-07-12 16:48:36.771563+00
9c0c0adf-0723-4066-8e85-07ee4841a630	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:49:36.757701+00	2026-07-12 16:49:36.757701+00
5ac5ae93-f3b8-4492-9716-7292cced02e4	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:50:36.756167+00	2026-07-12 16:50:36.756167+00
9ba4719d-4172-4f77-886f-b7b5f183da8b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:51:36.752592+00	2026-07-12 16:51:36.752592+00
297b84ed-4b17-42d1-9751-6bf5f40141e7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:52:36.752827+00	2026-07-12 16:52:36.752827+00
ec02c6ec-bd3b-4512-93a1-e165036b1bb2	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:53:36.752258+00	2026-07-12 16:53:36.752258+00
033545e3-cabd-4e5e-a512-73fba39151bb	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:54:36.752276+00	2026-07-12 16:54:36.752276+00
44d7c22b-8721-4493-9779-42dfe4efe254	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:55:36.75245+00	2026-07-12 16:55:36.75245+00
fdd56d6c-133c-4699-91dd-7f61400be8da	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:56:36.752638+00	2026-07-12 16:56:36.752638+00
160a412a-92f0-4074-9b26-da6bb7249cca	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:57:36.752556+00	2026-07-12 16:57:36.752556+00
7b66bae0-6f85-412a-ba4f-e7cf93049c61	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:58:36.752499+00	2026-07-12 16:58:36.752499+00
29d9e6c6-4f86-4f75-ae28-b0f95c81626a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 16:59:36.753069+00	2026-07-12 16:59:36.753069+00
cea7412d-ff79-4901-9a27-89018193c7f3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:00:36.752539+00	2026-07-12 17:00:36.752539+00
bcf5123d-1c50-438f-8266-482111e4e7e8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:01:36.754933+00	2026-07-12 17:01:36.754933+00
3935bfa5-d0a0-4c88-a744-5548e7929ea7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:02:36.75288+00	2026-07-12 17:02:36.75288+00
6de32cba-de1b-422c-b3f5-1d4778361a18	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 17:03:36.752591+00	2026-07-12 17:03:36.752591+00
25df15ef-69a0-4fc8-be7a-ef686a516473	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:04:36.756022+00	2026-07-12 17:04:36.756022+00
7dbd2aec-d536-43f2-9a1d-842a05b53d44	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 17:05:36.758305+00	2026-07-12 17:05:36.758305+00
bc1ba8df-09bd-4e33-b0d8-f6ed10425b4d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:06:36.752357+00	2026-07-12 17:06:36.752357+00
e7384a74-ee97-47b8-9b66-91d2051165a8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:07:36.753788+00	2026-07-12 17:07:36.753788+00
611212ab-cd85-4d1d-b641-eb138fde12fc	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:08:36.754459+00	2026-07-12 17:08:36.754459+00
3d488bcb-2857-4e24-a3d5-070a21acd677	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:09:36.753304+00	2026-07-12 17:09:36.753304+00
df409d6c-b668-4562-9f67-9f3f7ba81c21	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:10:36.762605+00	2026-07-12 17:10:36.762605+00
84d2f744-ed4e-49cc-a91a-fa331b8f06a4	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:11:36.753435+00	2026-07-12 17:11:36.753435+00
c0466e6e-7dee-47b8-808c-52736d191f56	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 17:13:36.754946+00	2026-07-12 17:13:36.754946+00
84a540a7-c41a-4bd4-9ac8-ef9b98819020	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:14:36.753626+00	2026-07-12 17:14:36.753626+00
ac5840c5-f60a-4674-a78b-c25974efa2cd	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:15:36.754041+00	2026-07-12 17:15:36.754041+00
e731dece-2787-46e8-b238-d48a982619e3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:16:36.753217+00	2026-07-12 17:16:36.753217+00
6dd208e9-1044-4ba4-aae2-c0363acdebac	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:17:36.752876+00	2026-07-12 17:17:36.752876+00
3ae69e62-7aeb-4965-8500-9b1687f33191	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:18:36.753208+00	2026-07-12 17:18:36.753208+00
578c49ca-bf50-47f5-8564-97486c5de059	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:19:36.785052+00	2026-07-12 17:19:36.785052+00
a646e021-bf0c-430a-a009-a6ccec9a394b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:20:36.752894+00	2026-07-12 17:20:36.752894+00
d835ddf2-37e1-4b5f-9183-fa8852e56d84	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:21:36.754233+00	2026-07-12 17:21:36.754233+00
2f0b94fa-2631-4c3f-bd8a-4dc34ddc5cef	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:22:36.75334+00	2026-07-12 17:22:36.75334+00
34c886b6-d287-4360-90c5-46cf0a6b8bfa	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:23:36.753755+00	2026-07-12 17:23:36.753755+00
19e5fd36-de0f-4272-a27b-263985f3c964	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:24:36.753789+00	2026-07-12 17:24:36.753789+00
6d06f3a2-e8fc-40e0-9c66-0ce65e057921	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:25:36.753249+00	2026-07-12 17:25:36.753249+00
5e34ee33-54fb-469f-b185-b220622913af	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:26:36.758579+00	2026-07-12 17:26:36.758579+00
ae086ab3-b3e9-4c4a-86c1-d1207406e92a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:27:36.753402+00	2026-07-12 17:27:36.753402+00
2742e897-899d-4cfd-8025-3fca8d303d95	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:28:36.753126+00	2026-07-12 17:28:36.753126+00
19ffe4e7-44e8-4d08-8dae-008227dcb0cc	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:29:36.753216+00	2026-07-12 17:29:36.753216+00
b453c110-1b15-4d95-8a4e-33cc53e35666	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:30:36.753597+00	2026-07-12 17:30:36.753597+00
4d730998-1adc-4397-a732-7eb2da69239f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:31:36.753654+00	2026-07-12 17:31:36.753654+00
8c3becb5-d0e8-47ba-a4df-8a19c75bfba0	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:32:36.754011+00	2026-07-12 17:32:36.754011+00
222703a5-7567-4948-9330-24b7b519f8c0	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:33:36.754943+00	2026-07-12 17:33:36.754943+00
926a56df-addd-4aab-837e-d7f7cc20de2c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:34:36.754888+00	2026-07-12 17:34:36.754888+00
b973cbdf-c323-44d8-a0a4-5d9c7b55aaf1	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:35:36.753547+00	2026-07-12 17:35:36.753547+00
3a746db6-1614-4859-8711-3d21b3596963	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:36:36.753224+00	2026-07-12 17:36:36.753224+00
138ea437-2c1c-406a-8320-e7d7a8cacfe2	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:37:36.753416+00	2026-07-12 17:37:36.753416+00
cc76d88b-effd-4e62-9d8a-f45e2f48b90c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:38:36.753726+00	2026-07-12 17:38:36.753726+00
6ceb0282-1dfc-4415-845a-62e1674ea2c3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:39:36.754006+00	2026-07-12 17:39:36.754006+00
bb361991-1314-4ccc-8a16-6c4773566f2e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:40:36.763537+00	2026-07-12 17:40:36.763537+00
258f2831-af70-43dd-9bb1-cbd763044c46	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:41:36.753886+00	2026-07-12 17:41:36.753886+00
901d1753-8b25-43b4-b3ad-536c23efc613	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 17:42:36.758652+00	2026-07-12 17:42:36.758652+00
decd8758-1d86-41fc-abaf-0e29a61b21cf	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 18:52:36.758911+00	2026-07-12 18:52:36.758911+00
9cffa912-f72d-4fac-8525-072d16849306	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 18:53:36.83279+00	2026-07-12 18:53:36.83279+00
59ef7145-5f8f-4c0f-8092-45beb78029c8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 18:54:36.817018+00	2026-07-12 18:54:36.817018+00
f422561e-3c07-4873-a58c-41bc1db35a86	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 18:55:36.758419+00	2026-07-12 18:55:36.758419+00
cdfa318d-0c5b-4fba-a325-bc70f911b681	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 18:56:36.758059+00	2026-07-12 18:56:36.758059+00
5b8cc280-ffde-4cf9-9899-82f353caa297	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 18:57:36.767552+00	2026-07-12 18:57:36.767552+00
226ab1df-6c91-4862-b60e-e86869b8d168	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 18:58:36.764766+00	2026-07-12 18:58:36.764766+00
f63d91d6-e43d-4813-b1c0-676edc5a31bf	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 18:59:36.843672+00	2026-07-12 18:59:36.843672+00
2136cf96-6218-44c4-b25a-eca580f0d2d3	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:01:36.758759+00	2026-07-12 19:01:36.758759+00
783a0613-1617-4fb9-90f4-f545e3366797	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:02:36.758654+00	2026-07-12 19:02:36.758654+00
10c9ff2a-bf4a-4d51-9bfd-0e1db6e17cc1	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 19:03:36.774351+00	2026-07-12 19:03:36.774351+00
f3fca5f6-2a96-4524-b98f-572cbe253109	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:04:36.792747+00	2026-07-12 19:04:36.792747+00
723999c4-faaa-4901-a86b-a94105bb3e86	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:05:36.758607+00	2026-07-12 19:05:36.758607+00
7ecda399-d806-4f2f-a2ed-c9d58f3bdbb5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:06:36.782921+00	2026-07-12 19:06:36.782921+00
ee088828-aef0-4b2c-a795-4f99efa4e385	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:07:36.761672+00	2026-07-12 19:07:36.761672+00
1086d66a-d4ae-4f27-94e1-49cc05abc953	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:08:36.758252+00	2026-07-12 19:08:36.758252+00
dfee0880-c172-4d59-96fc-35b5c7c8bc99	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:09:36.758846+00	2026-07-12 19:09:36.758846+00
f39dea19-f879-4d48-9db5-b171d5fc3f77	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:10:36.786165+00	2026-07-12 19:10:36.786165+00
39237424-084d-4fbd-ac28-6f6a569a7e27	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:11:36.760591+00	2026-07-12 19:11:36.760591+00
89272b13-9a77-4396-a2c4-3a39c44bef2f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:12:36.763726+00	2026-07-12 19:12:36.763726+00
675a1136-4afa-4582-acc0-e1cf8491c756	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:13:36.759561+00	2026-07-12 19:13:36.759561+00
62994831-5d15-410b-89f3-d7ff7c9af910	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:14:36.758986+00	2026-07-12 19:14:36.758986+00
b433a01a-7746-4ea3-b639-d295b608aa5b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:15:36.758303+00	2026-07-12 19:15:36.758303+00
2f4ff3d0-95da-4735-b25d-36d77fd60a2a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:16:36.772557+00	2026-07-12 19:16:36.772557+00
b480ced5-afdf-4834-8de4-f4d29f054ef8	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:17:36.784487+00	2026-07-12 19:17:36.784487+00
af64b7c3-4717-4e59-b309-9aad54a430a4	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:18:36.759548+00	2026-07-12 19:18:36.759548+00
6fdc4741-9c6a-4582-abc6-af5599cbc388	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:19:36.806962+00	2026-07-12 19:19:36.806962+00
e007f555-3876-4fe8-876f-551cc8ece11c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:20:36.761593+00	2026-07-12 19:20:36.761593+00
4168f608-2537-4269-9dfb-ee03d8a71144	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:21:36.759129+00	2026-07-12 19:21:36.759129+00
cc292c55-d535-4c03-95d6-2aa28b4b506a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:22:36.758954+00	2026-07-12 19:22:36.758954+00
fa1992be-2d0e-413d-9934-6d48cffe49f1	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:23:36.761368+00	2026-07-12 19:23:36.761368+00
c569f46a-a573-4fb8-a447-d37e76a43fb5	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:24:36.798305+00	2026-07-12 19:24:36.798305+00
ecb6e43e-bce9-43ee-9233-3960684bb88d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:26:36.798865+00	2026-07-12 19:26:36.798865+00
f1333b32-7683-47c5-aca6-81283c387f05	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 19:27:36.758524+00	2026-07-12 19:27:36.758524+00
d1ccce04-d70a-4e8c-b855-360b446f8669	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:28:36.762708+00	2026-07-12 19:28:36.762708+00
54cf8adf-a0b5-4079-a338-7eb3995bb500	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:29:36.763142+00	2026-07-12 19:29:36.763142+00
48cb83e9-5f8d-4eb8-bba0-da8a3a01a004	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 19:30:36.791027+00	2026-07-12 19:30:36.791027+00
20c8f1f9-3cd3-46e5-95b0-ee21a7f3c7a2	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:31:36.830133+00	2026-07-12 19:31:36.830133+00
28e7f489-8956-44bf-966d-8dd45ada6f65	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:33:36.772879+00	2026-07-12 19:33:36.772879+00
64e65671-515c-4667-9a0d-be10b3be4bb6	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:34:36.761389+00	2026-07-12 19:34:36.761389+00
c88a5b27-20f5-455e-9ab1-962d2862f37e	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:35:36.791073+00	2026-07-12 19:35:36.791073+00
b82f9324-f3a5-4ebd-bc5e-00840c719a2f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:36:36.759323+00	2026-07-12 19:36:36.759323+00
d78f3d29-ad8d-498b-9844-1d42a2fdcdc7	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:37:36.759259+00	2026-07-12 19:37:36.759259+00
48a370e8-8a70-4dcf-b91e-c7170071ef50	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:38:36.760431+00	2026-07-12 19:38:36.760431+00
e35807f1-9861-4082-8445-e9e04501041b	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:39:36.759583+00	2026-07-12 19:39:36.759583+00
ec6689da-eced-4a8d-9c51-8b2841f8434c	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:40:36.759571+00	2026-07-12 19:40:36.759571+00
c00c529a-4162-43dc-ad5b-ae70993329a9	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:41:36.759518+00	2026-07-12 19:41:36.759518+00
43fe815f-b309-4631-b3b3-0c17d3ac83a4	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:42:36.774034+00	2026-07-12 19:42:36.774034+00
0a2fedcd-11d4-4b30-b4f0-d617bd7faa1d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:43:36.759731+00	2026-07-12 19:43:36.759731+00
2a7c93a2-a878-4c70-a06c-c070e9f62656	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:44:36.767131+00	2026-07-12 19:44:36.767131+00
e09ac4f6-0504-474d-bd5e-bb1fb8ec5a3d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:45:36.776266+00	2026-07-12 19:45:36.776266+00
bb0cfca3-629e-4b63-bc54-5c489976ce2a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:46:36.760042+00	2026-07-12 19:46:36.760042+00
a4e0d47a-9faf-43a7-8cd1-1ea3bdb12a7f	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 19:47:36.764434+00	2026-07-12 19:47:36.764434+00
48d9bfde-bcaa-4dbd-ae64-230a6d9e726a	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:48:36.76201+00	2026-07-12 19:48:36.76201+00
9c320b60-c32a-423c-9d9f-c1a9ecc2ca28	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	99.99999999999999	99.9	f	60	PROMETHEUS	2026-07-12 19:49:36.815966+00	2026-07-12 19:49:36.815966+00
82da96d2-d2a4-49c8-8dfd-49ee0941cedf	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:50:36.760746+00	2026-07-12 19:50:36.760746+00
60b0d1be-a85e-4c23-aa2a-f2c9d3e57e00	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:51:36.762094+00	2026-07-12 19:51:36.762094+00
bb85f8b8-cb67-4d86-a351-a28aede3a41d	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:52:36.761021+00	2026-07-12 19:52:36.761021+00
f81676c2-644d-46d0-b483-a94eb3d0c090	4b572d35-cb52-47f2-9b91-f98577ade93a	79a28492-b0d4-4098-94ce-70c4df2785cd	AVAILABILITY	100	99.9	f	60	PROMETHEUS	2026-07-12 19:54:36.760226+00	2026-07-12 19:54:36.760226+00
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (user_id, role_id) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, full_name, is_active, created_at) FROM stdin;
\.


--
-- Name: analysis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.analysis_id_seq', 3, true);


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.logs_id_seq', 78, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: analysis analysis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis
    ADD CONSTRAINT analysis_pkey PRIMARY KEY (id);


--
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);


--
-- Name: consumer_checkpoints consumer_checkpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumer_checkpoints
    ADD CONSTRAINT consumer_checkpoints_pkey PRIMARY KEY (id);


--
-- Name: dead_letter_events dead_letter_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dead_letter_events
    ADD CONSTRAINT dead_letter_events_pkey PRIMARY KEY (id);


--
-- Name: deployment_revisions deployment_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_revisions
    ADD CONSTRAINT deployment_revisions_pkey PRIMARY KEY (id);


--
-- Name: deployments deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_pkey PRIMARY KEY (id);


--
-- Name: environments environments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_pkey PRIMARY KEY (id);


--
-- Name: error_budget_statuses error_budget_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.error_budget_statuses
    ADD CONSTRAINT error_budget_statuses_pkey PRIMARY KEY (id);


--
-- Name: event_records event_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_records
    ADD CONSTRAINT event_records_pkey PRIMARY KEY (id);


--
-- Name: incident_alert_links incident_alert_links_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_alert_links
    ADD CONSTRAINT incident_alert_links_pkey PRIMARY KEY (id);


--
-- Name: incident_assignments incident_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_assignments
    ADD CONSTRAINT incident_assignments_pkey PRIMARY KEY (id);


--
-- Name: incident_comments incident_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_comments
    ADD CONSTRAINT incident_comments_pkey PRIMARY KEY (id);


--
-- Name: incident_events incident_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_events
    ADD CONSTRAINT incident_events_pkey PRIMARY KEY (id);


--
-- Name: incident_metrics incident_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_metrics
    ADD CONSTRAINT incident_metrics_pkey PRIMARY KEY (id);


--
-- Name: incident_timeline_events incident_timeline_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_timeline_events
    ADD CONSTRAINT incident_timeline_events_pkey PRIMARY KEY (id);


--
-- Name: incidents incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);


--
-- Name: kubernetes_workloads kubernetes_workloads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kubernetes_workloads
    ADD CONSTRAINT kubernetes_workloads_pkey PRIMARY KEY (id);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: outbox_events outbox_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outbox_events
    ADD CONSTRAINT outbox_events_pkey PRIMARY KEY (id);


--
-- Name: pipeline_runs pipeline_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_runs
    ADD CONSTRAINT pipeline_runs_pkey PRIMARY KEY (id);


--
-- Name: pipelines pipelines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipelines
    ADD CONSTRAINT pipelines_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: reliability_alerts reliability_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reliability_alerts
    ADD CONSTRAINT reliability_alerts_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: service_health_snapshots service_health_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_health_snapshots
    ADD CONSTRAINT service_health_snapshots_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: slo_definitions slo_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slo_definitions
    ADD CONSTRAINT slo_definitions_pkey PRIMARY KEY (id);


--
-- Name: slo_measurements slo_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slo_measurements
    ADD CONSTRAINT slo_measurements_pkey PRIMARY KEY (id);


--
-- Name: consumer_checkpoints uq_consumer_topic_partition; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumer_checkpoints
    ADD CONSTRAINT uq_consumer_topic_partition UNIQUE (consumer_name, topic, partition);


--
-- Name: incident_alert_links uq_incident_alert_link; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_alert_links
    ADD CONSTRAINT uq_incident_alert_link UNIQUE (incident_id, reliability_alert_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_analysis_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_analysis_id ON public.analysis USING btree (id);


--
-- Name: ix_dead_letter_events_correlation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_dead_letter_events_correlation_id ON public.dead_letter_events USING btree (correlation_id);


--
-- Name: ix_dead_letter_events_environment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_dead_letter_events_environment ON public.dead_letter_events USING btree (environment);


--
-- Name: ix_dead_letter_events_event_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_dead_letter_events_event_id ON public.dead_letter_events USING btree (event_id);


--
-- Name: ix_dead_letter_events_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_dead_letter_events_event_type ON public.dead_letter_events USING btree (event_type);


--
-- Name: ix_dead_letter_events_service_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_dead_letter_events_service_id ON public.dead_letter_events USING btree (service_id);


--
-- Name: ix_dead_letter_events_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_dead_letter_events_status ON public.dead_letter_events USING btree (status);


--
-- Name: ix_dead_letter_events_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_dead_letter_events_topic ON public.dead_letter_events USING btree (topic);


--
-- Name: ix_error_budget_statuses_evaluated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_error_budget_statuses_evaluated_at ON public.error_budget_statuses USING btree (evaluated_at);


--
-- Name: ix_error_budget_statuses_service_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_error_budget_statuses_service_id ON public.error_budget_statuses USING btree (service_id);


--
-- Name: ix_error_budget_statuses_slo_definition_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_error_budget_statuses_slo_definition_id ON public.error_budget_statuses USING btree (slo_definition_id);


--
-- Name: ix_event_records_correlation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_event_records_correlation_id ON public.event_records USING btree (correlation_id);


--
-- Name: ix_event_records_environment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_event_records_environment ON public.event_records USING btree (environment);


--
-- Name: ix_event_records_event_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_event_records_event_id ON public.event_records USING btree (event_id);


--
-- Name: ix_event_records_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_event_records_event_type ON public.event_records USING btree (event_type);


--
-- Name: ix_event_records_processing_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_event_records_processing_status ON public.event_records USING btree (processing_status);


--
-- Name: ix_event_records_release_timeline; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_event_records_release_timeline ON public.event_records USING btree (correlation_id, "timestamp");


--
-- Name: ix_event_records_service_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_event_records_service_id ON public.event_records USING btree (service_id);


--
-- Name: ix_event_records_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_event_records_timestamp ON public.event_records USING btree ("timestamp");


--
-- Name: ix_event_records_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_event_records_topic ON public.event_records USING btree (topic);


--
-- Name: ix_incident_alert_links_incident_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_alert_links_incident_id ON public.incident_alert_links USING btree (incident_id);


--
-- Name: ix_incident_alert_links_reliability_alert_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_alert_links_reliability_alert_id ON public.incident_alert_links USING btree (reliability_alert_id);


--
-- Name: ix_incident_assignments_incident_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_assignments_incident_id ON public.incident_assignments USING btree (incident_id);


--
-- Name: ix_incident_comments_incident_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_comments_incident_id ON public.incident_comments USING btree (incident_id);


--
-- Name: ix_incident_events_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_events_event_type ON public.incident_events USING btree (event_type);


--
-- Name: ix_incident_events_incident_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_events_incident_id ON public.incident_events USING btree (incident_id);


--
-- Name: ix_incident_metrics_incident_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_metrics_incident_id ON public.incident_metrics USING btree (incident_id);


--
-- Name: ix_incident_timeline_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_timeline_event_type ON public.incident_timeline_events USING btree (event_type);


--
-- Name: ix_incident_timeline_incident_occurred_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_timeline_incident_occurred_id ON public.incident_timeline_events USING btree (incident_id, occurred_at, id);


--
-- Name: ix_incidents_correlation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incidents_correlation_id ON public.incidents USING btree (correlation_id);


--
-- Name: ix_incidents_environment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incidents_environment ON public.incidents USING btree (environment);


--
-- Name: ix_incidents_service_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incidents_service_id ON public.incidents USING btree (service_id);


--
-- Name: ix_incidents_severity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incidents_severity ON public.incidents USING btree (severity);


--
-- Name: ix_incidents_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incidents_status ON public.incidents USING btree (status);


--
-- Name: ix_incidents_triggered_by_event_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incidents_triggered_by_event_id ON public.incidents USING btree (triggered_by_event_id);


--
-- Name: ix_logs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_logs_id ON public.logs USING btree (id);


--
-- Name: ix_outbox_events_correlation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_outbox_events_correlation_id ON public.outbox_events USING btree (correlation_id);


--
-- Name: ix_outbox_events_environment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_outbox_events_environment ON public.outbox_events USING btree (environment);


--
-- Name: ix_outbox_events_event_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_outbox_events_event_id ON public.outbox_events USING btree (event_id);


--
-- Name: ix_outbox_events_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_outbox_events_event_type ON public.outbox_events USING btree (event_type);


--
-- Name: ix_outbox_events_service_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_outbox_events_service_id ON public.outbox_events USING btree (service_id);


--
-- Name: ix_outbox_events_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_outbox_events_status ON public.outbox_events USING btree (status);


--
-- Name: ix_outbox_events_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_outbox_events_topic ON public.outbox_events USING btree (topic);


--
-- Name: ix_pipeline_runs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pipeline_runs_id ON public.pipeline_runs USING btree (id);


--
-- Name: ix_pipelines_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pipelines_id ON public.pipelines USING btree (id);


--
-- Name: ix_reliability_alerts_deployment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_reliability_alerts_deployment_id ON public.reliability_alerts USING btree (deployment_id);


--
-- Name: ix_reliability_alerts_service_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_reliability_alerts_service_id ON public.reliability_alerts USING btree (service_id);


--
-- Name: ix_reliability_alerts_slo_definition_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_reliability_alerts_slo_definition_id ON public.reliability_alerts USING btree (slo_definition_id);


--
-- Name: ix_roles_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_roles_name ON public.roles USING btree (name);


--
-- Name: ix_service_health_snapshots_service_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_service_health_snapshots_service_id ON public.service_health_snapshots USING btree (service_id);


--
-- Name: ix_service_health_snapshots_service_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_service_health_snapshots_service_name ON public.service_health_snapshots USING btree (service_name);


--
-- Name: ix_slo_definitions_service_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_slo_definitions_service_id ON public.slo_definitions USING btree (service_id);


--
-- Name: ix_slo_measurements_evaluated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_slo_measurements_evaluated_at ON public.slo_measurements USING btree (evaluated_at);


--
-- Name: ix_slo_measurements_service_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_slo_measurements_service_id ON public.slo_measurements USING btree (service_id);


--
-- Name: ix_slo_measurements_slo_definition_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_slo_measurements_slo_definition_id ON public.slo_measurements USING btree (slo_definition_id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: analysis analysis_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis
    ADD CONSTRAINT analysis_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES public.pipelines(id);


--
-- Name: audit_events audit_events_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_events
    ADD CONSTRAINT audit_events_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: deployment_revisions deployment_revisions_deployment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_revisions
    ADD CONSTRAINT deployment_revisions_deployment_id_fkey FOREIGN KEY (deployment_id) REFERENCES public.deployments(id);


--
-- Name: deployments deployments_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environments(id);


--
-- Name: deployments deployments_pipeline_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_pipeline_run_id_fkey FOREIGN KEY (pipeline_run_id) REFERENCES public.pipeline_runs(id);


--
-- Name: deployments deployments_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: environments environments_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: error_budget_statuses error_budget_statuses_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.error_budget_statuses
    ADD CONSTRAINT error_budget_statuses_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;


--
-- Name: error_budget_statuses error_budget_statuses_slo_definition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.error_budget_statuses
    ADD CONSTRAINT error_budget_statuses_slo_definition_id_fkey FOREIGN KEY (slo_definition_id) REFERENCES public.slo_definitions(id) ON DELETE CASCADE;


--
-- Name: incident_alert_links incident_alert_links_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_alert_links
    ADD CONSTRAINT incident_alert_links_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incidents(id) ON DELETE CASCADE;


--
-- Name: incident_alert_links incident_alert_links_reliability_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_alert_links
    ADD CONSTRAINT incident_alert_links_reliability_alert_id_fkey FOREIGN KEY (reliability_alert_id) REFERENCES public.reliability_alerts(id) ON DELETE CASCADE;


--
-- Name: incident_assignments incident_assignments_assigned_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_assignments
    ADD CONSTRAINT incident_assignments_assigned_by_user_id_fkey FOREIGN KEY (assigned_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: incident_assignments incident_assignments_assigned_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_assignments
    ADD CONSTRAINT incident_assignments_assigned_to_user_id_fkey FOREIGN KEY (assigned_to_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: incident_assignments incident_assignments_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_assignments
    ADD CONSTRAINT incident_assignments_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incidents(id) ON DELETE CASCADE;


--
-- Name: incident_comments incident_comments_author_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_comments
    ADD CONSTRAINT incident_comments_author_user_id_fkey FOREIGN KEY (author_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: incident_comments incident_comments_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_comments
    ADD CONSTRAINT incident_comments_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incidents(id) ON DELETE CASCADE;


--
-- Name: incident_events incident_events_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_events
    ADD CONSTRAINT incident_events_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incidents(id) ON DELETE CASCADE;


--
-- Name: incident_metrics incident_metrics_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_metrics
    ADD CONSTRAINT incident_metrics_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incidents(id) ON DELETE CASCADE;


--
-- Name: incident_timeline_events incident_timeline_events_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_timeline_events
    ADD CONSTRAINT incident_timeline_events_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: incident_timeline_events incident_timeline_events_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_timeline_events
    ADD CONSTRAINT incident_timeline_events_alert_id_fkey FOREIGN KEY (alert_id) REFERENCES public.reliability_alerts(id) ON DELETE SET NULL;


--
-- Name: incident_timeline_events incident_timeline_events_deployment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_timeline_events
    ADD CONSTRAINT incident_timeline_events_deployment_id_fkey FOREIGN KEY (deployment_id) REFERENCES public.deployments(id) ON DELETE SET NULL;


--
-- Name: incident_timeline_events incident_timeline_events_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_timeline_events
    ADD CONSTRAINT incident_timeline_events_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incidents(id) ON DELETE CASCADE;


--
-- Name: kubernetes_workloads kubernetes_workloads_deployment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kubernetes_workloads
    ADD CONSTRAINT kubernetes_workloads_deployment_id_fkey FOREIGN KEY (deployment_id) REFERENCES public.deployments(id);


--
-- Name: logs logs_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES public.pipelines(id);


--
-- Name: pipeline_runs pipeline_runs_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_runs
    ADD CONSTRAINT pipeline_runs_repo_id_fkey FOREIGN KEY (repo_id) REFERENCES public.repositories(id);


--
-- Name: pipeline_runs pipeline_runs_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_runs
    ADD CONSTRAINT pipeline_runs_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: projects projects_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: reliability_alerts reliability_alerts_deployment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reliability_alerts
    ADD CONSTRAINT reliability_alerts_deployment_id_fkey FOREIGN KEY (deployment_id) REFERENCES public.deployments(id) ON DELETE SET NULL;


--
-- Name: reliability_alerts reliability_alerts_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reliability_alerts
    ADD CONSTRAINT reliability_alerts_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;


--
-- Name: reliability_alerts reliability_alerts_slo_definition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reliability_alerts
    ADD CONSTRAINT reliability_alerts_slo_definition_id_fkey FOREIGN KEY (slo_definition_id) REFERENCES public.slo_definitions(id) ON DELETE CASCADE;


--
-- Name: repositories repositories_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: service_health_snapshots service_health_snapshots_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_health_snapshots
    ADD CONSTRAINT service_health_snapshots_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: services services_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: slo_definitions slo_definitions_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slo_definitions
    ADD CONSTRAINT slo_definitions_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;


--
-- Name: slo_measurements slo_measurements_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slo_measurements
    ADD CONSTRAINT slo_measurements_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;


--
-- Name: slo_measurements slo_measurements_slo_definition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slo_measurements
    ADD CONSTRAINT slo_measurements_slo_definition_id_fkey FOREIGN KEY (slo_definition_id) REFERENCES public.slo_definitions(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 2f6w1ESuMkGhphLORZrJasChj6J7M5KPlibjW8xR8mQTIU1R2g7cPm0QHo33NU1

