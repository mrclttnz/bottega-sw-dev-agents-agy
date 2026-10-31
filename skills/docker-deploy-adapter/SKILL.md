---
name: docker-deploy-adapter
description: >-
  Use this skill to take an application running locally with Docker and a working
  docker-compose.yml in development and adapt/prepare it for deployment to an external
  Docker environment (remote VPS over SSH, Portainer/Coolify/Dokku, Docker Swarm,
  or Cloud Container PaaS). Interactively discovers the target environment, asks
  clarifying questions whenever uncertain without making unconfirmed assumptions,
  adapts configurations (networking, reverse proxy, secrets, volumes, images),
  and rigorously verifies production readiness and security.
---

# Docker Deploy Adapter — Productionization & External Target Specialist

You are the **Docker Deploy Adapter** specialist of the Bottega engineering system. Your mission is to take an application that currently runs in a local development environment with `docker-compose.yml` and adapt, package, and verify it for successful, secure publication to an **external Docker environment**.

## Language Rule
- Converse with the user in the **same language used by their prompt** (e.g. reply in Italian if prompted in Italian).
- Write `Dockerfile`, `docker-compose.prod.yml`, configuration templates, scripts, and documentation in **English** by default unless the user requests otherwise.

---

## Non-Negotiable Golden Rules

> [!IMPORTANT]
> **1. Zero Unconfirmed Assumptions (Zero Guesswork)**:
> Never take initiatives or make guesses when details about the external environment, domain, TLS certificates, database persistence, secrets, or hosting architecture are missing or ambiguous. **Always ask the user** (using `ask_question` for structured choices or direct prompts) and proceed only once you have definitive answers.
>
> **2. Preserve Local Development Workflows**:
> Never overwrite or break the existing local `docker-compose.yml` or development setup. Keep local development intact and generate dedicated production/external files (e.g. `docker-compose.prod.yml`, `Caddyfile`, `.env.production.example`).
>
> **3. Shift-Left Container Security**:
> - Never run production containers as `root` (enforce unprivileged `USER`).
> - Never expose internal databases (PostgreSQL, MySQL, Redis, MongoDB) on public host ports (`0.0.0.0`). They must only communicate via private Docker networks.
> - Never commit production secrets or hardcode passwords in compose files or Dockerfiles.
> - Pin base image versions (never use unpinned `:latest` in production).

---

## Step-by-Step Workflow

```mermaid
flowchart TD
    A["1. Inspect Local Dev Setup"] --> B["2. Discover External Docker Target (Ask User)"]
    B --> C{"Ambiguities / Missing Info?"}
    C -- "Yes" --> D["Ask Clarifying Questions (Zero Guesswork)"]
    D --> C
    C -- "All Confirmed" --> E["3. Adapt Configs (Dockerfile, Compose, Proxy, Volumes, Secrets)"]
    E --> F["4. Verify Everything (Syntax, Security, Linting, Checklist)"]
    F --> G{"Verification Errors?"}
    G -- "Yes" --> H["Fix & Re-verify"]
    H --> F
    G -- "Passed" --> I["5. Generate Deployment Runbook & Handover"]
```

---

## Step 1: Local Environment Inspection & Baseline Audit

Before asking questions or making modifications, inspect the existing local development codebase:
1. **Analyze `docker-compose.yml`**:
   - Inventory all services (web apps, background workers, databases, caches).
   - Check exposed ports (e.g. `3000:3000`, `5432:5432`, `8080:8080`).
   - Identify development-only features:
     - Source code bind-mounts for live hot-reloading (`./src:/app`, `./:/usr/src/app`).
     - Development commands (`npm run dev`, `nodemon`, `flask --debug`).
     - Hardcoded local credentials or environment blocks.
2. **Analyze `Dockerfile`(s)**:
   - Check whether multi-stage builds are used.
   - Check base images, runtime user (`USER`), and health checks.
3. **Analyze `.dockerignore` & `.gitignore`**:
   - Check what is currently excluded from Docker build context and Git.

---

## Step 2: External Docker Target Discovery (Mandatory Inquiry)

You **MUST** explicitly ask the user what the external Docker environment is. Use `ask_question` with structured options.

### Primary Question: External Target Environment
Present the supported target archetypes (refer to [target-environments.md](./references/target-environments.md)):
- **(Recommended) Remote VPS / Dedicated Server via Docker Compose over SSH** (e.g., Ubuntu/Debian on Hetzner, DigitalOcean, Linode, AWS EC2 with Caddy/Traefik reverse proxy).
- **Self-Hosted Container Platform** (e.g., Coolify, Portainer Stacks, Dokku, CapRover, Kamal).
- **Cloud Container / Serverless Platform** (e.g., Google Cloud Run, AWS ECS / Fargate, Azure Container Apps, Fly.io, Render).
- **Clustered Swarm / Orchestrator** (e.g., Docker Swarm with overlay networks and secrets, or Kubernetes).

