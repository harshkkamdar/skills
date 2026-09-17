#!/usr/bin/env bash
# Send one brief to a lane's Codex session. Starts the session the first time,
# resumes the same thread every time after, so the lane keeps its context.
#
#   lane.sh <lane> <brief.md> [--fresh]
#   lane.sh --next <lane>        print the next task tag (name the brief after it)
#
# A correction is sent the same way as any task: write the paragraph to a brief
# file and launch it. --fresh starts a new thread for the lane (new job or new
# theme); the lane name and its numbering carry on.
#
# Runs in the foreground and exits when Codex finishes. Launch it as a background
# command from the orchestrator (one call per lane, all in the same turn) so the
# lanes run in parallel and the harness reports each exit.
#
# Prompt sent = preamble.md + the brief + every file in notes/ (standing addenda).
# Env: CODEX_DIR (default <repo>/.context/codex), CODEX_SANDBOX (workspace-write),
#      CODEX_NETWORK (true), CODEX_MODEL (unset = Codex default).
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DIR="${CODEX_DIR:-$ROOT/.context/codex}"

# Tags are numbered by counting this lane's logs, so briefs named after the tag never collide.
next_tag() { printf '%s-%02d' "$1" $(( $(find "$DIR/out" -maxdepth 1 -name "$1-[0-9][0-9].jsonl" 2>/dev/null | wc -l | tr -d ' ') + 1 )); }
if [ "${1:-}" = "--next" ] && [ -n "${2:-}" ]; then next_tag "$2"; echo; exit 0; fi

[ $# -ge 2 ] || { echo "usage: lane.sh <lane> <brief.md> [--fresh] | lane.sh --next <lane>" >&2; exit 2; }
LANE="$1"; BRIEF="$2"; FRESH=0
[ "${3:-}" = "--fresh" ] && FRESH=1
[ -f "$BRIEF" ] || { echo "brief not found: $BRIEF" >&2; exit 2; }
command -v codex >/dev/null 2>&1 || { echo "codex CLI not found" >&2; exit 2; }
mkdir -p "$DIR/out" "$DIR/notes"; touch "$DIR/sessions.txt"

ID=""
[ $FRESH -eq 0 ] && ID="$(grep "^$LANE=" "$DIR/sessions.txt" | tail -1 | cut -d= -f2)"

TAG="$(next_tag "$LANE")"
PROMPT="$DIR/out/$TAG.prompt.md"; LOG="$DIR/out/$TAG.jsonl"; LAST="$DIR/out/$TAG.last.md"

{
  [ -f "$DIR/preamble.md" ] && { cat "$DIR/preamble.md"; printf '\n\n'; }
  cat "$BRIEF"
  for f in "$DIR"/notes/*.md; do [ -f "$f" ] && { printf '\n\n'; cat "$f"; }; done
} > "$PROMPT"

# Flags go BEFORE the resume subcommand; after it they are rejected.
FLAGS=(-s "${CODEX_SANDBOX:-workspace-write}" -c "sandbox_workspace_write.network_access=${CODEX_NETWORK:-true}" --json -o "$LAST")
[ -n "${CODEX_MODEL:-}" ] && FLAGS+=(-m "$CODEX_MODEL")

cd "$ROOT" || exit 2
if [ -n "$ID" ]; then
  codex exec "${FLAGS[@]}" resume "$ID" - < "$PROMPT" > "$LOG" 2>&1
else
  codex exec "${FLAGS[@]}" - < "$PROMPT" > "$LOG" 2>&1
fi
RC=$?
echo "EXIT $RC" >> "$LOG"

if [ -z "$ID" ]; then
  ID="$(grep -o '"thread_id":"[^"]*"' "$LOG" | head -1 | cut -d'"' -f4)"
  [ -n "$ID" ] && echo "$LANE=$ID" >> "$DIR/sessions.txt"
fi

echo "== $TAG  exit=$RC  thread=${ID:-unknown}  files_touched=$(grep -o '"path":"[^"]*"' "$LOG" | sort -u | wc -l | tr -d ' ')  (git status is the ground truth)"
grep '"type":"turn.completed"' "$LOG" | tail -1 | grep -o '"usage":{[^}]*}' || true
echo "-- report ($LAST)"
[ -f "$LAST" ] && cat "$LAST" || echo "(no final message; read $LOG)"
exit $RC
