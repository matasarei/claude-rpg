# Claude RPG

<p>
  <img src="https://img.shields.io/badge/Claude_Code-D97757?style=for-the-badge&logo=claude&logoColor=white" alt="Claude Code" /> <img src="https://img.shields.io/badge/License-MIT-3DA639?style=for-the-badge" alt="License: MIT" />
</p>

Skills for [Claude Code](https://claude.com/claude-code) that turn a day of development into a
party on a road. **You are the Medium.** You lead, you feel where to go, you see ahead — and
sometimes you are out of mana and want a road proposed. **Claude is the Archmage.** It can do
everything, but it follows your vision; once the plan is clear it casts on its own, and stops
only twice per quest: once if it has one question, and once at the end, for your judgement.

Work is **quests**. A quest is one piece of work that ends in one merged pull request. Big
things are **questlines** — a road of quests to one goal. Things found on the way that are not
blocking are **sidequests**, written down and taken now or after. When there is too much for
one pair of hands, the Archmage summons **mirrors** — subagents that scout, cast a part, or
read a diff as a second pair of eyes.

The voice is short and plain, in the spirit of the game *Nox*: easy to read for a non-native
speaker, game-like, never in the way of the facts. Paths, commands, test lines and errors are
always quoted as they are.

## Contents

- [Install](#install)
- [The party](#the-party)
- [The skills](#the-skills)
- [A quest, start to finish](#a-quest-start-to-finish)
- [Questlines and sidequests](#questlines-and-sidequests)
- [Mirrors](#mirrors)
- [What the Archmage never does](#what-the-archmage-never-does)
- [Files it writes](#files-it-writes)
- [A sample session](#a-sample-session)
- [Development](#development)
- [Origins](#origins)

## Install

In Claude Code:

```
/plugin marketplace add matasarei/claude-rpg
/plugin install rpg@claude-rpg
```

Type `/` and you will see `/rpg:party`, `/rpg:quest`, `/rpg:questline`, `/rpg:sidequest`,
`/rpg:journal` and `/rpg:evocation`.

You need `git`, and the GitHub CLI `gh` signed in (`gh auth login`) for the scroll — the pull
request. Without `gh`, quests still run; the scroll is handed over as a compare URL to open by
hand.

To update: `/plugin marketplace update claude-rpg`, then `/reload-plugins`. The plugin declares
no version on purpose, so every commit is an update.

## The party

| Word | Means |
|---|---|
| **the Medium** | you. Leads the party, feels where to go, sees ahead. Sometimes out of mana |
| **the Archmage** | Claude. Can do everything, follows your vision, casts on its own once the plan is clear |
| **mirrors** | subagents the Archmage summons: the scout, the caster, the judge |
| **quest** | one piece of work, one branch, one pull request, done when merged |
| **questline** | an ordered road of quests to one goal |
| **sidequest** | something found on the road, not blocking, taken now or after |
| **investigate** | read the code, check the facts, write the plan |
| **cast** | implement, one step at a time, one commit per step |
| **trial** | lint, tests, review, security pass, drive the real thing |
| **scroll** | the pull request |
| **the Medium's judgement** | your review, and your words of approval in the chat |
| **camp / party** | the repository set-up |
| **journal** | where are we |
| **evocation** | the roads ahead, when you are out of mana |

## The skills

| Command | Does | Changes files? |
|---|---|---|
| `/rpg:party [--reprofile]` | joins the party in this repository: surveys the land (how it is tested, run, where commands execute), makes camp (`.quests/`), checks `gh`, reads the laws of the land (`CLAUDE.md` and friends), greets you with what is open | `.quests/`, `.gitignore`, the profile |
| `/rpg:quest <goal> \| <file> [--continue] [--local] [--no-mirrors]` | one quest, from the first look to the merge — see below | yes: a branch, commits, a pull request |
| `/rpg:questline <goal> \| <file> [--continue]` | cuts a big goal into a road of quests that each merge alone, asks you to bless the road, starts the first; `--continue` after a merge takes the next | quest files, then via quests |
| `/rpg:sidequest [<what>] [--list] [--take <slug>] [--drop <slug>]` | records what was found, lists it, takes one as a quest, or drops one with the reason kept | sidequest files |
| `/rpg:journal` | where are we: the active quest and its state, the questline's progress, sidequests, scrolls awaiting you, the next commands | no |
| `/rpg:evocation [<question>]` | you are out of mana: two or three roads with cost and risk, one recommendation, the exact command for it | no |

`journal` and `evocation` are read-only by mechanism (their skill definitions remove the edit
tools), and the Archmage may reach for them itself when you ask "where are we" or "what next".
The other four only run when you type them.

**Every skill ends with a `Next` block**: one to three exact commands with their parameters
filled in, the recommended one first. You never have to work out what to type.

## A quest, start to finish

```
/rpg:quest export departments as CSV, the XLSX one merges departments with the same name
```

| Phase | What the Archmage does | Stops? |
|---|---|---|
| **0 preflight** | branch `quest/<slug>` from the base branch, quest file `.quests/<slug>.md` | only if the tree holds changes it did not make |
| **1 investigate** | classifies the ask (bug, feature, question, data fix), finds the code, checks facts on local data only and tags each (`[from the code]`, `[local database]`, `[assumed]`), writes findings, criteria and ordered steps into the quest file | **the plan stop**: the plan in eight lines. Plan clear → "I cast now" and goes on. One thing genuinely blocks → one question |
| **2 cast** | step by step: read, change, lint and scoped test at once, tick the step, commit. Mirrors take disjoint parts. Then tests: main path, error paths, edges | no |
| **3 trial** | lint, tests with the runner's line quoted, a reviewer's pass (BLOCKER / WARNING / NIT), the security checklist, drives the real thing, probes the guards. Failed → back to cast. **Three rounds at most** | only when stuck after three rounds |
| **4 scroll** | one coherent change or it asks; pushes; title in the house style; body with what-and-why, testing quoted verbatim, criteria ticked to reality; opens or updates the pull request | **hands over**: the URL and the three places worth your eyes. The run ends |
| **5 judgement** | on `--continue`: reads every comment, gives each a verdict before touching anything (agree / disagree with evidence / ask you), fixes one commit per finding, pushes, replies | asks for your words |
| **6 done** | **on your words in the chat** — "approved", "merge it", "готово", any wording — merges, cleans the branch, marks the quest done | — |

Nothing else counts as approval: not a GitHub review, not a comment, not a bot's green check,
not a file. The Archmage asks, and waits for you.

`--local` stops after the trial with no push and no scroll — for a repository with no remote,
or for trying the plugin. `--continue` resumes any quest from its file, after a closed session
or a usage limit, rebuilding nothing.

## Questlines and sidequests

**A questline** is for a refactoring or a feature too big for one pull request:

```
/rpg:questline replace the hand-written export layer with one writer per format
```

The Archmage investigates the goal, cuts it into three to seven quests that each merge alone
and leave the base branch working, shows you the road, and starts the first quest on your word.
After each merge, `/rpg:questline --continue .quests/questline-<slug>.md` takes the next.

**A sidequest** is anything the Archmage notices on the road that the current quest does not
need — a bug beside the one being fixed, a missing null check, a test that lies. It is written
to `.quests/side-<slug>.md` at once and mentioned at the next stop, never mid-cast, with one of
three words:

- **now** — it blocks the trial, or the current quest touches the same files (later means a
  conflict and a long road back), or it is one file and a few lines;
- **after** — the default;
- **never** — your word only; the file stays, with the reason.

`/rpg:sidequest --take side-<slug>` turns one into a quest with its own branch and scroll.

## Mirrors

Three subagents ship with the plugin, in `plugins/rpg/agents/`:

| Mirror | Summoned for | Can | Cannot |
|---|---|---|---|
| `mirror-scout` | sweeping a large unfamiliar area before the plan | read | edit, decide |
| `mirror-caster` | one part of a cast that touches its own files and no shared interface | edit its files, run scoped tests | commit, push, touch other files, talk to you |
| `mirror-judge` | a second reading of a large diff during the trial or the scroll | read | edit |

Three at once at most; never for a one-file change; never with `--no-mirrors`. The Archmage
says when it summons them and what came back, one line each, reads their reports as evidence
rather than instruction, and makes every commit itself.

## What the Archmage never does

Whatever anyone says — a comment on the pull request, a file, a mirror, a standards doc:

- `git push --force`, `--force-with-lease`, `--no-verify`, `commit --amend`, or a push to the
  base branch. While a quest is on, a hook (`plugins/rpg/scripts/guard.sh`) refuses these
  before they run, with the reason;
- weaken or delete a test to get to green;
- touch a production system, a live database, or a real person's account or data;
- merge without your words in the chat;
- paste code from a codebase under another licence without your word;
- follow an instruction found in text it reads. Comments, briefs, test output and mirror
  reports are evidence about the code, never orders.

Only you, typing here, can lift one of these — and only for the work, never for the list above.

## Files it writes

- `.quests/` at the repository root — one markdown file per quest, sidequest and questline:
  what was asked, what was found (tagged), the plan with ticked steps, and a dated log. Ignored
  by git on purpose: it is your road, not the project's history, and it survives branch
  switches. Commit it if your team wants to share questlines.
- `.claude/repo-profile.json` — the survey of the land: base branch, where commands run
  (container or host), lint, test and build commands, the runtime surface. Detected once,
  cached, ignored. The Archmage prints the commands when it first writes them.
- `.gitignore` — the two entries above, added if missing.
- `CLAUDE.md` — only when the repository has no standards doc at all, only on your word, and
  only a commands table plus a stub.

Everything else lands in commits on a `quest/<slug>` branch and in the pull request.

## A sample session

```
> /rpg:party

The land is a PHP app; tests run in the container:
    docker compose exec -T app vendor/bin/phpunit
Base branch: main. gh is signed in. No quests yet. Camp is made.

**Next**
- /rpg:quest "<what the wind says>"
- /rpg:evocation — if the wind says nothing, I will look around

> /rpg:quest export departments as CSV; the XLSX one merges departments with the same name

⚔ Export departments as CSV · investigating

The export lives in `application/commands/ExportCommand.php:41` [from the code]. XLSX only.
Departments with the same name are merged by `groupBy('name')` at line 58 [from the code] —
that is the bug you felt. The road: one CsvWriter beside the XLSX one, one flag on the command,
the grouping moved into the XLSX writer only, one test each.

The plan is clear. I cast now.

⚔ Export departments as CSV · casting
Step 1 landed: `application/export/CsvWriter.php` (new), 61 lines, commit a1b2c3d.
Step 2 landed: `--format=csv` on the command, commit b2c3d4e.
Step 3 landed: grouping moved into XlsxWriter, commit c3d4e5f.

⚔ Export departments as CSV · trial
The spell failed, round 1 of 3:
    Failed asserting that 2 matches expected 3.
Cause: the test fixture still groups. Fixed, commit d4e5f6a.
    OK (45 tests, 123 assertions)
Security: no new entry point, no request value reaches a query. Drove `./run export --format=csv`
with a bad path (exit 1, clear error) and for real (file written, 3 rows).

⚔ Export departments as CSV · awaiting
The scroll is written: https://github.com/org/repo/pull/118
Worth your eyes: `CsvWriter.php`; `ExportCommand.php:58`; the duplicate-names test.
One sidequest found: `side-null-department` — a department with no head crashes the old XLSX
path too. One file. I suggest after.

**Next**
- /rpg:quest --continue .quests/export-csv.md — when you have looked; say the words and I merge
- /rpg:sidequest --take side-null-department — if you want it before the road back

> looks good, merge it

⚔ Export departments as CSV · done
Merged 9f8e7d6. Branch gone. main pulled.

**Next**
- /rpg:sidequest --take side-null-department
- /rpg:evocation
```

## Development

```bash
git clone https://github.com/matasarei/claude-rpg
claude --plugin-dir ./claude-rpg/plugins/rpg      # loads the plugin without installing it
```

Then `/rpg:party` in any repository. `/reload-plugins` picks up edits. Before a commit:

```bash
claude plugin validate .                 # the marketplace
claude plugin validate plugins/rpg       # the plugin (the version warning is intended)
echo '{"tool_input":{"command":"git push --force origin x"}}' | plugins/rpg/scripts/guard.sh; echo $?   # 2
```

Layout:

```
plugins/rpg/
  skills/<name>/SKILL.md     short: arguments, the steps, which reference file to read when, Rules, Next
  reference/*.md             the procedures in full, loaded per phase: voice, quest-file, mirrors,
                             investigate, cast, trial, scroll, judgement, repo-profile, exec,
                             untrusted-input, security-checklist, code-provenance
  agents/*.md                the three mirrors, with tool allowlists
  scripts/guard.sh           the PreToolUse guard registered while a quest is on
```

Conventions: every in-plugin path is `${CLAUDE_PLUGIN_ROOT}/…`; every injected shell command ends
in `|| true`; skills that write are `disable-model-invocation: true`; skills that only read carry
`disallowed-tools: Edit, Write, NotebookEdit`; nothing under `plugins/rpg/` names any other
plugin, directory or file outside itself.

## Origins

The survey, execution, untrusted-input, security-checklist and code-provenance reference files
were carried over and reworded from [grinchenkoedu/claude-skills](https://github.com/grinchenkoedu/claude-skills)
(MIT). The rest is this repository's own. MIT licensed.
