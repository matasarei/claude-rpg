# claude-rpg — notes for Claude

A Claude Code plugin marketplace with one plugin, `rpg` (`plugins/rpg/`): six skills, three
subagents, one hook script and a `reference/` folder of procedures, all markdown except
five shell scripts under `scripts/`. There is no build, no language runtime and no test
framework; the checks are the `claude` CLI's validator, the guard script fed known inputs, the
eval suite under `plugins/rpg/evals/` (early access on some accounts), and smoke runs of the
skills in a throwaway repository.

## Commands

| What | Command |
|---|---|
| Install | none — load it with `claude --plugin-dir /Users/hc/Projects/claude-rpg/plugins/rpg`, or `/plugin marketplace add /Users/hc/Projects/claude-rpg` + `/plugin install rpg@claude-rpg` |
| Test | `claude plugin validate plugins/rpg && claude plugin validate plugins/rpg/skills && claude plugin validate plugins/rpg/agents`, then `bash evals/run-all.sh` (the guard's behaviour cases with and without `jq`, and the skills' invariants) and `shellcheck --severity=warning plugins/rpg/scripts/*.sh plugins/rpg/evals/*/scaffold.sh evals/*.sh evals/*/*.sh`; CI runs the same on every push and pull request (`.github/workflows/checks.yml`) |
| Lint | `claude plugin validate .` (the `version` warning is intended) |
| Build | none — nothing is generated |
| Run | `claude --plugin-dir /Users/hc/Projects/claude-rpg/plugins/rpg`, then `/rpg:summon` in any repository; `/reload-plugins` picks up edits |

Everything runs on the host; there is no container because there is nothing to contain. No
`timeout` or `gtimeout` on this machine — a hanging smoke run has to be stopped by hand.

**Smoke test** a skill in a fresh non-interactive session, from a throwaway git repository
(never from a real project):

```bash
claude -p "/rpg:summon" --plugin-dir /Users/hc/Projects/claude-rpg/plugins/rpg \
  --permission-mode acceptEdits --allowedTools "Bash(git *)" "Bash(ls *)" "Bash(cat *)" "Bash(gh *)" \
  --max-turns 40 --output-format text < /dev/null
```

A run that returns instantly with no output means the skill invocation aborted before Claude saw
it; the reason is in the newest file under `~/.claude/debug/` (grep `permission check failed`).

## This project specifically

- **The plugin is self-contained.** Nothing under `plugins/rpg/` names another plugin, a
  directory or a file outside itself — `grep -rn -i 'gku\|\.tasks/\|\.gku/' plugins/rpg` must
  print nothing. Every in-plugin path is `${CLAUDE_PLUGIN_ROOT}/…`; `Read(/${CLAUDE_PLUGIN_ROOT}/**)`
  (double slash, absolute form) is what pre-approves reading them.
- **Injected commands** (`` !`…` `` in a `SKILL.md`) are plain commands ending in `|| true` or an
  `|| echo` fallback. The harness refuses, and silently aborts the whole skill on: `cat` of a
  file outside the working directory, and any command substitution `$(…)`. Plugin files are
  brought in through a bundled script (`scripts/voice.sh`), never `cat`.
- **Skills that write** (`summon`, `quest`, `questline`, `sidequest`) carry
  `disable-model-invocation: true`; skills that only read (`journal`, `evocation`) carry
  `disallowed-tools: Edit, Write, NotebookEdit` and a `when_to_use` line.
- **The scripts do the reading.** `scripts/survey.sh` (the whole land in one pass, injected into
  `/rpg:summon`), `scripts/quests.sh` (the Road: one line per quest with state, last Log line and
  last ruling, injected into every skill that needs it; skips `lore.md`), `scripts/slug.sh` (the
  quest slug from a goal, deterministic), `scripts/voice.sh` (prints the voice for injection).
  Facts come from them as data; the Daemon opens a file only for what they did not settle. A new
  fact every skill needs goes into a script, not into prose.
- **Evals** (`plugins/rpg/evals/`): four cases with self-built fixtures for `claude plugin eval
  plugins/rpg --scaffold`. Each scaffold must build and its test pass (`bash scaffold.sh` in a
  temp dir); `case.yaml` must parse (Ruby's YAML is on this machine, PyYAML is not).
- **The guard** (`scripts/guard.sh`) is a `PreToolUse` hook declared in the frontmatter of the
  writing skills. It refuses `--force`, `--force-with-lease`, `--no-verify`, `--amend` and any
  push to `main`/`master`/the profile's base branch, exit 2 with the reason on stderr.
- **The words are the product.** Roles: the Summoner (user), the Daemon (Claude), forks
  (`fork-scout`, `fork-hand`, `fork-eye` — the Daemon split), spirits (other agents), the pact
  (the rules floor). Phases: summon, scry (draws the map), cast, trial, scroll, judgement. Only
  game words for phases and roles; technical facts (paths, commands, runner lines, URLs) are
  always verbatim. `reference/voice.md` is the authority.
- **The plugin never marks a user's project.** `/rpg:summon` writes `.quests/` and
  `.claude/repo-profile.json` inside the project but hides them through git's *global* excludes
  file; it never touches a project's `.gitignore`, `CLAUDE.md` or `AGENTS.md`. Keep it that way.
- **No `version` in `plugin.json` or `marketplace.json`** — deliberate, so every commit is an
  update. Do not "fix" the validator's warning.
- **Five reference files were carried over from `grinchenkoedu/claude-skills` (MIT)** —
  `repo-profile.md`, `exec.md`, `untrusted-input.md`, `security-checklist.md`,
  `code-provenance.md`. The credit paragraph in `LICENSE` and the line in the README stay.
- **Ignored, never committed:** `.claude/repo-profile.json`, `.quests/`, `.tasks/`, `.idea/`.
- **Changes land through pull requests** on `main`; identifiers and commit messages in English.
