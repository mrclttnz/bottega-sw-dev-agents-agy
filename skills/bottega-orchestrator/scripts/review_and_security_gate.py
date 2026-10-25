# Dynamic Workflow Script for Antigravity `run_workflow` tool
# Runs parallel Independent Code Review and AppSec Security Audit on the current workspace.
# Usage via tool: run_workflow(ScriptPath="/path/to/review_and_security_gate.py", Args={"profile": "forge", "slice": "All"})

profile = args.get("profile", "forge") if "args" in dir() and isinstance(args, dict) else "forge"
target_slice = args.get("slice", "current changes") if "args" in dir() and isinstance(args, dict) else "current changes"

phase(f"Parallel Verification Gate ({profile.upper()} Profile)")
log(f"Starting independent Code Review and Security Audit for: {target_slice}")

review_schema = {
    "type": "object",
    "properties": {
        "verdict": {"type": "string", "enum": ["APPROVE", "APPROVE_WITH_NITS", "BLOCK"]},
        "summary": {"type": "string"},
        "must_fix_now": {"type": "array", "items": {"type": "string"}},
        "backlog_nits": {"type": "array", "items": {"type": "string"}},
        "evidence_checked": {"type": "string"}
    },
    "required": ["verdict", "summary", "must_fix_now", "evidence_checked"]
}

security_schema = {
    "type": "object",
    "properties": {
        "verdict": {"type": "string", "enum": ["PASS", "PASS_WITH_WARNINGS", "BLOCK"]},
        "summary": {"type": "string"},
        "critical_or_high_findings": {"type": "array", "items": {"type": "string"}},
        "medium_or_low_findings": {"type": "array", "items": {"type": "string"}},
        "owasp_checks_performed": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["verdict", "summary", "critical_or_high_findings", "owasp_checks_performed"]
}

tasks = [
    {
        "role": "Adversarial Code Reviewer",
        "prompt": (
            f"Perform an independent Adversarial Code Review for slice '{target_slice}' under Bottega profile '{profile}'. "
            "Read docs/PROJECT_STATE.md and inspect recent code changes and tests. "
            "Check: 1) Correctness & Edge Cases, 2) Architecture & Modularity, 3) Error Handling, "
            "4) Performance/Resource leaks, 5) Test Coverage & Quality. "
            "Return a structured verdict (APPROVE, APPROVE_WITH_NITS, or BLOCK)."
        ),
        "schema": review_schema,
    },
    {
        "role": "AppSec Security Auditor",
        "prompt": (
            f"Perform an independent Application Security Audit for slice '{target_slice}' under Bottega profile '{profile}'. "
            "Inspect code, configs, dependencies, and auth flows against OWASP Top 10, CWE Top 25, "
            "hardcoded secrets, SQL/command/XSS injection, broken access control (IDOR/AuthZ), and insecure defaults. "
            "Return a structured verdict (PASS, PASS_WITH_WARNINGS, or BLOCK)."
        ),
        "schema": security_schema,
    }
]

results = await parallel(
    tasks,
    lambda t: agent(
        prompt=t["prompt"],
        schema=t["schema"],
        role=t["role"],
    )
)

code_review_res, sec_audit_res = results[0], results[1]
log(f"Code Review Verdict: {code_review_res['verdict']}")
log(f"Security Audit Verdict: {sec_audit_res['verdict']}")

gate_passed = (
    code_review_res["verdict"] in ("APPROVE", "APPROVE_WITH_NITS")
    and sec_audit_res["verdict"] in ("PASS", "PASS_WITH_WARNINGS")
    and len(code_review_res.get("must_fix_now", [])) == 0
    and len(sec_audit_res.get("critical_or_high_findings", [])) == 0
)

print({
    "gate_passed": gate_passed,
    "profile": profile,
    "code_review": code_review_res,
    "security_audit": sec_audit_res,
})
