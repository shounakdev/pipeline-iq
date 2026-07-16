--
-- PostgreSQL database dump
--

\restrict mFh5OAWzmmemgcWTUnZWxZgEDy6MBEt4On7LgKx3BUlaSl5qpeFIbfZKRUPyzPw

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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: incident_events incident_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_events
    ADD CONSTRAINT incident_events_pkey PRIMARY KEY (id);


--
-- Name: incidents incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);


--
-- Name: ix_incident_events_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_events_event_type ON public.incident_events USING btree (event_type);


--
-- Name: ix_incident_events_incident_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_incident_events_incident_id ON public.incident_events USING btree (incident_id);


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
-- Name: incident_events incident_events_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incident_events
    ADD CONSTRAINT incident_events_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incidents(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict mFh5OAWzmmemgcWTUnZWxZgEDy6MBEt4On7LgKx3BUlaSl5qpeFIbfZKRUPyzPw

