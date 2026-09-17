# Setup and sessions

Read before the first launch in a checkout, and whenever `.context/codex/` already exists.

## Before anything

Look for what earlier sessions left: a project handoff doc or memory note about this workflow (it holds the repo-specific commands a generic skill cannot), and an existing `.context/codex/` folder (see "Picking up an old checkout").

## init.sh

`bash <skill>/scripts/init.sh`, from the repo root. Safe to rerun. It:

- checks the Codex CLI is installed (log in with `codex login` first);
- creates `.context/codex/{briefs,out,notes}` and `sessions.txt`;
- copies `references/preamble-template.md` to `.context/codex/preamble.md` if none exists;
- adds `.context/` to the local git exclude (`.git/info/exclude`), leaving the tracked `.gitignore` alone;
- **appends a trust entry for this checkout to the global `~/.codex/config.toml`**, because an exec run cannot answer Codex's interactive trust prompt. Tell the owner if they would not expect their global config to change.

## Then, once

- **Git.** If you are on the default branch, branch once now. Fetch and reconcile with upstream before round one, since lanes will edit on top of it. After that, no branch per lane or per round; grouped commits are the rollback points.
- **One dev server, yours**, if the work has a UI. Check the port first (`lsof -nP -iTCP:3000 -sTCP:LISTEN`); another project may hold it, and the owner may have a proxy pointed at it. Lanes never start servers.
- **Fill in the preamble.** It rides in front of every brief, so anything true for the whole job goes there once:
  - what the repo is, and what to read first;
  - the five to ten hard rules that apply to every line Codex writes, pasted verbatim from the project's own standard so they cannot drift;
  - project-wide agent instructions that do **not** apply to a lane's work (for example "read the framework docs before writing any code"), scoped down explicitly, or Codex will obey them on every task;
  - the lint and build commands;
  - the fixed report format (`FILES / TESTS / CHECKS / NOTES`), which is what lets you read a report in seconds.
- **Network.** Lanes run with network access on by default so installs and test tooling work. Set `CODEX_NETWORK=false` if the project should not have it. `CODEX_MODEL` and `CODEX_SANDBOX` override the model and sandbox mode.

## Threads

- A thread holds three to five tasks, corrections included; after that, `--fresh` with the same lane name.
- Thread ids live in `.context/codex/sessions.txt` as `lane=id`; the last line for a lane wins. The id is the `thread_id` in the first line of each `--json` log.
- If you ever call Codex by hand: every flag goes **before** `resume`. After the subcommand only a few (`-c`, `-m`, `-o`) are accepted; `-s` and `-C` are rejected.
- `status.sh --usage` totals Codex tokens across the job. Quote it when the owner asks whether the split is saving anything.

## Picking up an old checkout

Read `sessions.txt`, `plans.txt`, the latest `out/*.last.md` reports and any project handoff doc.

- Same job, young threads: resume them.
- New job, or threads past five tasks: keep the lane names, launch `--fresh`.
- An older layout may have left a filled-in preamble somewhere else (for example `briefs/00-preamble.md`). Reuse its contents in `preamble.md` rather than starting from the blank template.
- Name new briefs with `lane.sh --next <lane>`, so an old brief is never overwritten.

## At the end of the job

Save the project-specific lessons (the lane split that worked, the gate commands, the traps) to memory or a handoff doc in the repo, so the next session does not rediscover them.
