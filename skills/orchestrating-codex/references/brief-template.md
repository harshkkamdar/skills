# Brief template and a real example

A brief is a work order, not a request. Codex will do what the words say and nothing the words imply, so every decision has to be made before the brief is written. If you find yourself writing an adjective ("cleaner", "clearer", "tighter"), you have not finished diagnosing; go back and decide what the change actually is.

## Template

```markdown
# Task <lane>-<NN>: <what this round does for this lane, in one line>

Read `<plan or review doc>` <section> first.
Ownership: `<paths this lane may edit>`.
Other lanes: <who owns what, so this agent does not edit across the boundary>.
<Anything new that exists since the last task: a primitive, a type, a renamed file.>

## <owner's item id>. <Item name>
`<file>` `<symbol or line>`: <what is there now>. Change to <exactly what it becomes>.
<Exact strings, class names, copy, signatures in backticks.>
Check: <one thing Codex can verify without a browser: a grep that must return nothing,
a curl status, a test name>.

## <next id>. ...

## Tests
`<lint command>`, `<targeted test command>`. Update assertions that encoded the old
behaviour; list them under NOTES.
```

## Rules of thumb

- **Name the file after the launcher's tag.** `lane.sh --next <lane>` prints it; the brief, the log and the report then share one number, and an old brief is never overwritten.
- **One section per item, numbered with the owner's item ids** (so item 5 is `## 5.` in whichever lane it lands; the numbers are how you refer back in a correction). Give each the file, the symbol or line, the exact before and the exact after.
- **Bulk replacements: anchor on a unique key, give only the after.** Twenty-six rewritten answers with before and after would blow the length limit; "the entry whose `q` is `<exact question>` gets answer `<exact new string>`" does not. Check the keys are unique yourself before sending.
- **Exact strings in backticks.** Class names, copy, prop names, routes. Anything left to taste comes back wrong, and the correction round costs more than the precision would have.
- **Ownership at the top, other lanes named.** A helpful agent that edits across the boundary collides with the lane that owns the file.
- **One acceptance check per item that runs without a browser.** `grep -rn "old-thing" src/components/site` returns nothing; `curl -s -o /dev/null -w '%{http_code}' localhost:3000/pricing` prints 200; a named test passes. This is what lets Codex catch its own misses before you spend tokens reading them.
- **Cross-lane changes are split in the same round.** Removing a data field: the content lane makes the type optional and drops the values; the component lane renders conditionally. Neither waits on the other and neither breaks the type check.
- **About 150 lines, or a few dozen items.** The limit is really about how much Codex holds at once, not line count. Bigger briefs get partial results; split by theme and send the second half as the next task on the same thread.
- **A guard test can be the acceptance check.** "Add a test in `<file>` asserting no answer exceeds two sentences" is in scope even though the preamble says no new features; it is how the item proves itself.
- **Say what not to do** when the obvious wrong fix is tempting: "do not edit content; split the string in the component".
- **Corrections are one paragraph in a brief file of their own**, named after the next tag and launched like any task: what is wrong in the result, which item number, the exact fix. The thread already has the context. A correction counts towards the thread's three to five tasks.

## Worked example (excerpt)

From a marketing-site cleanup, second round. Item 1 corrects the orchestrator's own earlier mistake, stated plainly so the agent does not defend the old change.

```markdown
# Task ui-04: round-2 component corrections (A1 hover ring, A2 tags)

Read `docs/reviews/round-2.md` Part A, items A1 and A2.
Ownership: `src/components/{home,pricing,solutions}/**`.
Another agent owns `src/components/{header,footer}/**`; a third owns `src/content/**`.
A new primitive exists: `Tag` in `src/components/ui/tag.tsx`. Use it; do not restyle it.

## A1. Accent hover ring
Round 1 replaced hover rings with `hover:ring-neutral-900/20`. Change every one of those
back to `hover:ring-accent` (keep the `[@media(hover:hover)]` gate and
`transition-shadow duration-150`). No transform, no shadow.
Check: `grep -rn "neutral-900/20" src/components/{home,pricing,solutions}` returns nothing.

## A2. Cost sources as tags
`pricing/cost-figure.tsx` `CostFigure`: the line
"Contracts · licences · usage · infrastructure · services" is split on " · " and rendered
as `<Tag>` elements in a `flex flex-wrap gap-1.5` row under the "Where the cost comes from"
label. The string comes from content; split it in the component, do not edit content.
Check: `grep -n '" · "' src/components/pricing/cost-figure.tsx` shows only the split call.

## Tests
`pnpm lint`, `pnpm vitest run src/components` (or the whole suite if the runner cannot target a file). Update assertions that encoded the neutral
ring; list them under NOTES.
```

## What a bad brief looks like

> "The cost diagram is confusing. Make it clearer and tidy up the labels."

Two adjectives and no decision. The version that worked was decided by the orchestrator first (plain flow, 56px rows, no added text) and then briefed as exact values.
