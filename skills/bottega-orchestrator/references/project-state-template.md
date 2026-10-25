# Project State & Context Index (`PROJECT_STATE.md`)

> Single source of truth maintained by **Bottega Orchestrator**. Read this file first before executing any phase or spawning specialist subagents.

## 1. Project Identity & Profile
- **Project Name**: `<Project Name>`
- **One-Line Vision**: `<Short description of what the application does>`
- **Active Bottega Profile**: `spark` | `forge` | `citadel`
- **Rationale for Profile**: `<Complexity & criticality justification, e.g., handles user auth + business data -> forge>`
- **Current Phase**: `Phase 0: Triage`

## 2. Key Technology & Architecture Decisions
| Layer | Chosen Technology | Rationale / Trade-off | Status |
| :--- | :--- | :--- | :--- |
| **Language / Runtime** | `TBD` | | Pending |
| **Frontend / UI** | `TBD` | | Pending |
| **Backend / API** | `TBD` | | Pending |
| **Database & Cache** | `TBD` | | Pending |
| **AuthN / AuthZ** | `TBD` | | Pending |
| **Deployment Target** | `TBD` | | Pending |

## 3. Artifact Index
- **Requirements Spec**: `docs/PRD.md` (or `docs/SPEC.md`) — `[Not Started | Draft | Approved]`
- **System Architecture**: `docs/ARCHITECTURE.md` — `[Not Started | Draft | Approved]`
- **Threat Model**: `docs/SECURITY_THREAT_MODEL.md` — `[N/A | Draft | Approved]`
- **Database Design**: `docs/DB_SCHEMA.md` — `[Not Started | Draft | Approved]`
- **Test Plan**: `docs/TEST_PLAN.md` — `[Not Started | Draft | Approved]`
- **Security Audit Report**: `docs/SECURITY_AUDIT.md` — `[Not Started | Pass | Blocked]`
- **Deployment Runbook**: `docs/DEPLOYMENT_RUNBOOK.md` — `[Not Started | Ready]`

## 4. Vertical Slices & Implementation Backlog
| Slice ID | Feature / Module | Owner Role | Dev Status | QA Status | Review & Sec Gate |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `S1` | Foundation & Auth | `software-craftsman` | `TODO` | `TODO` | `TODO` |

## 5. Quality & Security Gate Log
- **[ ] Gate 1 (Requirements Approved)**:
- **[ ] Gate 2 (Architecture & Threat Model Approved)**:
- **[ ] Gate 3 (DB Schema & Modules Approved)**:
- **[ ] Gate 5 (Automated Tests Passing — Evidence Recorded)**:
- **[ ] Gate 6 (Security Audit & Adversarial Code Review Passed)**:
- **[ ] Gate 7 (Deployment Verified)**:
