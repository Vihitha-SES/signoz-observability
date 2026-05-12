# SigNoz — Railway Multi-Service Deployment

This folder contains 4 self-contained service directories, each with its own
`Dockerfile` and `.env.example`.  You can deploy each one as a separate
Railway service by pointing **Root Directory** at the relevant folder.

```
services/
  zookeeper/        ← deploy first
  clickhouse/       ← deploy second
  signoz-otel-collector/   ← deploy third
  signoz/           ← deploy last
```

---

## Deployment order and Railway setup

### Step 1 — Create a Railway project

1. New Project → **Deploy from GitHub repo**
2. Connect this repository

---

### Step 2 — ZooKeeper service

| Setting | Value |
|---|---|
| Root Directory | `services/zookeeper` |
| Exposed port | `2181` |

**Environment variables** (copy from `services/zookeeper/.env.example`):

```
ZOO_SERVER_ID=1
ALLOW_ANONYMOUS_LOGIN=yes
ZOO_AUTOPURGE_INTERVAL=1
ZOO_ENABLE_PROMETHEUS_METRICS=yes
ZOO_PROMETHEUS_METRICS_PORT_NUMBER=9141
```

No public URL needed — only ClickHouse talks to it on the private network.

---

### Step 3 — ClickHouse service

| Setting | Value |
|---|---|
| Root Directory | `services/clickhouse` |
| Exposed port | `9000` (TCP native) and `8123` (HTTP) |

**Environment variables** (copy from `services/clickhouse/.env.example`):

```
ZOOKEEPER_HOST=zookeeper.railway.internal
ZOOKEEPER_PORT=2181
CLICKHOUSE_HOST=clickhouse.railway.internal
CLICKHOUSE_PORT=9000
CLICKHOUSE_SKIP_USER_SETUP=1
```

> **Important**: `zookeeper.railway.internal` and `clickhouse.railway.internal`
> are the Railway private-network hostnames.  Railway assigns them automatically
> using the **service name** you give the service in the dashboard.  Name your
> ZooKeeper service **zookeeper** and your ClickHouse service **clickhouse**
> for the defaults to work.

---

### Step 4 — OTEL Collector service

| Setting | Value |
|---|---|
| Root Directory | `services/signoz-otel-collector` |
| Exposed ports | `4317` (gRPC OTLP), `4318` (HTTP OTLP) |

**Environment variables** (copy from `services/signoz-otel-collector/.env.example`):

```
CLICKHOUSE_TRACES_DSN=tcp://clickhouse.railway.internal:9000/signoz_traces
CLICKHOUSE_METRICS_DSN=tcp://clickhouse.railway.internal:9000/signoz_metrics
CLICKHOUSE_LOGS_DSN=tcp://clickhouse.railway.internal:9000/signoz_logs
CLICKHOUSE_METER_DSN=tcp://clickhouse.railway.internal:9000/signoz_meter
CLICKHOUSE_METADATA_DSN=tcp://clickhouse.railway.internal:9000/signoz_metadata
SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_DSN=tcp://clickhouse.railway.internal:9000
SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_CLUSTER=cluster
SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_REPLICATION=true
SIGNOZ_OTEL_COLLECTOR_TIMEOUT=10m
SIGNOZ_OPAMP_ENDPOINT=ws://signoz.railway.internal:4320/v1/opamp
LOW_CARDINAL_EXCEPTION_GROUPING=false
OTEL_RESOURCE_ATTRIBUTES=host.name=signoz-host,os.type=linux
```

Make sure you name this Railway service **signoz-otel-collector** (or adjust hostnames
accordingly).

---

### Step 5 — SigNoz Backend + Frontend service

| Setting | Value |
|---|---|
| Root Directory | *(leave blank — repo root)* |
| Dockerfile Path | `services/signoz/Dockerfile` |
| Exposed port | `8080` |

> **Why no Root Directory?** The `services/signoz/Dockerfile` copies files from the
> repo root (`go.mod`, `frontend/`, `templates/email`).  Setting Root Directory to
> `services/signoz` restricts the Docker build context to that subdirectory and causes
> `COPY` instructions to fail with "not found" errors.  Leave Root Directory **blank**
> and set only the **Dockerfile Path** to `services/signoz/Dockerfile`.
> In Railway: **Settings → Build → Dockerfile Path**.
i
**Environment variables** (copy from `services/signoz/.env.example`):

```
# Railway will give you this URL after first deploy
SIGNOZ_EXTERNAL_URL=https://signoz-production-xxxx.up.railway.app

SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN=tcp://clickhouse.railway.internal:9000
SIGNOZ_TOKENIZER_JWT_SECRET=change-me-to-strong-random-value
SIGNOZ_SQLSTORE_SQLITE_PATH=/var/lib/signoz/signoz.db
SIGNOZ_ALERTMANAGER_PROVIDER=signoz
```

Railway automatically injects `PORT` — the patched code reads it, so no
manual port configuration is needed.

---

## Private network hostnames cheat-sheet

| Service name in Railway | Private hostname |
|---|---|
| `zookeeper` | `zookeeper.railway.internal` |
| `clickhouse` | `clickhouse.railway.internal` |
| `signoz-otel-collector` | `signoz-otel-collector.railway.internal` |
| `signoz` | `signoz.railway.internal` |

> Railway private hostnames follow the pattern `<service-name>.railway.internal`.
> Name your services exactly as shown above to match the defaults in each
> `.env.example`.

---

## Volumes (persistent data)

Add Railway volumes to the following services:

| Service | Mount path |
|---|---|
| `zookeeper` | `/bitnami/zookeeper` |
| `clickhouse` | `/var/lib/clickhouse` |
| `signoz` | `/var/lib/signoz` |

---

## Sending telemetry to SigNoz

Point your instrumented applications at the OTEL Collector public URL:

```
OTEL_EXPORTER_OTLP_ENDPOINT=https://signoz-otel-collector-production-xxxx.up.railway.app
```

- gRPC OTLP → port `4317`
- HTTP OTLP → port `4318`
