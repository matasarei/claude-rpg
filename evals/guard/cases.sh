#!/usr/bin/env bash
# Behaviour cases for plugins/rpg/scripts/guard.sh — run them from anywhere:
#
#   bash evals/guard/cases.sh
#
# Every case is "expected exit code | the command the hook is asked about".
# The table runs twice: once as the machine is, and once with jq off the PATH,
# because the guard's jq-less fallback is the half that once refused nothing
# when its regex was wrong.
#
# Exits 0 when every case matches, 1 otherwise, naming each mismatch.

set -u

root="$(cd "$(dirname "$0")/../.." && pwd)"
guard="$root/plugins/rpg/scripts/guard.sh"
[ -x "$guard" ] || { printf 'no guard at %s\n' "$guard" >&2; exit 1; }

# A directory with no profile in it, so only main and master are base branches
# and the result does not depend on whose checkout this is.
work="$(mktemp -d)"
# The jq-less PATH: the tools the guard needs, and not jq.
nojq="$work/nojq"; mkdir -p "$nojq"
for t in cat sed grep head; do
  for c in /bin/$t /usr/bin/$t; do [ -x "$c" ] && ln -sf "$c" "$nojq/$t" && break; done
done

fails=0
run() { # run <label> <expected> <json-escaped command> [PATH]
  local label="$1" want="$2" cmd="$3" path="${4-}" got
  if [ -n "$path" ]; then
    ( cd "$work" && printf '{"tool_input":{"command":"%s"}}' "$cmd" | PATH="$path" /bin/bash "$guard" ) >/dev/null 2>&1
  else
    ( cd "$work" && printf '{"tool_input":{"command":"%s"}}' "$cmd" | "$guard" ) >/dev/null 2>&1
  fi
  got=$?
  if [ "$got" != "$want" ]; then
    printf 'FAIL  %-8s want=%s got=%s  %s\n' "$label" "$want" "$got" "$cmd"
    fails=$((fails + 1))
  fi
}

cases() {
  local label="$1" path="${2-}"
  while IFS='|' read -r want cmd; do
    case "$want" in ''|'#'*) continue ;; esac
    run "$label" "$want" "$cmd" "$path"
  done <<'TABLE'
# refused — a forced push, however it is spelled
2|git push --force origin x
2|git push --force-with-lease
2|git push -f origin x
2|cd sub && git push --force
# refused — rewriting or skipping
2|git commit --amend -m \"x\"
2|git commit --no-verify -m \"x\"
2|git push --no-verify
# refused — a push to the base branch, in each of its shapes
2|git push origin main
2|git push -u origin master
2|git push origin HEAD:main
2|git push origin master:master
2|git push origin +main
2|git push origin HEAD:refs/heads/main
2|git push origin +refs/heads/master
2|git push --delete origin main
# allowed — a quest branch whose name merely contains one
0|git push origin quest/x
0|git push origin quest/main-thing
0|git push origin main-thing
0|git push origin domain
0|git push -u origin quest/export-csv
# allowed — talk about a flag is not use of it
0|git commit -m \"never pass --no-verify\"
0|git commit -m \"push --force is banned here\"
0|git commit -m 'do not --amend'
0|git commit -m \"it's done\" && echo \"that's it\"
# refused — apostrophes inside double quotes do not hide a flag between them
2|git commit -m \"it's\" && git push --force && echo \"that's\"
# refused — the flags outside the quotes are still seen
2|git commit -m \"msg\" && git push --force
# allowed — nothing to do with git, or nothing to read
0|ls -la
0|rm -rf build
TABLE
}

# The profile's base branch is read from the payload's cwd, and as a literal.
profiled="$work/profiled"; mkdir -p "$profiled/.claude"
printf '{"baseBranch":"release.1"}' > "$profiled/.claude/repo-profile.json"
run_cwd() { # run_cwd <expected> <command>
  local want="$1" cmd="$2" got
  ( cd "$work" && printf '{"cwd":"%s","tool_input":{"command":"%s"}}' "$profiled" "$cmd" | "$guard" ) >/dev/null 2>&1
  got=$?
  if [ "$got" != "$want" ]; then
    printf 'FAIL  %-8s want=%s got=%s  %s\n' "profile" "$want" "$got" "$cmd"
    fails=$((fails + 1))
  fi
}

# A push with no ref, or HEAD, is a push of the checked-out branch: refused on
# the base branch, allowed on a quest branch. The jq path learns the checkout
# from the payload's cwd; the jq-less path from the hook's own cwd.
checkout() { # checkout <dir> <branch>
  git init -q -b "$2" "$1" 2>/dev/null || { git init -q "$1" && git -C "$1" checkout -q -b "$2"; }
  git -C "$1" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
}
onmain="$work/onmain"; checkout "$onmain" main
onquest="$work/onquest"; checkout "$onquest" quest/x
run_in() { # run_in <dir> <label> <expected> <command> [PATH]
  local dir="$1" label="$2" want="$3" cmd="$4" path="${5-}" got
  if [ -n "$path" ]; then
    ( cd "$dir" && printf '{"tool_input":{"command":"%s"}}' "$cmd" | PATH="$path" /bin/bash "$guard" ) >/dev/null 2>&1
  else
    ( cd "$work" && printf '{"cwd":"%s","tool_input":{"command":"%s"}}' "$dir" "$cmd" | "$guard" ) >/dev/null 2>&1
  fi
  got=$?
  if [ "$got" != "$want" ]; then
    printf 'FAIL  %-8s want=%s got=%s  [%s] %s\n' "$label" "$want" "$got" "$(basename "$dir")" "$cmd"
    fails=$((fails + 1))
  fi
}
checkout_cases() {
  local label="$1" path="${2-}"
  run_in "$onmain" "$label" 2 'git push' "$path"
  run_in "$onmain" "$label" 2 'git push origin' "$path"
  run_in "$onmain" "$label" 2 'git push -u origin HEAD' "$path"
  run_in "$onmain" "$label" 2 'git push --all' "$path"
  run_in "$onmain" "$label" 0 'git push --tags' "$path"
  run_in "$onmain" "$label" 0 'git push origin quest/x' "$path"
  run_in "$onquest" "$label" 0 'git push' "$path"
  run_in "$onquest" "$label" 0 'git push -u origin HEAD' "$path"
}

cases 'jq'
if command -v jq >/dev/null 2>&1; then
  run_cwd 2 'git push origin release.1'
  run_cwd 0 'git push origin release01'
  checkout_cases 'jq'
fi
if [ -x "$nojq/sed" ]; then
  cases 'no-jq' "$nojq"
  # git itself is needed for the checkout cases on this path.
  for c in /bin/git /usr/bin/git /usr/local/bin/git /opt/homebrew/bin/git; do [ -x "$c" ] && ln -sf "$c" "$nojq/git" && break; done
  [ -x "$nojq/git" ] && checkout_cases 'no-jq' "$nojq"
fi

rm -rf "$work"
if [ "$fails" -eq 0 ]; then
  printf 'guard: all cases pass\n'
else
  printf 'guard: %s case(s) failed\n' "$fails" >&2
fi
exit $((fails > 0))
