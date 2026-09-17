# Verifying UI work

Read this when the round changes anything a person looks at in a browser. If the output is static HTML or text, rendering it with the project's own code and grepping the result verifies the markup; a layout complaint (heights, alignment, overflow) still needs the built file opened in a browser, which works from a `file://` URL. Codex cannot open a browser inside its sandbox, and even if it could, judging the result is the part of the job that stays with you.

## What to capture

- **Every spot that changed**, at the desktop width the owner reviews at (usually 1440) and at a phone width (390) where layout could break.
- **A viewport shot of the section**, scrolled into view, rather than a full-page capture. Full-page captures are for the final gate; they are too small to judge a card's spacing.
- **Interactive states by driving them**: click the tab, hover the card, open the menu. An edit that compiles can still swallow a click.

## A batch that actually writes files

Use whatever browser tool the machine has (`agent-browser`, Playwright, the project's own capture script). With `agent-browser`, write the batch as a bash script file and run it with `bash`, with literal commands and absolute output paths:

```bash
#!/bin/bash
AB=agent-browser; R="/abs/path/to/repo/.context/qa/review"; mkdir -p "$R"
go(){ $AB --session rev open "$1" >/dev/null 2>&1; $AB --session rev wait 2800 >/dev/null 2>&1
      [ -n "$2" ] && { $AB --session rev eval "$2" >/dev/null 2>&1; $AB --session rev wait 1100 >/dev/null 2>&1; }
      $AB --session rev screenshot "$R/$3.png" >/dev/null 2>&1; echo "$3"; }
$AB --session rev set viewport 1440 900 >/dev/null 2>&1
go http://localhost:3000/pricing "[...document.querySelectorAll('h2')].find(h=>h.textContent.includes('Compare plans')).scrollIntoView(); window.scrollBy(0,-60); 'ok'" pricing-compare
```

Why a script file: in zsh, a variable holding `agent-browser --session rev` does not word-split, so every call becomes one nonexistent command and the batch silently writes nothing. Why absolute paths: relative ones land in the browser daemon's temp directory. After the batch, `ls` the folder and confirm the count before you start reading images.

## Judging

Open each screenshot and compare it with the owner's complaint in the owner's words, and with the screenshot the owner sent if there was one. The brief's acceptance check passing means Codex did what you wrote; it does not mean what you wrote was right. Results that passed their check and still failed the owner:

- Cards made equal height by stretching, which left a hole in the middle of each card.
- An arrow placed "between" two values in its own grid column, when the owner meant in the middle of the row.
- A diagram made "clearer" by adding labels.

When the result is wrong because the brief was wrong, say so in the correction ("item 3 was my mistake; revert to X and do Y instead"). The agent does not need to be blamed and should not defend the old change.

## Dev server notes

- One dev server for the whole session, started by you, never by a lane. Check the port is yours before you start (`lsof -nP -iTCP:3000 -sTCP:LISTEN`); another workspace may already hold it, and the owner may have a proxy pointed at that port.
- The first request to a freshly written page can return 500 while the bundler compiles. Wait and retry before diagnosing.
- Redirect and rewrite tables are often read at server start. Restart before checking a redirect change.
