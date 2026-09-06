#!/usr/bin/env bash
# The road so far, as data: one line per file in .quests/ — kind, status, and the
# frontmatter fields the journal needs, plus the last Log line. Read-only.
# Injected into the skills so the Daemon reads a table, not every quest file.
dir="${1:-.quests}"
[ -d "$dir" ] || { echo "no $dir/ — run /rpg:summon first"; exit 0; }
found=0
for f in "$dir"/*.md; do
  [ -e "$f" ] || continue
  found=1
  awk -v file="$f" '
    BEGIN { fm=0; kind="?"; status="?"; ql="null"; br="null"; pr="null"; dec="null"; found="null"; title=""; last="" }
    NR==1 && $0=="---" { fm=1; next }
    fm==1 && $0=="---" { fm=2; next }
    fm==1 {
      split($0, kv, ": "); k=kv[1]; v=substr($0, length(k)+3)
      if (k=="kind") kind=v; else if (k=="status") status=v; else if (k=="questline") ql=v
      else if (k=="branch") br=v; else if (k=="pr") pr=v; else if (k=="decision") dec=v
      else if (k=="found-during") found=v
      next
    }
    fm==2 && title=="" && /^# / { title=substr($0,3); next }
    /^- / { last=$0 }
    END {
      printf "%s | %s | %s | title: %s | questline: %s | branch: %s | pr: %s | decision: %s | found-during: %s\n", file, kind, status, title, ql, br, pr, dec, found
      if (last!="") printf "    last: %s\n", substr(last,3)
    }' "$f"
done
[ "$found" = 1 ] || echo "$dir/ is empty — no quests yet"
