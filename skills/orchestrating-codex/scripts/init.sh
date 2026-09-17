#!/usr/bin/env bash
# One-time setup for a checkout: folders, preamble, local git exclude, Codex trust.
# Safe to run again; every step checks before it writes.
set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DIR="${CODEX_DIR:-$ROOT/.context/codex}"

command -v codex >/dev/null 2>&1 || { echo "codex CLI not found. Install it and run 'codex login' first." >&2; exit 1; }
echo "codex: $(codex --version 2>/dev/null)"

mkdir -p "$DIR/briefs" "$DIR/out" "$DIR/notes"
touch "$DIR/sessions.txt"

if [ ! -f "$DIR/preamble.md" ]; then
  cp "$SKILL_DIR/references/preamble-template.md" "$DIR/preamble.md"
  echo "preamble: copied template to $DIR/preamble.md  <- fill in the {{placeholders}} before the first launch"
else
  echo "preamble: $DIR/preamble.md already exists"
fi

# Keep briefs, logs and screenshots out of git without touching the tracked .gitignore.
if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  REL="${DIR#"$ROOT"/}"; TOP="${REL%%/*}"
  if ! git -C "$ROOT" check-ignore -q "$TOP" 2>/dev/null; then
    EXCLUDE="$(git -C "$ROOT" rev-parse --git-path info/exclude)"
    case "$EXCLUDE" in /*) ;; *) EXCLUDE="$ROOT/$EXCLUDE" ;; esac
    mkdir -p "$(dirname "$EXCLUDE")"
    echo "$TOP/" >> "$EXCLUDE"
    echo "git: added $TOP/ to $EXCLUDE"
  else
    echo "git: $TOP/ already ignored"
  fi
fi

# Codex asks for trust interactively on an unknown directory; exec runs cannot answer.
# Both the logical path and the physical one (macOS: /tmp vs /private/tmp), so a hand-run codex matches too.
CFG="${CODEX_HOME:-$HOME/.codex}/config.toml"; mkdir -p "$(dirname "$CFG")"; touch "$CFG"
for P in "$ROOT" "$(cd "$ROOT" && pwd -P)"; do
  if grep -Fq "[projects.\"$P\"]" "$CFG"; then echo "trust: $P already in $CFG"
  else printf '\n[projects."%s"]\ntrust_level = "trusted"\n' "$P" >> "$CFG"; echo "trust: added $P to $CFG (your global Codex config)"; fi
done | sort -u

echo "ready: briefs in $DIR/briefs, logs in $DIR/out"
