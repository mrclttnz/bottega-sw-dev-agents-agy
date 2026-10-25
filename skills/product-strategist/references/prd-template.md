# Product Requirements Document (`PRD.md` / `SPEC.md`)

> For **`spark`** profile, keep only Sections 1, 2, 3 (simplified), and 6 in `docs/SPEC.md`.
> For **`forge`** and **`citadel`** profiles, complete all sections in `docs/PRD.md`.

## 1. Executive Summary & Vision
- **Problem Statement**: What problem are we solving and why now?
- **Target Audience / Personas**: Who are the primary users?
- **Success Metrics**: How do we measure that the application succeeds?
- **Active Bottega Profile**: `spark` | `forge` | `citadel`

## 2. Scope & Boundaries (MoSCoW)
- **In Scope (Must-Have for v1)**:
  - ...
- **Should-Have / Could-Have (Post-MVP Backlog)**:
  - ...
- **Explicit Non-Goals (Out of Scope)**:
  - ...

## 3. Actors, Roles & Access Control Matrix (Security Shift-Left)
| Actor / Role | Authentication Method | Permitted Actions | Restricted / Forbidden Actions |
| :--- | :--- | :--- | :--- |
| `Anonymous` | None | | |
| `User` | Session / JWT / OAuth | | Cannot access other users' resources (IDOR protection) |
| `Admin` | MFA / Privileged Role | | |

## 4. Functional Requirements & User Stories

### `US-01`: `<Title of User Story>`
- **Story**: As a `<role>`, I want to `<action>`, so that `<value>`.
- **Acceptance Criteria (Given / When / Then)**:
  1. **Happy Path**: *Given* `<context>`, *When* `<action>`, *Then* `<expected outcome>`.
  2. **Validation / Edge Case**: *Given* `<invalid input or boundary>`, *When* `<action>`, *Then* `<safe error response>`.
  3. **Security / AuthZ**: *Given* `<unauthenticated or unauthorized actor>`, *When* `<action>`, *Then* `<401/403 rejection and audit log>`.

## 5. Non-Functional & Security Requirements
- **`NFR-01` (Performance & Scalability)**:
- **`NFR-02` (Reliability & Error Handling)**:
- **`SEC-01` (Data Classification & Privacy)**: List any PII, secrets, or sensitive data and how they must be protected.
- **`SEC-02` (Abuse & Rate Limiting)**: Protection against brute force, spam, or resource exhaustion.

## 6. Open Questions & Decisions Log
| ID | Question / Decision | Chosen Option | Rationale |
| :--- | :--- | :--- | :--- |
| `D-01` | | | |
