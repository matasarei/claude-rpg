#!/usr/bin/env bash
# The Daemon's guard — a PreToolUse hook on Bash while a quest is on.
# Reads the hook's JSON on stdin, looks at tool_input.command, and refuses
# (exit 2, reason on stderr) the things no quest may do:
#   git push --force / --force-with-lease / -f
#   git commit --amend
#   --no-verify on any git command
#   git push to the base branch (main, master, or the profile's baseBranch)
# Everything else exits 0 and the command runs.

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  cmd="$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -1)"
fi

[ -n "$cmd" ] || exit 0
case "$cmd" in *git*) ;; *) exit 0 ;; esac

refuse() { printf 'The guard refuses: %s\n' "$1" >&2; exit 2; }

if printf '%s' "$cmd" | grep -Eq 'git[^|;&]*push[^|;&]*(--force|--force-with-lease|(^|[[:space:]])-f([[:space:]]|$))'; then
  refuse "a forced push rewrites history somebody may have. Push a new commit instead."
fi
if printf '%s' "$cmd" | grep -Eq 'git[^|;&]*commit[^|;&]*--amend'; then
  refuse "--amend rewrites the last commit. Make a new commit instead."
fi
if printf '%s' "$cmd" | grep -Eq 'git[^|;&]*--no-verify'; then
  refuse "--no-verify skips a hook. A failing hook means the code needs fixing."
fi

base=""
if [ -f .claude/repo-profile.json ] && command -v jq >/dev/null 2>&1; then
  base="$(jq -r '.baseBranch // empty' .claude/repo-profile.json 2>/dev/null)"
fi
for b in main master $base; do
  if printf '%s' "$cmd" | grep -Eq "git[^|;&]*push[^|;&]*[[:space:]](origin[[:space:]]+)?(refs/heads/)?$b([[:space:]]|:|\$)"; then
    refuse "a push to the base branch '$b'. A quest lands through its scroll (pull request)."
  fi
  if printf '%s' "$cmd" | grep -Eq "git[^|;&]*push[^|;&]*:$b([[:space:]]|\$)"; then
    refuse "a push to the base branch '$b'. A quest lands through its scroll (pull request)."
  fi
done

exit 0
