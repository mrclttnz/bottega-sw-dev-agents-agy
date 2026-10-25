# Test Strategy & Verification Plan (`TEST_PLAN.md`)

## 1. Test Scope & Profile Alignment
- **Active Bottega Profile**: `spark` | `forge` | `citadel`
- **Test Runner & Frameworks**: `<e.g., Vitest / Pytest / Go test / Playwright>`
- **Test Environment & DB Isolation**: `<e.g., SQLite in-memory / Testcontainers / Transaction rollback>`

## 2. Requirements-to-Tests Traceability Matrix
| Req / Story ID | Scenario Description | Test Type | Test File / Suite | Security / Edge Case Covered | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `US-01` | Happy path + validation + AuthZ | Unit / Integration | `tests/...` | Rejects unauthorized user (`403`) | `PASS` |

## 3. Security & Negative Test Scenarios (Mandatory for `forge` & `citadel`)
- [ ] **Authentication Bypass**: Protected endpoints return `401` with missing, malformed, or expired tokens.
- [ ] **Broken Object Level Authorization (IDOR)**: User A attempting to read/update/delete User B's resource receives `403` or `404`.
- [ ] **Schema & Boundary Validation**: Oversized payloads, wrong types, SQL/HTML special characters, and negative numbers are safely handled (`400`/`422`).
- [ ] **Error Sanitization**: Forced internal errors return a safe `500` payload without leaking stack traces or DB internals.

## 4. Test Execution Evidence
```text
# Paste latest test execution command and summary output here
```
