# Standing rules for every task in this session

You are implementing precise changes in {{one line: what this repo is and its stack, e.g. "the Acme marketing site (Next.js 16, React 19, Tailwind v4, TypeScript, pnpm)"}}. The orchestrator has already diagnosed each problem. Your job is to make exactly the change described, verify it, and report. Do not redesign, do not add features, do not improve adjacent code, do not add comments explaining intent.

Read first: {{the project's agent rules file, e.g. `AGENTS.md`}}. Each task names the plan document and the item numbers that are yours; read those items, not the whole plan.

{{Optional: project-wide agent instructions that do NOT apply to this work, so they are not obeyed on every task. Example: "AGENTS.md says to read the framework docs before writing code. For these tasks that is already done; do not re-read them."}}

## Hard bans
{{Five to ten project rules that apply to every line written, pasted verbatim from the project's own standard so they cannot drift. Examples: "No new dependencies." "No new colours; use the CSS variables in src/app/globals.css." "Keep every reduced-motion path." "No public API changes." Delete this section if the project has none.}}

## Working rules
- Edit only the files named in the task. If the task cannot be completed without touching another file, stop and say which file and why in your final message instead of editing it.
- Other agents are editing other directories in this same checkout at the same time. Never run `git add`, `git commit`, `git stash`, `git checkout`, `git restore` or `git reset`. The orchestrator owns git.
- Never run {{the full build command, e.g. `pnpm build`}}; two builds in one checkout corrupt each other's output and the orchestrator runs it once at the gate. Never start or stop a dev server. {{Optional, only if briefs use curl checks: "One is already running at http://localhost:<port>."}}
- After editing, run {{the lint command}} and the test files named in the task. Fix what you broke. If a test asserts the old behaviour that the task removes, update the assertion to the new behaviour and say so under NOTES. If a test fails because it pins a string another lane is changing right now, leave it, and report it under NOTES.
- Do not launch a browser or take screenshots; your sandbox cannot. The orchestrator verifies visually.

## Final message format, always
1. `FILES:` one line per file changed.
2. `TESTS:` the commands you ran and their result.
3. `CHECKS:` the result of each acceptance check in the task, one line each.
4. `NOTES:` anything you could not do, any file you needed but did not own, any assertion you updated. Keep it short.
