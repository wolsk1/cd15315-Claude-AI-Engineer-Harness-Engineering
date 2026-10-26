# Reflection Brief — Harness Engineering Capstone

**Name:** Imants Volkovs
**Date:** 26.10.2026

Evidence links below refer to my collected artifacts. System 1 remains incomplete: its saved test run failed during SDK import, and no final-solution claim trace or summary was available. Code-based explanations for that system are identified as such, not presented as successful run observations.

**Environment**

- Model(s): Retail case-facts extraction used `claude-haiku-4-5-20251001`, recorded in [the call log](evidence/system-2-retail/20261026-142551/case_facts_call.json). System 4 used a recorded response rather than live inference; System 3's validator does not use a model. No completed System 1 API run is documented.
- OS / Python: Windows / 3.14.4
- Approx. API spend: Not measured. The Retail artifacts record token usage, but I have not reconciled charges against the provider's usage dashboard; I am not treating the README's estimate as my actual spend.

---

## Part 1 — Per-system

### System 1 — Agentic loop

1. **Loop control.** Quote the `stop_reason` sequence from one trace. Name the file and function that decides continue-vs-stop, and how.
   **Incomplete run evidence:** I cannot quote a trace sequence because no final-solution trace was captured; the [Claims test log](evidence/system-1-claims/tests.log) instead records an SDK import failure. In [claims_intake/loop.py](../Build%20a%20Claims%20Intake%20Agent%20with%20a%20stop_reason-Driven%20Loop/exercises/03-dynamic-decomposition/solution/claims_intake/loop.py), `run()` continues only when `response.stop_reason == "tool_use"` and returns a `FinalState` on `"end_turn"`. Other reasons raise `UnexpectedStopReason`, rather than being interpreted through the assistant's prose. A successful claim trace is still required to verify the actual sequence in my environment.

2. **Anti-pattern.** Name one anti-pattern `test_antipatterns.py` checks for. What would break in your run if the loop used it?
   One prohibited anti-pattern is deciding control flow through string membership in the model's text, such as checking whether an answer contains a completion keyword. The [loop implementation](../Build%20a%20Claims%20Intake%20Agent%20with%20a%20stop_reason-Driven%20Loop/exercises/03-dynamic-decomposition/solution/claims_intake/loop.py) explicitly uses `stop_reason` instead. A prose check could stop a claim prematurely when a keyword appears in a clarification, or continue after a completed response with different wording. This is a code-based risk assessment, not an observed claim failure: my [saved test log](evidence/system-1-claims/tests.log) stopped during import before these checks ran.

3. **Tool design.** Pick two tools with overlapping inputs. How do the descriptions prevent misrouting? What did a structured tool error let the agent do that a generic string would not?
   In [tools.py](../Build%20a%20Claims%20Intake%20Agent%20with%20a%20stop_reason-Driven%20Loop/exercises/03-dynamic-decomposition/solution/claims_intake/tools.py), `classify_claim` and `assess_severity` both accept a `rationale`, but the former selects a claim-type enum and confidence while the latter selects a damage-severity enum after classification. Their descriptions distinguish the business decisions and intended ordering instead of leaving the model to infer the distinction from similar explanatory inputs. Structured errors expose `is_error`, `error_category`, `is_retryable`, and `message`, allowing the model to distinguish a correctable request from a retryable service failure. I have not captured the agent actually recovering from one: the [Claims log](evidence/system-1-claims/tests.log) documents an import failure, so that behavioral example remains missing.

4. **Your numbers.** Quote the turn count and cost for one claim. How does it differ from the README sample, and why?
   **Incomplete:** no claim turn count or cost can be reported from my current evidence. The [Claims log](evidence/system-1-claims/tests.log) records `ModuleNotFoundError` for an Anthropic SDK module, and the [evidence index](evidence/README.md) records that no final-solution run directory was found. I therefore cannot make a measured comparison with the README sample or attribute any difference to model behavior. After repairing the environment, I need a successful run's summary and trace before completing this answer.

### System 2 — Context strategy

