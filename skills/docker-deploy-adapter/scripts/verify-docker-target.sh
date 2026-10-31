#!/usr/bin/env bash
# Bottega — Docker External Deployment Verification Script
# Validates production readiness of Docker & Docker Compose configurations
# Usage: ./verify-docker-target.sh [path-to-target-compose-file]

set -uo pipefail

COMPOSE_FILE="${1:-docker-compose.prod.yml}"
APP_DIR="$(cd "$(dirname "$COMPOSE_FILE")" && pwd)"
ERRORS=0
WARNINGS=0

red() { echo -e "\033[31m[FAIL]\033[0m $1"; ((ERRORS++)); }
yellow() { echo -e "\033[33m[WARN]\033[0m $1"; ((WARNINGS++)); }
green() { echo -e "\033[32m[PASS]\033[0m $1"; }
blue() { echo -e "\033[34m[INFO]\033[0m $1"; }

echo "=========================================================="
echo " Bottega — Docker External Target Deployment Verifier"
echo " Target Compose File: $COMPOSE_FILE"
echo " Working Directory:   $APP_DIR"
echo "=========================================================="

# 1. Check Compose file existence
if [[ ! -f "$COMPOSE_FILE" ]]; then
  red "Target compose file '$COMPOSE_FILE' not found."
  echo "Summary: $ERRORS errors, $WARNINGS warnings."
  exit 1
else
  green "Compose file '$COMPOSE_FILE' found."
fi

# 2. Syntax validation with docker compose if installed
if command -v docker &>/dev/null; then
  if docker compose -f "$COMPOSE_FILE" config -q 2>/dev/null; then
    green "Docker compose syntax is valid (verified via 'docker compose config')."
  else
    yellow "Docker compose syntax check failed or requires missing environment variables."
  fi
else
  blue "Docker CLI not detected locally; skipping live 'docker compose config' syntax check."
fi

# 3. Check for dev bind-mounts of application source code in production compose
if grep -E '^\s*-\s*(\./|/)[a-zA-Z0-9_\-\./]+:(/app|/src|/var/www|/usr/src)' "$COMPOSE_FILE" | grep -v ':\s*ro' | grep -v 'caddy_data' | grep -v 'caddy_config' &>/dev/null; then
  yellow "Detected potential local dev bind-mount of application source code in '$COMPOSE_FILE'. For external production, build/package code into images or use immutable named volumes."
else
  green "No mutable source-code bind-mounts detected in compose file."
fi

# 4. Check for public port exposure of internal databases and caches
DANGEROUS_PORTS=("5432" "3306" "6379" "27017" "9200" "11211" "28015")
for port in "${DANGEROUS_PORTS[@]}"; do
  # Check for patterns like "5432:5432" or "0.0.0.0:5432:5432" (unsafe) vs "127.0.0.1:5432:5432" (safe)
  if grep -E "^\s*-\s*\"?([0-9]+\.)*0\s*:\s*$port" "$COMPOSE_FILE" &>/dev/null || grep -E "^\s*-\s*\"?$port:$port" "$COMPOSE_FILE" &>/dev/null; then
    red "Service port $port is exposed directly to the public host interface in '$COMPOSE_FILE'. Internal databases/caches must communicate via private Docker networks without public port bindings."
  fi
done

# 5. Check for hardcoded plaintext secrets in compose
if grep -Ei 'password\s*:\s*["\x27]?[a-zA-Z0-9_\-]{4,}["\x27]?' "$COMPOSE_FILE" | grep -v '\${' | grep -v 'CHANGE_ME' &>/dev/null; then
  yellow "Possible hardcoded plaintext password/secret found in '$COMPOSE_FILE'. Use environment variables (\${VAR}) or Docker Secrets."
else
  green "No obvious hardcoded plaintext passwords in compose file."
fi

