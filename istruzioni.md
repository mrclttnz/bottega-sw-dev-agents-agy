# Bottega — Guida e Istruzioni Operative

**Bottega** è un sistema completo di *AI Software Engineering* per Google Antigravity, progettato ispirandosi ai principi di **10x-Team** (*Index-First Context*, *Spec-Before-Code*, ruoli specialistici) e **dev-team** (*Phase 0 Triage*, *Evidence-Based Completion*, *Adversarial Review* e *Inline Quality Gates*).

> [!NOTE]
> Puoi gestire il plugin direttamente da Antigravity tramite `bottega` o `customization://bottega`.
> Poiché è stata creata una directory plugin globale in questa sessione, riavvia Antigravity per consentire il caricamento globale di tutte le skill e i subagent. Nel workspace corrente sono già attivi tramite `.agents/` e [AGENTS.md](file:///home/marco/work/bottega-agy/AGENTS.md).

---

## 1. Architettura e Proporzionalità del Rigore (Phase 0 Triage)

I guardrail di sicurezza, la profondità documentale e i controlli di review scalano proporzionalmente alla complessità e alla criticità dell'applicazione, valutate durante la **Fase 0 (Triage)** e tracciate nell'indice di stato `docs/PROJECT_STATE.md`.

| Profilo | Target Tipico | Requisiti & Architettura | Testing (QA) | Sicurezza & Code Review Gates |
| :--- | :--- | :--- | :--- | :--- |
| **`spark`**<br>*(Prototipo / Semplice)* | Script, CLI, PoC, tool personali a basso rischio | `docs/SPEC.md` snello (1 pagina con requisiti, stack e modello dati) | Smoke test + validazione input critici | Baseline essenziale (zero segreti hardcoded, input sicuri) + singolo passaggio combinato Review & Security |
| **`forge`**<br>*(MVP / Standard)* | Web/Mobile app, API autenticate, prodotti B2B/B2C | `docs/PRD.md` + `docs/ARCHITECTURE.md` (con Threat Model) + `docs/DB_SCHEMA.md` | Unit + Integration + Test negativi e AuthZ (401/403/400) | Gate indipendenti bloccanti (`code-reviewer` + `security-engineer` OWASP Top 10) + container non-root |
| **`citadel`**<br>*(Produzione / Critico)* | Fintech, SaaS multi-tenant, dati PII/sensibili, alta affidabilità | PRD con Adversarial Review + ADR + `docs/SECURITY_THREAT_MODEL.md` (STRIDE) + DB Zero-Trust (RLS, cifratura, audit log) | Piramide completa (TDD, Unit, Integration, E2E, Security Regression & Concurrency) | Adversarial Review multi-dimensionale + AppSec Audit completo (`docs/SECURITY_AUDIT.md`) + IaC & Runbook SRE |

---

## 2. Il Team di Ruoli (Skills + Subagent a Contesto Isolato)

Ogni ruolo è accessibile sia come **Skill procedurale** (on-demand o guidata dall'Orchestrator, con template dedicati in `references/`), sia come **Subagent dedicato** con permessi calibrati sul principio del *Least Privilege*:

1. **Tech Lead & Coordinator**
   - **File principali**: [SKILL.md](file:///home/marco/work/bottega-agy/skills/bottega-orchestrator/SKILL.md) · [project-state-template.md](file:///home/marco/work/bottega-agy/skills/bottega-orchestrator/references/project-state-template.md) · [review_and_security_gate.py](file:///home/marco/work/bottega-agy/skills/bottega-orchestrator/scripts/review_and_security_gate.py)
   - **Responsabilità**: esegue il Triage iniziale, mantiene aggiornato `docs/PROJECT_STATE.md`, orchestra le 7 fasi dello sviluppo e coordina i gate di verifica.

2. **Product Strategist** *(PM & Requirements Analyst)*
   - **File principali**: [SKILL.md](file:///home/marco/work/bottega-agy/skills/product-strategist/SKILL.md) · [product-strategist.md](file:///home/marco/work/bottega-agy/agents/product-strategist.md) · [prd-template.md](file:///home/marco/work/bottega-agy/skills/product-strategist/references/prd-template.md)
   - **Responsabilità**: intervista socratica per chiarire requisiti, matrice ruoli/permessi (*Shift-Left Security*), storie utente con criteri *Given/When/Then* e definizione dei *Non-Goals*.

3. **System Architect** *(CTO)*
   - **File principali**: [SKILL.md](file:///home/marco/work/bottega-agy/skills/system-architect/SKILL.md) · [system-architect.md](file:///home/marco/work/bottega-agy/agents/system-architect.md) · [architecture-template.md](file:///home/marco/work/bottega-agy/skills/system-architect/references/architecture-template.md)
   - **Responsabilità**: guida la selezione dello stack tecnologico con matrici di trade-off, disegna l'architettura modulare, definisce i contratti API e stabilisce i confini di sicurezza.

4. **Data Architect** *(DBA & Data Engineer)*
   - **File principali**: [SKILL.md](file:///home/marco/work/bottega-agy/skills/data-architect/SKILL.md) · [data-architect.md](file:///home/marco/work/bottega-agy/agents/data-architect.md) · [db-schema-template.md](file:///home/marco/work/bottega-agy/skills/data-architect/references/db-schema-template.md)
   - **Responsabilità**: progetta diagrammi ER Mermaid, schemi relazionali/NoSQL, strategie di indexing, migrazioni reversibili e policy di protezione/cifratura dati PII.

5. **Software Craftsman** *(Senior Full-Stack Dev)*
   - **File principali**: [SKILL.md](file:///home/marco/work/bottega-agy/skills/software-craftsman/SKILL.md) · [software-craftsman.md](file:///home/marco/work/bottega-agy/agents/software-craftsman.md) · [secure-coding-checklist.md](file:///home/marco/work/bottega-agy/skills/software-craftsman/references/secure-coding-checklist.md)
   - **Responsabilità**: implementa vertical slice modulari e sicure (validazione input, query parametrizzate, controlli anti-IDOR), allegando sempre report di Self-Check ed evidenze concrete di build/lint.

6. **QA Engineer** *(Test Architect)*
   - **File principali**: [SKILL.md](file:///home/marco/work/bottega-agy/skills/qa-engineer/SKILL.md) · [qa-engineer.md](file:///home/marco/work/bottega-agy/agents/qa-engineer.md) · [test-plan-template.md](file:///home/marco/work/bottega-agy/skills/qa-engineer/references/test-plan-template.md)
   - **Responsabilità**: redige `docs/TEST_PLAN.md`, sviluppa ed esegue suite di test automatici (unitari, di integrazione, edge-case e sicurezza negativa), fornendo evidenze di esecuzione.

7. **Security Engineer** *(Principal AppSec)*
   - **File principali**: [SKILL.md](file:///home/marco/work/bottega-agy/skills/security-engineer/SKILL.md) · [security-engineer.md](file:///home/marco/work/bottega-agy/agents/security-engineer.md) · [threat-model-and-audit-templates.md](file:///home/marco/work/bottega-agy/skills/security-engineer/references/threat-model-and-audit-templates.md)
   - **Responsabilità**: esegue il Threat Modeling STRIDE in fase iniziale e opera come Security Gate bloccante in Fase 6 (OWASP Top 10, CWE Top 25, segreti, dipendenze, AuthN/AuthZ).

8. **Code Reviewer** *(Adversarial Staff Engineer)*
   - **File principali**: [SKILL.md](file:///home/marco/work/bottega-agy/skills/code-reviewer/SKILL.md) · [code-reviewer.md](file:///home/marco/work/bottega-agy/agents/code-reviewer.md) · [review-rubric.md](file:///home/marco/work/bottega-agy/skills/code-reviewer/references/review-rubric.md)
   - **Responsabilità**: revisione indipendente in sola lettura sui file sorgente; sfida le assunzioni nei documenti di specifica e valida i diff su 6 dimensioni qualitative, distinguendo tra blocchi critici (*must-fix-now*) e migliorie secondarie (*backlog*).

9. **DevOps & SRE**
   - **File principali**: [SKILL.md](file:///home/marco/work/bottega-agy/skills/devops-sre/SKILL.md) · [devops-sre.md](file:///home/marco/work/bottega-agy/agents/devops-sre.md) · [deployment-runbook-template.md](file:///home/marco/work/bottega-agy/skills/devops-sre/references/deployment-runbook-template.md)
   - **Responsabilità**: guida la configurazione dell'hosting, realizza Dockerfile multi-stage non-root, configura pipeline CI/CD con security gate integrati, monitoraggio, healthcheck e runbook di rilascio/rollback.

---

## 3. Regole Globali, Hook di Sicurezza e Script

- **Regole Core e Politica della Lingua ([AGENTS.md](file:///home/marco/work/bottega-agy/AGENTS.md))**:
  - Gli agenti conversano sempre nella stessa lingua usata dall'utente nel prompt.
  - La documentazione tecnica (`docs/*.md`), i diagrammi, gli schemi e il codice sorgente sono redatti in inglese (salvo diversa esplicita richiesta).
- **Hook Automatico PreToolUse ([hooks.json](file:///home/marco/work/bottega-agy/hooks.json) + [pre-command-guard.sh](file:///home/marco/work/bottega-agy/scripts/pre-command-guard.sh))**:
  - **`deny`**: blocca automaticamente comandi distruttivi di sistema (es. rimozioni ricorsive non sicure).
  - **`ask`**: richiede conferma esplicita prima di operazioni delicate come `git push --force` o esecuzione diretta di script remoti (`curl ... | sh`).
  - **Commit Guard**: intercetta `git commit` e impedisce il salvataggio se rileva file `.env`, chiavi private o token/secret in chiaro nell'area di stage.
- **Scanner Statico di Sicurezza ([security-scan.sh](file:///home/marco/work/bottega-agy/scripts/security-scan.sh))**:
  - Eseguibile su qualsiasi codebase indicando il profilo desiderato:
    ```bash
    ./scripts/security-scan.sh /path/to/project [spark|forge|citadel]
    ```
- **Installer Globale & Workspace ([install.sh](file:///home/marco/work/bottega-agy/scripts/install.sh) e [README.md](file:///home/marco/work/bottega-agy/README.md))**:
  - Script riproducibile per abilitare il plugin su `~/.gemini/config/plugins/bottega` e sincronizzare la configurazione in nuovi workspace.

---

## 4. Come Iniziare Subito

Per avviare il team su un nuovo progetto o feature (supportato anche da slash command di Antigravity come `/plan` o `/grill-me`), invia un prompt iniziale di questo tipo:

> *"Ho un'idea per un'applicazione: **[descrivi qui la tua idea]**. Avvia il team Bottega per eseguire il Triage iniziale e aiutarmi a definirne i requisiti."*
