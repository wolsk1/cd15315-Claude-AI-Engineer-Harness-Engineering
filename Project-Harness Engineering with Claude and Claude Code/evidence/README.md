# Capstone Evidence

Collected and refreshed on 2026-10-26 from the final solution directories. All four full suites pass: **30 Claims + 30 Retail + 35 Config + 33 Monitor = 128 tests**. A live Claims run was added to address the original missing evidence; Retail and Monitor artifacts were preserved without repeating their API or shift runs. No `.env` files or virtual environments are included. The reflection brief is included alongside this evidence in the submission ZIP.

## System 1: Claims Intake

- [Test log](system-1-claims/tests.log): **30 passed** in the repaired short-path environment at `$env:LOCALAPPDATA\venvs\claims-intake`.
- [Original failure log](system-1-claims/tests-before-repair.log): preserves the missing Anthropic SDK module error before the environment repair.
- [Run summary](system-1-claims/20261026_171247/summary.md): **8 fixtures**, **2 routed / 6 escalated**, **$0.1215 estimated total cost**; runner exit code 0.
- [Auto-collision trace](system-1-claims/20261026_171247/traces/claim_05_auto_collision.jsonl): `tool_use -> tool_use -> tool_use -> end_turn`, **4 turns**, **$0.0207 estimated claim cost**.
- The complete run folder includes all eight traces, routed queue records, and [six escalation records](system-1-claims/20261026_171247/escalations.jsonl). All six escalations are explicitly marked as deterministic backstops after the model ended without a terminal action, not model-selected escalation calls.
- [Console log](system-1-claims/run.log): original captured output. Windows PowerShell formats the runner's first stderr progress line as a native-command error record; the runner continued and returned 0. The summary, JSONL records, and terminal exit status distinguish this display artifact from a failed run.
- The README sample's expected route/escalation distribution was not achieved. Safe termination and passing offline tests do not imply exact model-outcome accuracy.

## System 2: Retail Context

- [Test log](system-2-retail/tests.log): **30 passed** after the saved run.
- Run ID: **20261026-142551**.
- [Token budget](system-2-retail/20261026-142551/budget.json): baseline **38,708**, assembled **16,883**, reduction **56.38%**.
- [Evaluation](system-2-retail/20261026-142551/eval.jsonl): **6/6 passed**.
- [Control evaluation](system-2-retail/20261026-142551/eval_control.jsonl): **Q6 regressed**; Q1 still passed.
- [Assembled context](system-2-retail/20261026-142551/context.md) and [case-facts call log](system-2-retail/20261026-142551/case_facts_call.json) are preserved.
- Environment issue encountered: the deeply nested virtual environment exceeded Windows path-length limits during SDK installation. A shorter environment at `$env:LOCALAPPDATA\venvs\retail-context` restored startup and passing tests.

## System 3: Team Configuration

- [Test log](system-3-config/tests.log): **35 passed**.
- [Validator output](system-3-config/validator.log): **OK**, exit code 0.
- Root configuration, `.claude/`, `src/`, and `docs/` were copied to preserve the hierarchy, rules, commands, skill, and decision-document evidence.

## System 4: Shift Monitor

- [Test log](system-4-monitor/tests.log): **33 passed**.
- [Focused fork-isolation log](system-4-monitor/fork-isolation-tests.log): **4 passed**, verifying copied base state, independent H1/H2 scratchpads, unchanged base bytes, and explicit append-only merging.
- [Verified metrics](system-4-monitor/metrics.json): hot state **980 bytes**, warm database **40 defects**, **17 defects** after `2026-04-01T00:00:00Z`.
- [Hot state](system-4-monitor/data/hot_state.json), [shift scratchpad](system-4-monitor/data/shift_scratchpad.jsonl), and a copy of the warm database are preserved.
- The scratchpad records `17 new defects analyzed since 2026-04-01T00:00:00Z` and the shift-C conclusion.
- The original shift console output was not available to the collector. The metrics were recomputed from saved state without rerunning or changing the shift. Add your original terminal screenshot or log if available.

## Collection

The parent folder's `collect-evidence.ps1` captures tests and the offline validator, requires all four suites to pass, copies the saved Claims and Retail runs and monitor data, and recomputes monitor metrics. It does not run live agents, seed the database, or collect credentials. Run it from PowerShell if these logs need refreshing; the four evidence directories must already exist and the referenced original solution folders must be present. Both live-run IDs are explicitly pinned to the runs documented above.