5. **The reduction.** From `budget.json`: baseline tokens, assembled tokens, reduction %. Which section dominates the assembled context, and why keep it verbatim?
   In run `20261026-142551`, the [budget](evidence/system-2-retail/20261026-142551/budget.json) reports **38,708 baseline tokens**, **16,883 assembled tokens**, and **56.38% reduction**. The active payment-method issue dominates at **15,789 tokens**, compared with 204 for case facts, 381 for the refund section, and 527 for the subscription section. Keeping the active conversation verbatim preserves exact failure messages, identifiers, and unresolved conversational detail needed for the next response. The per-section counts are measured independently, so they should not be assumed to add exactly to the whole-context token count.

6. **Summarize vs preserve.** State the rule for what gets summarized vs kept byte-exact, citing your per-section token numbers.
   Resolved issues are compressed into summaries, while the active issue's source conversation is preserved byte-exact within its assembled section. My [budget](evidence/system-2-retail/20261026-142551/budget.json) shows **381 tokens** for resolved refund history and **527** for resolved subscription history, versus **15,789** for the active issue. The [assembled context](evidence/system-2-retail/20261026-142551/context.md) places the **204-token case-facts block** first, resolved summaries in the middle, and the active issue last. This spends detail on the unresolved work while retaining compact, explicit facts from older cases.

7. **Facts block.** Compare `eval.jsonl` to `eval_control.jsonl`. Which question regressed, and what does that prove?
   The full-context [eval](evidence/system-2-retail/20261026-142551/eval.jsonl) passed **6/6 questions**, but **Q6 failed** in the [case-facts-stripped control](evidence/system-2-retail/20261026-142551/eval_control.jsonl). Q6 asks for the exact payment-update status token, `in_progress`; without the facts block, the model said it could not find a structured status token. Q1 still passed in the control, correctly retrieving the **$22.14** refund amount from the remaining context. This run supports the facts block's value for exact structured-state retrieval, but one control comparison does not establish that every question depends on it or that performance is deterministic across runs.

### System 3 — Claude Code config

8. **Path-scoped rules.** Quote the glob frontmatter from one rule file. Why is it better than a directory-level CLAUDE.md for cross-cutting conventions?
   The copied [API rule](evidence/system-3-config/.claude/rules/api.md) contains the frontmatter `paths:` followed by `- "src/api/**/*"`. This targets API handlers explicitly rather than loading the handler conventions for every repository file. Although this particular glob covers a single subtree, the same path-rule mechanism can target related files across multiple directories, which is useful for cross-cutting conventions such as co-located tests. The [validator log](evidence/system-3-config/validator.log) reports `OK`, and the [test log](evidence/system-3-config/tests.log) records **35 passed**; these validate the configuration, not a live model's compliance with every rule.

9. **Forked skill.** Quote the `context: fork` and `allowed-tools` lines. What does running forked + read-only buy you? What breaks without it?
   The saved [deploy-check skill](evidence/system-3-config/.claude/skills/deploy-check/SKILL.md) declares the following frontmatter:

   ```yaml
   context: fork
   allowed-tools:
     - Read
     - Grep
     - Glob
     - Bash(git status:*)
     - Bash(git diff:*)
     - Bash(git log:*)
     - Bash(git rev-parse:*)
     - Bash(git ls-files:*)
     - Bash(gh pr view:*)
     - Bash(gh pr checks:*)
   ```

   The fork keeps verbose discovery separate from the parent conversation and returns a compact verdict instead. The restricted tool set excludes the intended workflow's editing and deployment operations, reducing the risk that a validation step changes the thing it is checking. Without isolation, raw logs would consume the parent's context; without restrictions, an accidental write or deploy would have a larger blast radius. My [validator result](evidence/system-3-config/validator.log) confirms the configuration is accepted, but is not evidence that I executed the skill in Claude Code.

10. **Scope.** From the validator output: project-level vs user-level scope. Give one example of each from this config.
    My [validator output](evidence/system-3-config/validator.log) is simply `OK`; it does not print an inventory of user-level settings. The copied [root CLAUDE.md](evidence/system-3-config/CLAUDE.md) identifies the repository's `.claude/rules/` and `.claude/skills/deploy-check/` as project-level, version-controlled configuration shared with teammates. It contrasts these with personal files such as `~/.claude/CLAUDE.md`, and the skill documents a possible personal `~/.claude/skills/deploy-check-strict/` variant. Those user-level paths are documented examples, not personal files that I inspected or proved existed on my machine.

