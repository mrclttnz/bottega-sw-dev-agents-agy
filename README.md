# Bottega — AI Software Engineering Team for Google Antigravity

**Bottega** is a full-cycle, security-first AI software engineering system for Google Antigravity. Inspired by multi-agent engineering frameworks (`10x-Team`, `dev-team`) and built natively around Antigravity's **Plugins, Skills, Subagents, Hierarchical Rules, Lifecycle Hooks, and Dynamic Workflows**, Bottega takes you from an initial idea to a tested, reviewed, secure, and deployed application.

---

## Key Architectural Principles

1. **Adaptive Proportionality (Phase 0 Triage)**:
   Guardrails, documentation depth, threat modeling, testing rigor, and review ceremony scale proportionally to the complexity and criticality of your application:
   - **`spark` (Prototype / Simple / Low-Risk)**: Lightweight 1-page `docs/SPEC.md`, essential security baseline (zero hardcoded secrets, input validation, safe APIs), smoke tests, and a single combined Code & Security review pass.
   - **`forge` (MVP / Standard Application / Moderate-Risk)**: Structured `docs/PRD.md`, `docs/ARCHITECTURE.md` (with Threat Model Light), `docs/DB_SCHEMA.md`, vertical-slice implementation, automated Unit/Integration + Negative AuthZ tests, independent `code-reviewer` + `security-engineer` blocking gates, and hardened Docker/CI deployment.
   - **`citadel` (Production / High-Complexity / Mission-Critical)**: Adversarial PRD review, `docs/ARCHITECTURE.md` + `docs/adr/`, full STRIDE `docs/SECURITY_THREAT_MODEL.md`, Zero-Trust `docs/DB_SCHEMA.md` (RLS, encryption, audit logs), strict TDD + E2E + security regression suite, blocking multi-dimensional Adversarial Code Review + full AppSec Audit (`docs/SECURITY_AUDIT.md`), and hardened IaC + SRE `docs/DEPLOYMENT_RUNBOOK.md`.
2. **Index-First Context Management (`docs/PROJECT_STATE.md`)**:
   Maintains a single, token-efficient source of truth across phases and subagent handoffs.
3. **Shift-Left & Gate-Enforced Security**:
   Security starts at Requirements and Architecture/DB design (`security-engineer`) and is enforced before completion via automated scanning (`scripts/security-scan.sh`), independent AppSec review, and `PreToolUse` command/commit guard hooks (`hooks.json`).
4. **Evidence-Based Completion**:
   No implementation, test, or security task can be marked `DONE` without fresh execution command output (`Evidence`) and an explicit `Self-Check`.
5. **Continuous Documentation Alignment (Doc-Code Sync)**:
   Documentation is treated as a first-class engineering artifact that must always remain in lockstep with the codebase. Whenever changes are made to code, API endpoints, database schemas, configurations, or tests, all corresponding documentation (`docs/PROJECT_STATE.md`, `docs/ARCHITECTURE.md`, `docs/DB_SCHEMA.md`, `docs/PRD.md`/`docs/SPEC.md`, `docs/TEST_PLAN.md`, `docs/DEPLOYMENT_RUNBOOK.md`, `README.md`, `.env.example`, and inline docstrings) MUST be updated synchronously. Outdated documentation is treated as a blocking defect during code review.
6. **Language Policy**:
   Agents converse with you in the **same language used in your prompt** (e.g., Italian or English), while producing technical documentation (`docs/*.md`), schemas, and code in **English** by default (unless requested otherwise).

---

## The Bottega Specialist Roster

