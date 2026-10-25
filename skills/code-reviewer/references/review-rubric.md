# Bottega 6-Dimension Code Review Rubric

## Dimension 1: Correctness & Edge Cases (All Profiles)
- Does the code accurately implement every requirement and acceptance criterion in `docs/PRD.md` / `docs/SPEC.md`?
- Are null/undefined/empty values, boundary numbers (`0`, `-1`, `MAX_INT`), empty arrays, and unicode strings handled safely?
- Are async operations properly awaited, and are errors in promises/goroutines/threads properly propagated?
- In `citadel`: Are database writes wrapped in transactions where multiple tables are updated? Are concurrent mutations protected against race conditions (optimistic/pessimistic locking or atomic SQL updates)?

## Dimension 2: Security & Data Safety (All Profiles)
- Are all inputs validated at the boundary?
- Are SQL queries parameterized and OS commands free of shell interpolation?
- Does every endpoint verify resource ownership (`owner_id` / `tenant_id`)?
- Are secrets, tokens, and PII excluded from source code and redacted from logs?

## Dimension 3: Architecture & Modularity (`forge` & `citadel`)
- Does the code respect the module boundaries defined in `docs/ARCHITECTURE.md`?
- Is business logic decoupled from HTTP/CLI transport and raw database drivers?
- Is there duplicated logic that should be consolidated, or premature abstraction that hurts readability?

## Dimension 4: Error Handling & Resilience (`forge` & `citadel`)
- Are external calls (HTTP, DB, filesystem) wrapped with proper error handling and timeouts?
- Do error responses return appropriate status codes without leaking internal stack traces?
- Are resources (file descriptors, DB connections, streams, timers) always closed/cleaned up in `finally` / `defer` / `with` blocks?

## Dimension 5: Performance & Resource Hygiene (`forge` & `citadel`)
- Are there N+1 query loops (fetching related records inside a `for` loop instead of a `JOIN` or `WHERE id IN (...)`)?
- Are list endpoints bounded by pagination (`limit` / `offset` or cursor) with a maximum allowed page size?

## Dimension 6: Test Quality & Execution Evidence (All Profiles)
- Do tests assert meaningful behavior rather than tautologies or trivial mocks?
- Are both happy-path and negative/error paths tested?
- Is fresh command output proving 100% test pass included?