### System 4 — Orchestration

11. **Push work down.** Defects the SQL query returned vs warm-tier total. Name the indexed query. Why does the model never see the full history?
    The saved [metrics](evidence/system-4-monitor/metrics.json) show **17 defects** after `2026-04-01T00:00:00Z` out of **40 total** warm-tier records, and the [scratchpad](evidence/system-4-monitor/data/shift_scratchpad.jsonl) records the same 17-defect working set. In [warm.py](../Build%20a%20Multi-Shift%20Quality%20Monitoring%20System%20with%20Claude%20Orchestration/04-fork-scratchpad/solution/shift_monitor/warm.py), `defects_since()` executes `SELECT * FROM defects WHERE ts > ? ORDER BY ts DESC LIMIT ?`, supported by `idx_defects_ts`. SQL filters and bounds retrieval before the invocation is assembled, rather than asking the model to scan all stored history. The model therefore receives the selected working set for this invocation, not the entire database; the full history remains available for later targeted queries.

12. **Crash recovery.** The resume-vs-fresh decision and its staleness threshold (`recovery.py`). Why is a fresh start with an injected summary sometimes more reliable than resuming?
    In [recovery.py](../Build%20a%20Multi-Shift%20Quality%20Monitoring%20System%20with%20Claude%20Orchestration/04-fork-scratchpad/solution/shift_monitor/recovery.py), an empty or completed manifest starts fresh, while an incomplete manifest resumes only when its last step is at most **30 minutes** old. Older partial work starts fresh; the module describes injecting captured findings as a summary rather than carrying forward stale session state. A fresh invocation can reassess current evidence without inheriting outdated partial assumptions, while still retaining useful durable findings. My [33-pass test log](evidence/system-4-monitor/tests.log) includes the recovery decision truth-table and threshold tests, but the saved shift artifacts do not demonstrate an actual crash-and-resume event.

13. **Small state.** Byte size of your `hot_state.json`. Why does the budget matter for a system run once per shift, indefinitely?
    The [metrics report](evidence/system-4-monitor/metrics.json) measures my saved [hot state](evidence/system-4-monitor/data/hot_state.json) at **980 bytes**, below the approximately 5 KB target. It holds recent defect identifiers, a shift summary, alerts, and threshold statuses rather than the entire defect history. A bounded hot state prevents indefinitely repeated shifts from accumulating an ever-larger startup payload and corresponding context cost. This artifact demonstrates the size for one saved shift, not a long-duration production soak test.

---

## Part 2 — Synthesis

_Graded on connecting two or more systems. Cite a named file/artifact from each._

14. **Three layers.** Point to a file/artifact for each layer and justify.
    **Model:** The Retail [case-facts call log](evidence/system-2-retail/20261026-142551/case_facts_call.json) shows `claude-haiku-4-5-20251001` extracting structured facts from a conversation, which is the semantic reasoning layer.

    **Harness:** Retail's [assembled context](evidence/system-2-retail/20261026-142551/context.md) and [budget](evidence/system-2-retail/20261026-142551/budget.json) show the deterministic packaging and accounting around model calls, reducing the input to **16,883 tokens**.

    **Orchestration:** The monitor's [scratchpad](evidence/system-4-monitor/data/shift_scratchpad.jsonl) and [hot state](evidence/system-4-monitor/data/hot_state.json) carry findings across shift invocations, separating durable workflow continuity from a single model response.

15. **Deterministic vs prompt.** Cite one behavior guaranteed in code (terminal tool, read-only allowlist, atomic write, byte budget) and one guided by prompt. When is each right?
    A deterministic example is the monitor's [30-minute recovery decision](../Build%20a%20Multi-Shift%20Quality%20Monitoring%20System%20with%20Claude%20Orchestration/04-fork-scratchpad/solution/shift_monitor/recovery.py), covered by tests in my [33-pass log](evidence/system-4-monitor/tests.log). A prompt-guided example is Retail's extraction of `payment_update_status: "in_progress"` in the [case-facts call log](evidence/system-2-retail/20261026-142551/case_facts_call.json), whose usefulness is tested by the Q6 [control regression](evidence/system-2-retail/20261026-142551/eval_control.jsonl). Code is appropriate for exact thresholds, permissions, and state transitions that must not depend on wording. Prompted inference is appropriate for interpreting ambiguous natural-language evidence, but its outputs need evaluation rather than being treated as mechanically guaranteed.

