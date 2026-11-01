# Production Docker Verification Checklist

Use this checklist to verify that the Docker configuration is 100% production-ready before handing it over to the user or deploying to the external Docker environment.

---

## 1. Security & Principle of Least Privilege
- [ ] **Non-Root User**: Every application Dockerfile includes a dedicated unprivileged user (`USER appuser` or `USER 10001:10001`) before `ENTRYPOINT`/`CMD`. The container does NOT run as `root`.
- [ ] **No Public Database/Cache Ports**: Database (PostgreSQL, MySQL, MongoDB) and cache (Redis, Memcached) services do **NOT** expose ports on public interfaces (e.g. `5432:5432` or `0.0.0.0:6379:6379`). They are accessible solely through private Docker internal networks.
- [ ] **Zero Hardcoded Secrets**: No passwords, API keys, private tokens, or encryption keys are written in plaintext inside Dockerfiles, `docker-compose.prod.yml`, or build arguments.
- [ ] **Secret Files in `.gitignore`**: `.env`, `.env.production`, `*.pem`, `*.key` are strictly listed in `.gitignore`. Only `.env.production.example` (with dummy values/instructions) is committed.
- [ ] **Hardened `.dockerignore`**: Excludes `.git`, `.env*`, `node_modules`, `.venv`, `tests/`, local docs, and temporary files from the build context.
- [ ] **Pinned Image Tags**: Base images in Dockerfiles and Compose files use specific immutable version tags (e.g. `node:20.11-alpine`, `python:3.12-slim`) rather than `:latest`.

---

## 2. Reliability & Operations
- [ ] **Restart Policy**: All persistent services specify `restart: unless-stopped` or `restart: always` (or swarm equivalent `restart_policy.condition: on-failure`).
- [ ] **Health Checks**: Application services define a `HEALTHCHECK` in Dockerfile or `healthcheck:` in Compose with reasonable interval, timeout, and retries against a `/health` or `/healthz` endpoint.
- [ ] **Log Rotation**: Services define logging drivers with limits to prevent disk exhaustion:
  ```yaml
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
  ```
- [ ] **Resource Constraints**: Production services have CPU and memory limits/reservations configured to protect the host against memory leaks or CPU starvation.
- [ ] **Clean Shutdown / Signals**: Containers handle `SIGTERM` gracefully (e.g. using `exec node ...` or `tini` / dumb-init as init system) to allow zero-downtime rolling restarts.

---

## 3. Network & Storage Architecture
- [ ] **Network Segmentation**: At least two distinct networks exist:
  - `frontend` / `ingress`: Connects the public reverse proxy to web-facing application containers.
  - `backend` / `internal`: Connects application containers to internal services (databases, caches, queues).
- [ ] **No Development Bind-Mounts**: Development hot-reloading bind-mounts (`./src:/app`) are removed. The application code is baked into the immutable image.
- [ ] **Persistent Named Volumes**: Databases and uploads use named Docker volumes (e.g. `postgres_data:/var/lib/postgresql/data`) or verified persistent host directories with correct ownership (`chown 1000:1000`).
- [ ] **Reverse Proxy / TLS**: Public web traffic routes through an automated TLS reverse proxy (Caddy / Traefik / Nginx) with automated Let's Encrypt certificates on ports 80/443.

---

## 4. Syntax & Automated Verification
- [ ] Run automated syntax and rule verification:
  ```bash
  # Validate compose syntax and variables
  docker compose -f docker-compose.prod.yml config

  # Run Bottega Docker verifier script
  ./skills/docker-deploy-adapter/scripts/verify-docker-target.sh docker-compose.prod.yml
  ```

---

## 5. Documentation & Environment Alignment
- [ ] **Deployment Runbook**: `docs/DEPLOYMENT_DOCKER_EXTERNAL.md` accurately reflects the exact compose file, all services, ports, volume backup instructions, and step-by-step deploy commands.
- [ ] **Production Env Template**: `.env.production.example` lists every required production variable with clear instructions and safe placeholder values.
- [ ] **Project State Sync**: `docs/PROJECT_STATE.md` records the active target environment, architecture decisions, and verification sign-off.
- [ ] **Zero Documentation Drift**: No differences exist between the actual compose configuration and the deployment guide.
