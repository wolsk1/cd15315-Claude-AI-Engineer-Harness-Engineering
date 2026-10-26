# Capstone Evidence

Collected on 2026-10-26 from the final solution directories. Test logs are fresh offline runs; existing run artifacts were copied without rerunning paid API calls. No `.env` files or virtual environments are included. The reflection brief remains a separate deliverable.

## System 1: Claims Intake

- [Test log](system-1-claims/tests.log): collection failed with `ModuleNotFoundError: No module named 'anthropic.types.beta.prompt_caching.prompt_caching_beta_tool_param'` in the project's nested virtual environment. This is not passing test evidence.
- No `runs/` directory was found in `exercises/03-dynamic-decomposition/solution` at collection time. The claims summary, trace, and live-run outcomes are missing.
- Remaining: repair the Claims environment, save passing test output, run the final Claims system, and collect its summary and at least one trace. No Claims API run was performed by the collector.

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
- [Verified metrics](system-4-monitor/metrics.json): hot state **980 bytes**, warm database **40 defects**, **17 defects** after `2026-04-01T00:00:00Z`.
- [Hot state](system-4-monitor/data/hot_state.json), [shift scratchpad](system-4-monitor/data/shift_scratchpad.jsonl), and a copy of the warm database are preserved.
- The scratchpad records `17 new defects analyzed since 2026-04-01T00:00:00Z` and the shift-C conclusion.
- The original shift console output was not available to the collector. The metrics were recomputed from saved state without rerunning or changing the shift. Add your original terminal screenshot or log if available.

## Collection

The adjacent `collect-evidence.ps1` captures tests and the offline validator, copies the saved Retail run and monitor data, and recomputes monitor metrics. It does not run live agents, seed the database, or collect credentials. Run it from PowerShell if these logs need refreshing; the four evidence directories must already exist. The Retail run ID is explicitly pinned to the run documented above.