#!/usr/bin/env bash
# Invariants of the RPG skills — run them from anywhere:
#
#   bash evals/skills/invariants.sh
#
# The rules these assert are the ones CLAUDE.md states and a reader of a skill's
# description relies on: a skill that writes is never fired by the model on its
# own and registers the guard; a skill that only reads never edits and says when
# the model may invoke it; every injected line survives a failure and contains
# nothing the harness refuses; and nothing under the plugin reaches for gku.
#
# Exits 0 when every rule holds, 1 otherwise, naming each mismatch.

set -u

root="$(cd "$(dirname "$0")/../.." && pwd)"
plugin="$root/plugins/rpg"
skills="$plugin/skills"
# A run that finds nothing to check must fail, not pass.
[ -d "$skills" ] || { printf 'no skills at %s\n' "$skills" >&2; exit 1; }
[ -n "$(ls -d "$skills"/*/ 2>/dev/null)" ] || { printf 'no skills under %s\n' "$skills" >&2; exit 1; }

# The deliberate lists. A new skill that writes or reads belongs in one of them,
# and adding it here is part of adding the skill.
WRITES="quest questline sidequest"     # never model-invoked; register the guard
SUMMON="summon"                        # never model-invoked; writes only the profile, no hook
READS="journal evocation"              # read-only by mechanism; model may invoke

fails=0
checked=0
note() { printf 'FAIL  %s\n' "$1"; fails=$((fails + 1)); }
head_of() { sed -n '2,/^---$/p' "$skills/$1/SKILL.md"; }   # the frontmatter, minus its opening ---
has() { head_of "$1" | grep -q "^$2"; }
in_list() { case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

for dir in "$skills"/*/; do
  s="$(basename "$dir")"
  [ -f "$dir/SKILL.md" ] || continue
  checked=$((checked + 1))

  if in_list "$s" "$WRITES" || in_list "$s" "$SUMMON"; then
    has "$s" 'disable-model-invocation: true' || note "$s: writes, but lacks disable-model-invocation: true"
    has "$s" 'when_to_use:' && note "$s: writes, but carries when_to_use"
  fi
  if in_list "$s" "$WRITES"; then
    head_of "$s" | grep -q 'scripts/guard.sh' || note "$s: writes, but does not register the guard"
  fi
  if in_list "$s" "$READS"; then
    has "$s" 'disable-model-invocation' && note "$s: reads, but carries disable-model-invocation"
    has "$s" 'when_to_use:' || note "$s: reads, but lacks when_to_use"
    for t in Edit Write NotebookEdit; do
      head_of "$s" | grep -E '^disallowed-tools:' | grep -q "$t" || note "$s: reads, but disallowed-tools lacks $t"
    done
    head_of "$s" | grep -q 'scripts/guard.sh' && note "$s: reads, but registers the guard"
  fi
  in_list "$s" "$WRITES $SUMMON $READS" || note "$s: not in any list above — decide what it is"

  # Injected lines: !`cmd` one-liners and the lines inside ```! blocks. Each
  # ends in || true so a failure injects nothing instead of aborting the skill,
  # and none contains $( ), which the harness refuses and aborts on silently.
  while IFS= read -r line; do
    case "$line" in
      *'|| true'*) ;;
      *) note "$s: injected line without || true: $line" ;;
    esac
    case "$line" in
      *'$('*) note "$s: injected line contains \$( ): $line" ;;
    esac
  done <<LINES
$(grep -E '^!`' "$dir/SKILL.md" | sed -E 's/^!`(.*)`$/\1/'; awk '/^```!/{f=1; next} /^```$/{f=0} f' "$dir/SKILL.md")
LINES

  # The voice is injected by every skill.
  grep -q 'scripts/voice.sh' "$dir/SKILL.md" || note "$s: does not inject the voice"
  # Every skill ends with the Next block.
  grep -q '^## Next' "$dir/SKILL.md" || note "$s: has no ## Next section"
done

# Self-contained: nothing under the plugin reaches for the gku skills or their files.
if hits="$(grep -rn -i 'gku\|\.tasks/\|\.gku/' "$plugin" 2>/dev/null)" && [ -n "$hits" ]; then
  note "the plugin mentions gku or its directories:"
  printf '%s\n' "$hits" | sed 's/^/      /'
fi

# The scripts the skills call exist and are executable.
for sc in voice.sh survey.sh quests.sh slug.sh guard.sh; do
  [ -x "$plugin/scripts/$sc" ] || note "scripts/$sc is missing or not executable"
done

if [ "$fails" -eq 0 ]; then
  printf 'skills: invariants hold across %s skills\n' "$checked"
else
  printf 'skills: %s rule(s) broken\n' "$fails" >&2
fi
exit $((fails > 0))
