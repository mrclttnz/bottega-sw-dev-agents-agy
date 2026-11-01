# Bottega Secure Coding & Self-Check Checklist

Every implementation slice must pass this self-check before handoff to `qa-engineer`, `code-reviewer`, or `security-engineer`.

## 1. Secrets & Configuration Hygiene (All Profiles)
- [ ] Zero hardcoded API keys, passwords, JWT secrets, private keys, or connection strings in source code or tests.
- [ ] `.gitignore` includes `.env`, `.env.*` (except `.env.example`), `*.pem`, `*.key`, and local DB files containing sensitive data.
- [ ] Application fails fast on startup with a clear error message if required security environment variables (e.g., `SESSION_SECRET`, `DATABASE_URL`) are missing or set to weak defaults in production.

## 2. Input Validation & Injection Prevention (All Profiles)
- [ ] All user/external inputs (body, query, params, headers, files) are validated against an explicit schema (types, length bounds, allowed enums).
- [ ] Mass Assignment prevented: ORM `create`/`update` calls explicitly pick allowed fields rather than passing raw `req.body`.
- [ ] SQL Queries: 100% parameterized queries / prepared statements (including `ORDER BY` / `LIMIT` whitelist validation).
- [ ] OS Commands: Zero shell interpolation (`sh -c`, `os.system`, `shell=True`) with user-supplied data.
- [ ] Path Traversal: Any file path derived from user input is canonicalized (`realpath`/`resolve`) and verified to remain strictly inside the intended base directory.
- [ ] SSRF: Outbound HTTP requests using user-supplied URLs validate the scheme (`https` only) and block private/loopback/metadata IP ranges (`127.0.0.0/8`, `169.254.169.254`, `10.0.0.0/8`, etc.).

## 3. Authentication & Access Control (`forge` & `citadel`)
- [ ] Passwords hashed with `Argon2id` or `bcrypt` (cost $\ge 12$).
- [ ] Tokens/Sessions generated using cryptographically secure random generators (`crypto.randomBytes`, `secrets.token_urlsafe`), never `Math.random()`.
- [ ] Every protected route checks both **Authentication** and **Object-Level Authorization (IDOR check)** before reading or mutating a record.
- [ ] State-changing cookie-authenticated endpoints enforce CSRF protection and `SameSite=Lax` or `Strict`, `HttpOnly`, `Secure` cookie attributes.

## 4. Output Encoding, Error Handling & Resilience
- [ ] Untrusted strings rendered in UI are properly escaped; dangerous APIs (`dangerouslySetInnerHTML`, `v-html`, `innerHTML`) are avoided or sanitized with DOMPurify.
- [ ] Error responses return safe HTTP status codes (`400`, `401`, `403`, `404`, `422`, `429`, `500`) without exposing internal stack traces, SQL errors, or file paths.
- [ ] External API/DB calls configure explicit timeouts and resource cleanup.

## 5. Documentation & Specification Alignment (Mandatory for All Profiles)
- [ ] **Architecture & API Contracts**: `docs/ARCHITECTURE.md` updated with any new/modified endpoints, payloads, HTTP status codes, or component interactions.
- [ ] **Data Model & Schema**: `docs/DB_SCHEMA.md` (and Mermaid ERD) updated with any new/modified tables, fields, constraints, or indexes.
- [ ] **Configuration & Environment**: Any new environment variable is added to `.env.example` with safe placeholder documentation.
- [ ] **Project State Tracking**: `docs/PROJECT_STATE.md` updated with the latest slice implementation status and architectural decisions.
- [ ] **Code-Level Documentation**: Docstrings, JSDoc/type definitions, and comments match the real behavior of the modified functions/classes.
- [ ] **Public Guides**: `README.md` or user documentation updated if public CLI flags, setup instructions, or dependencies changed.
