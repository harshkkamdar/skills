# skills

Agent skills by [@harshkkamdar](https://github.com/harshkkamdar). Works with Claude Code and any agent that reads the [Agent Skills](https://agentskills.io) format.

```bash
npx skills add harshkkamdar/skills
```

## claude-brain-codex-hands

Run a big, many-file job with **Claude as the brain and OpenAI Codex CLI sessions as the hands**.

Codex does exactly what it is told and is cheap, but judges poorly. Claude judges well and is expensive. This skill splits the work accordingly: Claude reads the request, finds root causes, writes exact work orders and judges the results; one to three persistent Codex sessions apply the edits in parallel, in the same checkout, each inside its own set of files.

On the job it was extracted from (a four-round, roughly 100-file website cleanup), the Codex side used about 40M input tokens, almost all cached, and the Claude side came in roughly ten times cheaper than editing directly.

What is in it:

- `SKILL.md`: when the split pays and when it does not, the three roles, one round in thirteen steps, brief rules, red flags and common mistakes.
- `scripts/init.sh`: one-time setup for a checkout (folders, preamble, local git exclude, Codex trust entry).
- `scripts/lane.sh`: send a brief to a lane. Starts the lane's Codex session the first time and resumes the same thread after that, so the lane keeps its context. `--next` names the next brief, `--fresh` starts a new thread.
- `scripts/status.sh`: where each lane stands, and Codex token totals for the job.
- `references/`: preamble template, brief template with a worked example, setup and session hygiene, UI verification.

Requires the [Codex CLI](https://github.com/openai/codex), installed and logged in.

```bash
npx skills add harshkkamdar/skills --skill claude-brain-codex-hands
```

Then ask: "use Codex as the hands for this, you be the brain", and hand over the review list.

## Licence

MIT
