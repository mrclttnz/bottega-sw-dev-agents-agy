# External Docker Target Environments Reference

When preparing a local Docker Compose development environment for deployment to an external Docker environment, the exact adaptations depend on the target environment.

---

## 1. Remote VPS / Dedicated Server (Docker Compose over SSH)
**Examples**: Ubuntu / Debian on Hetzner, DigitalOcean, Linode, AWS EC2, GCP Compute Engine, OVH.

### Architecture
- Single host running Docker Engine and Docker Compose plugin (`docker compose`).
- A lightweight reverse proxy (Caddy or Traefik) handles incoming HTTP/HTTPS (ports 80 and 443), terminates TLS with automated Let's Encrypt certificates, and proxies traffic to application containers.
- Internal services (databases, caches, workers) run in private Docker bridge networks and **never expose ports to the public host interface**.

### Key Adaptations Required
1. **Reverse Proxy & Ingress**: Add a reverse proxy service (e.g. Caddy) or connect the application to an existing reverse proxy network on the host.
2. **Remove Dev Bind-Mounts**: Eliminate `./src:/app` hot-reloading mounts. Either build the image on the host or pull pre-built production images from a container registry.
3. **Persistent Volumes**: Replace local development relative paths (`./dev-db-data`) with named Docker volumes (`db_data:/var/lib/postgresql/data`) or designated host directory mounts (`/var/lib/myapp/data`).
4. **Log Rotation**: Add `logging` blocks to prevent container logs from filling the remote disk.
5. **Restart Policies**: Enforce `restart: unless-stopped` on all persistent services.
6. **Firewall / Port Security**: Only ports `80` (HTTP), `443` (HTTPS), and `22` (SSH) should be open on the host firewall (`ufw`).

---

## 2. Self-Hosted Container Platforms (Coolify, Portainer, Dokku, CapRover)
**Examples**: Coolify on VPS, Portainer Stacks on remote server, Dokku, CapRover.

### Architecture
- The platform manages ingress routing, SSL certificates, build triggers, and environment variables natively.
- Deployments typically occur via Git push / webhook or Docker Compose Stack definitions.

### Key Adaptations Required
1. **Ingress Labels vs Port Bindings**:
   - For **Coolify / Traefik / CapRover**: Strip host port mappings (`80:3000`) and replace with platform-specific labels (e.g., Traefik router rules or Coolify domain configuration).
   - For **Portainer**: Maintain internal service names; avoid host port collisions if multiple stacks share the host.
2. **Environment Variable Injection**:
   - Variables are usually configured in the platform's UI / Secret Store rather than a raw `.env` file on disk. Provide `.env.production.example` for easy copy-pasting.
3. **Database Selection**:
   - Check if the user wants to use the platform's built-in one-click managed database service or keep the database inside the stack compose definition.

---

## 3. Cloud Container PaaS (AWS ECS / Google Cloud Run / Azure Container Apps / Fly.io)

### Architecture
- Serverless or managed container tasks. Usually single-container or multi-container pods with cloud-managed load balancers.
- Docker Compose is either translated (e.g., AWS ECS Compose / Kompose) or decoupled into individual container services.

### Key Adaptations Required
1. **Image Registry Mandatory**: Containers cannot be built locally on the fly; images must be built and pushed to a remote registry (AWS ECR, Google Artifact Registry, GitHub GHCR, Docker Hub).
2. **Stateless Containers & Ephemeral Storage**: Local filesystem writes inside the container will be lost on container restart.
   - Databases must be migrated to managed cloud databases (AWS RDS, Google Cloud SQL, Supabase, Neon).
   - User file uploads must be stored in Object Storage (AWS S3, Google Cloud Storage, Cloudflare R2).
3. **Port Binding**: Containers usually listen on a single internal port (e.g., `$PORT` or 8080) provided by the cloud runtime.
4. **Health Checks**: Cloud health probes require a fast HTTP `/healthz` endpoint returning `200 OK`.

---

## 4. Clustered Swarm / Multi-Node Docker Swarm

### Architecture
- Multi-node clustering using Docker Swarm (`docker stack deploy -c docker-compose.prod.yml <stack-name>`).
- Ingress routing via Docker Swarm Routing Mesh and Overlay networks.

### Key Adaptations Required
1. **Deploy Keys**: Add `deploy:` blocks to specify `replicas`, `restart_policy`, `resources.limits`, and `update_config`.
2. **Secrets & Configs**: Convert plaintext environment secrets to Docker Swarm `secrets:` and configs to `configs:`.
3. **Volumes**: Local bind-mounts cannot be used across multi-node swarms without distributed network storage (NFS, GlusterFS, Ceph, or cloud block storage). Prefer object storage for state.
4. **Overlay Networks**: Define `driver: overlay` for cross-node service discovery.