| Specialist (`skills/` & `agents/`) | Role | Primary Responsibilities | Key Artifacts |
| :--- | :--- | :--- | :--- |
| **`bottega-orchestrator`** | Tech Lead & Delivery Coordinator | Phase 0 Triage (`spark` / `forge` / `citadel`), workflow orchestration, context index, gate sign-offs | `docs/PROJECT_STATE.md` |
| **`product-strategist`** | Product Manager & Requirements Analyst | Socratic discovery interviews, personas, user stories with Given/When/Then criteria, scope & non-goals | `docs/PRD.md` or `docs/SPEC.md` |
| **`system-architect`** | Principal Architect & CTO | Tech stack trade-offs, component architecture, module boundaries, API contracts, Security-by-Design, ADRs | `docs/ARCHITECTURE.md`, `docs/adr/` |
| **`data-architect`** | DBA & Data Engineer | Mermaid ER diagrams, schema design, indexing, migrations, PII classification, Row-Level Security (RLS) | `docs/DB_SCHEMA.md`, migrations |
| **`software-craftsman`** | Senior Full-Stack Engineer | Clean vertical-slice implementation, defensive coding, input validation, parameterized queries, Self-Check | Source code + Evidence |
| **`qa-engineer`** | QA Architect & Test Engineer | Proportional test strategy, automated unit/integration/E2E/negative security tests, test execution | `docs/TEST_PLAN.md`, test suites |
| **`security-engineer`** | Principal AppSec & DevSecOps Engineer | STRIDE Threat Modeling (Shift-Left) & OWASP Top 10 / CWE Top 25 / Secrets / Supply-Chain Audit (Gate) | `docs/SECURITY_THREAT_MODEL.md`, `docs/SECURITY_AUDIT.md` |
| **`code-reviewer`** | Adversarial Staff Reviewer | Independent review of specs and code diffs across 7 dimensions (`must-fix-now` vs `backlog`, including doc sync) | `APPROVE` / `BLOCK` Verdict |
| **`devops-sre`** | Cloud Architect, DevOps & SRE | Hosting selection, hardened non-root `Dockerfile`, CI/CD pipelines with security gates, deployment runbooks | `Dockerfile`, CI/CD, `docs/DEPLOYMENT_RUNBOOK.md` |
| **`docker-deploy-adapter`** | Docker Deployment & Production Specialist | Zero-assumption production adaptation of local `docker-compose.yml` for external Docker environments | `docker-compose.prod.yml`, `docs/DEPLOYMENT_DOCKER_EXTERNAL.md` |
| **`github-issue-manager`** | GitHub Issues & Backlog Specialist | Standardized label taxonomy, GitHub Issue Forms (`.yml`), static backlog migration (`suggerimenti.md`/`TODO.md`), Issue-to-Slice linkage, and review backlog sync | `.github/ISSUE_TEMPLATE/*.yml`, GitHub Issues & Labels |

---

## Repository Structure

```text
bottega-agy/
├── plugin.json                # Antigravity Plugin Manifest
├── hooks.json                 # PreToolUse security & git pre-commit secret guard
├── AGENTS.md                  # Root workspace rules (mirrored from rules/AGENTS.md)
├── assets/
│   └── logo.svg               # Plugin icon
├── rules/
│   └── AGENTS.md              # Core Bottega Engineering & Security Rules
├── agents/                    # Isolated-context Subagent definitions
│   ├── product-strategist.md
│   ├── system-architect.md
│   ├── data-architect.md
│   ├── software-craftsman.md
│   ├── qa-engineer.md
│   ├── security-engineer.md
│   ├── code-reviewer.md
│   └── devops-sre.md
├── skills/                    # On-demand procedural Skills + Reference Templates
│   ├── bottega-orchestrator/
│   │   ├── SKILL.md
│   │   ├── references/project-state-template.md
│   │   └── scripts/review_and_security_gate.py
│   ├── product-strategist/
│   │   ├── SKILL.md
│   │   └── references/prd-template.md
│   ├── system-architect/
│   │   ├── SKILL.md
│   │   └── references/architecture-template.md
│   ├── data-architect/
│   │   ├── SKILL.md
│   │   └── references/db-schema-template.md
│   ├── software-craftsman/
│   │   ├── SKILL.md
│   │   └── references/secure-coding-checklist.md
│   ├── qa-engineer/
│   │   ├── SKILL.md
│   │   └── references/test-plan-template.md
│   ├── security-engineer/
│   │   ├── SKILL.md
│   │   └── references/threat-model-and-audit-templates.md
│   ├── code-reviewer/
│   │   ├── SKILL.md
│   │   └── references/review-rubric.md
│   ├── devops-sre/
│   │   ├── SKILL.md
│   │   └── references/deployment-runbook-template.md
│   ├── docker-deploy-adapter/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   │   ├── target-environments.md
│   │   │   ├── verification-checklist.md
│   │   │   └── templates/
│   │   │       ├── docker-compose.prod.yml.template
│   │   │       ├── Caddyfile.template
│   │   │       └── env.production.example.template
│   │   └── scripts/
│   │       └── verify-docker-target.sh
│   └── github-issue-manager/
│       ├── SKILL.md
│       ├── references/
│       │   ├── label-taxonomy.md
│       │   └── issue-templates/
│       │       ├── config.yml
│       │       ├── feature_request.yml
│       │       ├── bug_report.yml
│       │       └── tech_debt_security.yml
│       └── scripts/
│           └── gh-issue-bootstrap.sh
└── scripts/
    ├── install.sh             # Global plugin & workspace installer
    ├── pre-command-guard.sh   # PreToolUse hook handler (blocks destructive cmds & secret commits)
    └── security-scan.sh       # Automated static security & secret scanner
```

---

## Installation & Usage

### 1. Install Globally in Antigravity + Configure Current Workspace
```bash
./scripts/install.sh --all
```
*(After installing the global plugin for the first time, restart Antigravity so `~/.gemini/config/plugins/bottega` is indexed globally across all projects).*

### 2. Install into Another Project Workspace (Standalone `.agents/`)
```bash
./scripts/install.sh --workspace /path/to/your/project
```

### 3. Running the Automated Security Scanner Directly
```bash
./scripts/security-scan.sh /path/to/your/project [spark|forge|citadel]
```