# 6. Check restart policy
if grep -E '^\s*restart\s*:\s*(unless-stopped|always)' "$COMPOSE_FILE" &>/dev/null; then
  green "Production restart policy ('unless-stopped' or 'always') detected."
else
  yellow "No explicit 'restart: unless-stopped' or 'restart: always' policy found in services."
fi

# 7. Check for log rotation limits
if grep -E '^\s*logging:' "$COMPOSE_FILE" &>/dev/null && grep -E 'max-size' "$COMPOSE_FILE" &>/dev/null; then
  green "Container logging driver and max-size rotation configured."
else
  yellow "No container log rotation configured. Without 'max-size', logs may exhaust remote disk space."
fi

# 8. Check Dockerfile security & best practices
DOCKERFILES=$(find "$APP_DIR" -maxdepth 2 -name "Dockerfile*" 2>/dev/null)
if [[ -n "$DOCKERFILES" ]]; then
  for df in $DOCKERFILES; do
    blue "Checking Dockerfile: $df"
    
    # Check non-root USER directive
    if grep -E '^\s*USER\s+[a-zA-Z0-9_-]+' "$df" &>/dev/null; then
      green "  Non-root USER directive found in $(basename "$df")."
    else
      red "  No non-root USER directive found in $(basename "$df"). Production containers should not run as root."
    fi

    # Check for unpinned :latest tag in base images
    if grep -E '^\s*FROM\s+[a-zA-Z0-9_./-]+:latest' "$df" &>/dev/null; then
      yellow "  Unpinned ':latest' base image tag found in $(basename "$df"). Pin explicit versions (e.g., node:20-alpine)."
    else
      green "  Base images appear pinned (no ':latest' found) in $(basename "$df")."
    fi

    # Check for healthcheck directive
    if grep -E '^\s*HEALTHCHECK\s+' "$df" &>/dev/null || grep -E '^\s*healthcheck:' "$COMPOSE_FILE" &>/dev/null; then
      green "  Healthcheck defined in $(basename "$df") or compose file."
    else
      yellow "  No HEALTHCHECK instruction found in $(basename "$df") or compose service definition."
    fi
  done
else
  blue "No Dockerfile found in current or immediate subdirectories."
fi

# 9. Check .dockerignore
if [[ -f "$APP_DIR/.dockerignore" ]]; then
  green ".dockerignore file exists."
  for item in ".git" ".env" "node_modules" "tests"; do
    if grep -E "^[[:space:]]*${item}" "$APP_DIR/.dockerignore" &>/dev/null; then
      green "  .dockerignore excludes '$item'."
    else
      yellow "  .dockerignore should explicitly exclude '$item'."
    fi
  done
else
  red "Missing .dockerignore file. Build context may leak secrets, git history, or heavy local dependencies."
fi

# 10. Check secrets and .gitignore
if [[ -f "$APP_DIR/.gitignore" ]]; then
  if grep -E '^\s*\.env(\.production)?' "$APP_DIR/.gitignore" &>/dev/null; then
    green ".gitignore protects production .env files from being committed."
  else
    red ".gitignore does NOT explicitly exclude .env or .env.production."
  fi
fi

if [[ -f "$APP_DIR/.env.production.example" ]]; then
  green ".env.production.example template is present."
else
  yellow "Missing .env.production.example documentation template."
fi

echo "=========================================================="
if [[ $ERRORS -gt 0 ]]; then
  echo -e "\033[31mVERIFICATION FAILED: $ERRORS error(s), $WARNINGS warning(s).\033[0m"
  echo "Fix the highlighted errors before deploying to the external environment."
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e "\033[33mVERIFICATION PASSED WITH WARNINGS: $WARNINGS warning(s), 0 errors.\033[0m"
  echo "Review warnings to ensure production stability and security."
  exit 0
else
  echo -e "\033[32mVERIFICATION PASSED: 100% compliant with Bottega container standards.\033[0m"
  exit 0
fi
