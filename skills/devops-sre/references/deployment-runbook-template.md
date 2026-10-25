# Deployment & SRE Operations Runbook (`DEPLOYMENT_RUNBOOK.md`)

## 1. Deployment Target & Topology
- **Active Bottega Profile**: `spark` | `forge` | `citadel`
- **Target Environment**: `<e.g., Docker Compose on VPS / Google Cloud Run / Fly.io>`
- **Runtime & Base Image**: `<e.g., node:22-bookworm-slim (non-root user 10001)>`

## 2. Environment Variables & Secrets Inventory
> Never commit real secret values. Configure these in your hosting Secret Manager or `.env` (excluded via `.gitignore` and `.dockerignore`).

| Variable Name | Required | Secret? | Example / Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `NODE_ENV` / `APP_ENV` | Yes | No | `production` | Runtime environment mode |
| `PORT` | Yes | No | `8080` | HTTP listening port |
| `DATABASE_URL` | Yes | **YES** | `postgresql://...` | Primary database connection string |
| `SESSION_SECRET` | Yes | **YES** | `<32+ byte hex>` | Cryptographic signing key |

## 3. Pre-Deploy Security & Readiness Checklist
- [ ] Gate 5 (Automated Tests) and Gate 6 (Security Audit & Code Review) are marked `PASS` in `docs/PROJECT_STATE.md`.
- [ ] Container runs as a non-root user (`id -u` != `0`).
- [ ] `.dockerignore` excludes `.env`, `.git`, and local development artifacts.
- [ ] Database migrations are tested and ready to run prior to traffic switch.
- [ ] TLS / HTTPS is enforced at the edge or load balancer.

## 4. Step-by-Step Deployment Procedure
```bash
# 1. Run pre-deploy verification & security scan
# 2. Build production artifact / container image
# 3. Apply database migrations
# 4. Deploy & verify health check (/healthz)
```

## 5. Health Check, Monitoring & Rollback Procedure
- **Health Check Endpoint**: `GET /healthz` $\rightarrow$ `200 OK`
- **Key Logs & Metrics to Monitor**: Error rate (`5xx`), latency (`p95`), auth failure spikes (`401/403`).
- **Emergency Rollback Steps**:
  1. Revert container image / release to previous known-good tag.
  2. If a database migration was applied, execute the backward-compatible down migration or restore from pre-deploy snapshot.
