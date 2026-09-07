#!/usr/bin/env bash
# The pact's guard — a PreToolUse hook on Bash while a quest is on.
# Reads the hook's JSON on stdin, looks at tool_input.command, and refuses
# (exit 2, reason on stderr) the things no quest may do:
#   git push --force / --force-with-lease / -f / +ref
#   git commit --amend
#   --no-verify on any git command
#   git push to the base branch (main, master, or the profile's baseBranch)
# and the gh commands that are no phase of any quest:
#   gh pr review --approve, gh pr merge --admin, gh release, gh workflow run,
#   gh api ... /merge
# Everything else exits 0 and the command runs — gh pr merge included: the
# judgement phase merges on the Summoner's words, and no hook can check words.
#
# Behaviour cases: evals/guard/cases.sh in the repository, run with and without jq.

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  # -E, because BSD sed has no \| alternation in a basic regex and would
  # silently extract nothing — a guard that refuses nothing.
  cmd="$(printf '%s' "$input" | sed -E -n 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p' | head -1)"
fi

[ -n "$cmd" ] || exit 0
case "$cmd" in *git*|*gh*) ;; *) exit 0 ;; esac

refuse() { printf 'The guard refuses: %s\n' "$1" >&2; exit 2; }

# Match against the command with quoted text blanked out: a commit message
# that names a flag — git commit -m "never pass --no-verify" — is talk about
# the flag, not use of it. Everything outside the quotes survives, so the
# flags themselves are still seen. One alternation, consumed left to right,
# so whichever quote opens first owns the string: "it's" is a double-quoted
# word, not the start of a single-quoted one that swallows what follows.
scan="$(printf '%s' "$cmd" | sed -E "s/('[^']*'|\"[^\"]*\")/\"\"/g")"

if printf '%s' "$scan" | grep -Eq 'git[^|;&]*push[^|;&]*(--force|--force-with-lease|(^|[[:space:]])-f([[:space:]]|$))'; then
  refuse "a forced push rewrites history somebody may have. Push a new commit instead."
fi
if printf '%s' "$scan" | grep -Eq 'git[^|;&]*commit[^|;&]*--amend'; then
  refuse "--amend rewrites the last commit. Make a new commit instead."
fi
if printf '%s' "$scan" | grep -Eq 'git[^|;&]*--no-verify'; then
  refuse "--no-verify skips a hook. A failing hook means the code needs fixing."
fi

# The judgement is spoken: the Daemon never approves its own scroll, never merges
# past the repository's rules, never ships a release or runs a workflow. The
# word has to end where it is matched — "--json mergeable" is a question.
if printf '%s' "$scan" | grep -Eq 'gh[^|;&]*pr[^|;&]*[[:space:]]--approve([[:space:]]|$)'; then
  refuse "approving is the Summoner's act. The Daemon asks for the words; it never gives them."
fi
if printf '%s' "$scan" | grep -Eq 'gh[^|;&]*pr[^|;&]*[[:space:]]merge[^|;&]*[[:space:]]--admin([[:space:]]|$)'; then
  refuse "--admin merges past the repository's own rules. A refused merge is reported, verbatim."
fi
if printf '%s' "$scan" | grep -Eq 'gh[^|;&]*release[[:space:]]+(create|edit|delete|upload)([[:space:]]|$)'; then
  refuse "a release ships to users. That is the Summoner's decision, after the merge."
fi
if printf '%s' "$scan" | grep -Eq 'gh[^|;&]*workflow[[:space:]]+(run|enable|disable)([[:space:]]|$)'; then
  refuse "running a workflow reaches CI and whatever it deploys. Ask the Summoner first."
fi
if printf '%s' "$scan" | grep -Eq 'gh[^|;&]*api[^|;&]*/merge'; then
  refuse "that API call merges around the judgement. The scroll is merged with gh pr merge, on the words."
fi

base=""
hook_cwd=""
if command -v jq >/dev/null 2>&1; then
  # The payload names the session's directory; the hook's own cwd need not be
  # the project, and a profile read from the wrong place is no profile at all.
  hook_cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
  profile="${hook_cwd:+$hook_cwd/}.claude/repo-profile.json"
  [ -f "$profile" ] && base="$(jq -r '.baseBranch // empty' "$profile" 2>/dev/null)"
fi
# The ref can arrive after a space or after a colon (HEAD:main), carry a
# leading + (which is itself a forced push), and spell itself out in full
# (refs/heads/main). All four shapes push to the same branch.
for b in main master ${base:+"$base"}; do
  # A branch name is a literal here, not a pattern: release.1 must not also
  # match release01.
  b_re="$(printf '%s' "$b" | sed -E 's|[^a-zA-Z0-9_/-]|\\&|g')"
  if printf '%s' "$scan" | grep -Eq "git[^|;&]*push[^|;&]*([[:space:]]|:)\+?(refs/heads/)?$b_re([[:space:]]|:|\$)"; then
    refuse "a push to the base branch '$b'. A quest lands through its scroll (pull request)."
  fi
done

# A push with no ref, or with HEAD as the ref, pushes the branch that is checked
# out; when that is the base branch, it is a push to the base branch. --all and
# --mirror push every branch, the base branch included. --tags pushes none.
seg="$(printf '%s' "$scan" | grep -oE 'git[^|;&]*push[^|;&]*' | head -1)"
case "$seg" in
  *--all*|*--mirror*) refuse "a push of every branch, the base branch included. Push the quest branch by name." ;;
  *--tags*) seg="" ;;
esac
if [ -n "$seg" ]; then
  # Drop the words git and push and every flag; what remains is remote and ref.
  n=0; ref=""
  for w in $seg; do
    case "$w" in git|push|-*) ;; *) n=$((n + 1)); [ "$n" -eq 2 ] && ref="$w" ;; esac
  done
  if [ "$n" -le 1 ] || [ "$ref" = "HEAD" ]; then
    cur="$(git -C "${hook_cwd:-.}" branch --show-current 2>/dev/null)"
    for b in main master ${base:+"$base"}; do
      [ "$cur" = "$b" ] && refuse "a push of the checked-out base branch '$b'. A quest lands through its scroll (pull request)."
    done
  fi
fi

exit 0
