# Bottega Standard GitHub Label Taxonomy

Bottega uses a clean, standardized label taxonomy across all projects, organized around three orthogonal dimensions:
1. **Work Item Type (`type:*`)**
2. **Priority (`priority:*`)**
3. **Workflow Status (`status:*`)**

*(If an individual project requires custom domain or component labels, the user or agent can create them ad-hoc with `gh label create`, without hardcoding domain-specific options in the global bootstrap script).*

---

## 1. Work Item Type (`type:*`)

| Label | Hex Color | Description | Typical Origin |
| :--- | :--- | :--- | :--- |
| `type:feature` | `#0E8A16` | New user-facing capability or major functional requirement | User idea, `product-strategist`, PRD |
| `type:enhancement` | `#A2EEEF` | Iterative improvement or UX refinement to an existing feature | User suggestion, UI/UX feedback |
| `type:bug` | `#D73A4A` | Unexpected behavior, crash, regression, or broken edge case | User report, `qa-engineer` |
| `type:security` | `#B60205` | Security vulnerability, Threat Model control, or AppSec hardening | `security-engineer`, `security-scan.sh` |
| `type:refactor` | `#FBCA04` | Code quality, architectural cleanup, or tech debt reduction | `code-reviewer` (`backlog` items), `system-architect` |
| `type:docs` | `#0075CA` | Documentation alignment, ADR, schema doc, or runbook update | Continuous Doc Sync, `code-reviewer` |
| `type:chore` | `#CFD3D7` | CI/CD, Docker, dependencies, build tooling, or infra maintenance | `devops-sre`, `docker-deploy-adapter` |

---

## 2. Priority (`priority:*`)

| Label | Hex Color | Description |
| :--- | :--- | :--- |
| `priority:critical` | `#B60205` | Blocker, production outage, or critical/high security vulnerability (`must-fix-now`) |
| `priority:high` | `#D93F0B` | High-value feature or important defect for the next vertical slice |
| `priority:medium` | `#FBCA04` | Standard backlog item planned for upcoming iterations |
| `priority:low` | `#0E8A16` | Nice-to-have improvement, minor nit, or long-term idea |

---

## 3. Workflow Status (`status:*`)

| Label | Hex Color | Description |
| :--- | :--- | :--- |
| `status:triage` | `#EDEDED` | Newly opened issue awaiting requirements/priority assessment |
| `status:needs-spec` | `#D876E3` | Requires PRD/Architecture/DB Schema update before implementation |
| `status:ready` | `#0E8A16` | Scope and acceptance criteria are clear; ready to be picked up in a Slice |
| `status:in-progress` | `#1D76DB` | Actively being implemented in a Bottega Vertical Slice (`docs/PROJECT_STATE.md`) |
| `status:blocked` | `#B60205` | Blocked by external dependency, pending decision, or failed Gate 6 review |