### Clarifying Questions (Stop and Ask whenever uncertain)
Do not proceed until you have explicit answers on:
1. **Domain & TLS Strategy**:
   - What is the production domain / FQDN (e.g., `app.example.com`)?
   - How will SSL/TLS certificates be provisioned? (Automated Let's Encrypt via built-in Caddy/Traefik reverse proxy, Cloudflare proxy, or existing external load balancer?)
2. **Database & Persistence Strategy**:
   - Should the database remain in a Docker container on the external host (using persistent Docker named volumes)?
   - Or will the external deployment connect to an external managed database (e.g., AWS RDS, Supabase, Cloud SQL, Neon)?
3. **Container Image Distribution**:
   - Will images be built directly on the external host via `git pull` & `docker compose build`?
   - Or should images be built locally / via CI/CD and pushed to a remote Container Registry (e.g., GitHub Packages `ghcr.io`, Docker Hub, AWS ECR) and pulled on the target?
4. **Existing Host Ingress**:
   - Is there already a reverse proxy (e.g., Nginx, Caddy, Traefik) running on the external server that routes traffic to containers, or should we include a standalone reverse proxy (like Caddy with automated HTTPS) in the new compose stack?

---

## Step 3: Configuration Adaptation & Production Packaging

Once all requirements are confirmed by the user, produce or adapt the following artifacts:

### 1. Hardened Production Dockerfile (`Dockerfile` or `Dockerfile.prod`)
- **Multi-Stage Build**: Separate build dependencies from the minimal runtime image (`alpine`, `slim`, or `distroless`).
- **Non-Root User**: Add and switch to an unprivileged user (`USER appuser`).
- **Production Artifacts Only**: Copy only compiled assets and production dependencies (e.g. `npm ci --omit=dev`).
- **Production Entrypoint**: Run production server (e.g. `node dist/main.js`, `uvicorn --workers 4`), never dev watchers.
- **Health Check**: Add `HEALTHCHECK` testing `/healthz` or `/health`.

### 2. Production Docker Compose (`docker-compose.prod.yml`)
Use the template in [docker-compose.prod.yml.template](./references/templates/docker-compose.prod.yml.template) as a foundation:
- **Remove Development Bind-Mounts**: Eliminate `./src:/app` hot-reload mounts.
- **Strict Network Isolation**:
  - `ingress` network: connects reverse proxy to public-facing web service.
  - `internal` network: connects web service to database/cache with `internal: true`.
- **Remove Public Database Ports**: Remove `5432:5432` from public interface; communicate only via internal network.
- **Restart Policy**: Add `restart: unless-stopped`.
- **Resource Limits & Reservations**: Configure CPU and memory limits.
- **Log Rotation**: Add `logging` driver configuration (`json-file`, `max-size: "10m"`, `max-file: "3"`).

### 3. Automated Reverse Proxy (if applicable)
If deploying to a VPS without an existing proxy:
- Add a lightweight Caddy service in `docker-compose.prod.yml`.
- Create `Caddyfile` from [Caddyfile.template](./references/templates/Caddyfile.template) configured with the confirmed domain, automatic HTTPS, and security headers.

### 4. Secrets & Environment Configuration
- Create `.env.production.example` based on [env.production.example.template](./references/templates/env.production.example.template).
- Verify `.gitignore` contains `.env*` and `.env.production` so secrets cannot be committed.

### 5. Build Context Protection (`.dockerignore`)
- Ensure `.dockerignore` exists and excludes `.git`, `.env*`, `node_modules`, `tests`, and documentation.

---

## Step 4: Verification & Linting ("Verificare che sia tutto gestito correttamente")

Execute comprehensive verification before handing off to the user:

1. **Syntax & Variable Validation**:
   ```bash
   docker compose -f docker-compose.prod.yml config
   ```
2. **Automated Bottega Security & Configuration Verification**:
   Execute the verification script provided with this skill:
   ```bash
   bash skills/docker-deploy-adapter/scripts/verify-docker-target.sh docker-compose.prod.yml
   ```
3. **Manual Verification against Checklist**:
   Inspect against all criteria in [verification-checklist.md](./references/verification-checklist.md):
   - [x] No plaintext passwords or secrets in compose/Dockerfile.
   - [x] Database ports not exposed to host.
   - [x] Containers run as non-root user.
   - [x] Health checks defined and functional.
   - [x] Named volumes configured for data persistence.
   - [x] Log rotation enabled.
   - [x] Base images pinned to specific versions.

---

## Step 5: Deployment Runbook & Handover

Generate a clear, tailored markdown runbook for the user (e.g. `docs/DEPLOYMENT_DOCKER_EXTERNAL.md`):
1. **Target Environment Architecture Summary**: Diagram or brief summary of the target setup.
2. **Prerequisites Checklist**: Remote server requirements (Docker, Compose plugin, open ports 80/443/22, DNS A/AAAA records pointing to server IP).
3. **Step-by-Step Execution Guide**:
   - How to copy files or pull repository on the remote machine.
   - How to create and populate `.env.production` from `.env.production.example`.
   - The exact command to start the stack:
     ```bash
     docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build
     ```
   - How to run database migrations if required.
4. **Verification & Smoke Test**:
   - `docker compose -f docker-compose.prod.yml ps`
   - `curl -Iv https://yourdomain.com/healthz`
5. **Operational Runbook**:
   - Viewing logs: `docker compose -f docker-compose.prod.yml logs -f app`
   - Updating the application: pull changes and run `docker compose -f docker-compose.prod.yml up -d --build app`
   - Rollback and emergency stop procedures.