16. **Context, two faces.** Compare context management in System 2 (intra-session) and System 4 (cross-session) with cited numbers from both. Same principle, different mechanism — how?
    Retail manages one long conversation by pruning and summarizing older work, reducing **38,708 tokens to 16,883**, or **56.38%**, while preserving the active issue and explicit facts in its [budget](evidence/system-2-retail/20261026-142551/budget.json). The monitor manages continuity across invocations using a **980-byte** hot-state snapshot and a SQL-selected **17/40-record** working set, recorded in its [metrics](evidence/system-4-monitor/metrics.json). Both keep the next decision's context selective rather than treating all historical data as equally relevant. Retail uses position-aware assembly within a session, while the monitor uses durable tiers and retrieval across sessions; byte counts and token counts are different measurements, not directly interchangeable budgets.

17. **Reliability you can't see in one run.** Name one behavior a test guarantees that a single successful run would not reveal. Why does it matter before shipping?
    The monitor's [test log](evidence/system-4-monitor/tests.log) includes `test_mid_write_read_reveals_prior_complete_lines`, which checks recovery when a manifest write is interrupted rather than only when every write succeeds. Its **33 passing tests** provide evidence for this tested failure condition that the saved [normal shift scratchpad](evidence/system-4-monitor/data/shift_scratchpad.jsonl) cannot provide on its own. Retail likewise has **30 passing tests** in its [log](evidence/system-2-retail/tests.log), complementing rather than replacing the observed **6/6 eval** result. Before shipping, failure-path tests matter because a single happy-path run does not exercise partial writes, stale state, or other unusual transitions; passing tests still apply only to their covered conditions.

18. **Blast radius.** Pick one system. What's the blast radius if it misbehaves, and what's the kill switch? Ground it in that system's tools, enforcement points, and state.
    For System 3, a faulty deploy check could give a misleading readiness verdict, exposing any later human or automated decision that trusts it. The saved [skill](evidence/system-3-config/.claude/skills/deploy-check/SKILL.md) limits its intended actions to repository/PR inspection through a read-only allowlist, so it does not itself have deployment or migration commands. The operational stop is to cancel or decline the skill and withhold deployment; the allowlist restricts capability but is not a separate global kill-switch service. The [validator's OK result](evidence/system-3-config/validator.log) confirms configuration conformance, not that a pass verdict is sufficient authorization to release software.

---

## Part 3 — Honest assessment

19. **What broke.** One thing that failed first try in your environment, and how you fixed it. (If nothing, what you checked to be sure.)
    Retail initially failed before starting the pipeline because its deeply nested Windows virtual environment had an incomplete Anthropic installation; reinstalling exposed a Windows path-length-limit error. Moving its environment to `$env:LOCALAPPDATA\venvs\retail-context` allowed dependency installation and command startup to succeed, as documented in the [evidence index](evidence/README.md). The resulting [test log](evidence/system-2-retail/tests.log) has **30 passed**, and run [20261026-142551](evidence/system-2-retail/20261026-142551/budget.json) produced the budget and eval artifacts. Claims still has a separate unresolved SDK import failure in its [test log](evidence/system-1-claims/tests.log), so I am not claiming that all four environments are healthy.

20. **What you'd change.** One architectural decision you'd make differently, grounded in what you observed.
    I would strengthen Retail's compression budget with a deterministic post-assembly check against the authoritative token counter, retrying or rejecting an over-budget resolved summary. My [budget artifact](evidence/system-2-retail/20261026-142551/budget.json) shows the subscription section at **527 tokens**, above the assembler's documented **500-token** section target even though the overall reduction passed. I would account for section headings and formatting in that check and preserve the active conversation rather than silently truncating it. The [6/6 eval result](evidence/system-2-retail/20261026-142551/eval.jsonl) would remain a separate quality gate, since meeting a size budget alone does not establish factual correctness.
