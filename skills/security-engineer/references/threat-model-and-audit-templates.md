# Security Templates: Threat Model & AppSec Audit Report

---

## Template 1: Threat Model (`docs/SECURITY_THREAT_MODEL.md`)

### 1. Asset & Data Sensitivity Inventory
| Asset / Data Store | Classification (`PUBLIC` / `INTERNAL` / `PII` / `SECRET`) | Storage Location | Protection Control (Encryption, Hashing, Masking) |
| :--- | :--- | :--- | :--- |
| User Passwords | `SECRET` | DB `users.password_hash` | Argon2id / bcrypt |
| Session / API Tokens | `SECRET` | HTTP-only Cookie / Header | Signed/Encrypted, short TTL |

### 2. Trust Boundaries & Entry Points
- **Public Untrusted Entry Points**: `<List public API routes, webhooks, file uploads, CLI args>`
- **Authenticated User Entry Points**: `<List user-scoped routes>`
- **Privileged / Admin Entry Points**: `<List admin routes / internal jobs>`

### 3. STRIDE Threat Matrix
| Component / Flow | Threat Category (STRIDE) | Abuse Scenario / Attack Vector | Impact | Required Mitigation & Verification Test |
| :--- | :--- | :--- | :--- | :--- |
| Auth Login | **S**poofing / Brute Force | Credential stuffing on `/login` | High | Rate limiting + generic error message + Argon2id |
| Resource API | **E**levation / IDOR | User A modifies `/:id` owned by User B | Critical | Enforce `WHERE id = $1 AND owner_id = $2` + integration test |
| Input Handler | **T**ampering / Injection | Malicious SQL/HTML/Command payload | Critical | Strict schema validation + parameterized queries |

---

## Template 2: Application Security Audit Report (`docs/SECURITY_AUDIT.md`)

### 1. Executive Audit Summary
- **Audit Date**: `<YYYY-MM-DD>`
- **Active Bottega Profile**: `spark` | `forge` | `citadel`
- **Automated Scanner Output (`security-scan.sh`)**: `PASS` | `WARN` | `FAIL`
- **Overall Security Gate Verdict**: `PASS` | `PASS_WITH_WARNINGS` | `BLOCK`

### 2. OWASP Top 10 & CWE Verification Checklist
| Category | Status (`PASS` / `FAIL` / `N/A`) | Notes & Evidence |
| :--- | :--- | :--- |
| **A01: Broken Access Control (AuthZ, IDOR, Path Traversal, CORS)** | | |
| **A02: Cryptographic Failures & Hardcoded Secrets** | | |
| **A03: Injection (SQLi, Command, XSS, Template)** | | |
| **A04: Insecure Design (Rate Limiting, Mass Assignment, Race Conditions)** | | |
| **A05: Security Misconfiguration (Headers, Error Leaks, Non-Root Container)** | | |
| **A06: Vulnerable Dependencies (Supply Chain Audit)** | | |
| **A07: Authentication & Session Security** | | |
| **A08: Data Integrity & Deserialization / Webhook Verification** | | |
| **A09: Safe Logging (Zero Secret/PII Leaks in Logs)** | | |
| **A10: SSRF & Outbound Request Validation** | | |

### 3. Findings & Remediation Tracker
| ID | Severity (`CRITICAL` / `HIGH` / `MEDIUM` / `LOW`) | Title & CWE | Location (`file:line`) | Proof of Concept / Risk | Required Remediation | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `SEC-F01` | | | | | | `OPEN` / `FIXED` |
