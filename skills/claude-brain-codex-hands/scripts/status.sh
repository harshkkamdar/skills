#!/usr/bin/env bash
# Where every lane stands, and what the Codex side has cost so far.
#
#   status.sh           latest task per lane
#   status.sh --usage   token totals across every task in this checkout
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DIR="${CODEX_DIR:-$ROOT/.context/codex}"
[ -d "$DIR/out" ] || { echo "no $DIR/out; run init.sh first" >&2; exit 1; }

if [ "${1:-}" = "--usage" ]; then
  grep -h '"type":"turn.completed"' "$DIR"/out/*.jsonl 2>/dev/null | awk '
    function num(k,   m) { if (match($0, "\"" k "\":[0-9]+")) { m = substr($0, RSTART, RLENGTH); sub(/.*:/, "", m); return m + 0 } return 0 }
    { i += num("input_tokens"); c += num("cached_input_tokens"); o += num("output_tokens"); t++ }
    END { printf "tasks %d | uncached input %d | output %d | cached input %d (billed at a fraction)\n", t, i - c, o, c }'
  exit 0
fi

# Lanes are read from the logs, not sessions.txt, so a lane shows up while it is still running.
LANES="$(find "$DIR/out" -maxdepth 1 -name "*-[0-9][0-9].jsonl" -exec basename {} .jsonl \; | sed 's/-[0-9][0-9]$//' | sort -u)"
[ -n "$LANES" ] || { echo "no lanes yet"; exit 0; }
for lane in $LANES; do
  f="$(find "$DIR/out" -maxdepth 1 -name "$lane-[0-9][0-9].jsonl" | sort | tail -1)"
  [ -n "$f" ] || continue
  if grep -q '^EXIT' "$f"; then state="done ($(grep '^EXIT' "$f" | tail -1))"; else state="running"; fi
  printf '%-22s %-16s events %-5s files_touched %-4s errors %s\n' "$(basename "$f" .jsonl)" "$state" \
    "$(wc -l < "$f" | tr -d ' ')" "$(grep -o '"path":"[^"]*"' "$f" | sort -u | wc -l | tr -d ' ')" "$(grep '"type":"error"' "$f" | grep -vc 'Skill descriptions were shortened')"
done
