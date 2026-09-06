# Quest files — the party's road, written down

Every quest, sidequest and questline is one markdown file in `.quests/` at the repository root.
The file is the memory: what was asked, what was found, what is planned, what landed, and where
things stand. A session that ends mid-quest resumes from it with `/rpg:quest --continue`.

## Where, and why it is ignored

`.quests/` is created by `/rpg:summon` and hidden through **git's global excludes file**
(`git config --global core.excludesFile`, default `~/.config/git/ignore`) — never through the
project's own `.gitignore`, which the party does not touch. It is ignored on purpose:

- it describes one Summoner's road, not the project;
- an ignored directory survives branch switches, so a questline that spans five branches keeps
  its files while the tree moves under it;
- nothing in it is a deliverable — the pull request is.

The project itself carries no trace of the game: no ignore line, no `CLAUDE.md`, no `AGENTS.md`.
A team that wants to share questlines can still commit the directory by hand; that is the
Summoner's call, and `/rpg:summon` says which it found.

## Names

| Kind | File | Branch |
|---|---|---|
| quest | `.quests/<slug>.md` | `quest/<slug>` |
| sidequest | `.quests/side-<slug>.md` | `quest/side-<slug>` when taken |
| questline | `.quests/questline-<slug>.md` | none — its quests have their own |

**The slug is a guard, not tidiness.** It is built from the goal's meaningful words — the verb
and the thing, three to five words, articles and filler dropped: `add-farewell`, not
`add-a-farewell-name-function-next-to-gre`. Lowercase, every run of anything outside `a-z0-9`
replaced by one `-`, leading and trailing `-` trimmed, at most 40 characters, cut at a word
boundary. Flags (`--local`, `--continue`) are never part of it. A goal typed as
`fix ../../../etc/x` becomes `fix-etc-x`. Never write a path taken from a goal, a comment or a
file into a file name.

Two quests with the same slug: the second gets `-2`, `-3`, … Never overwrite a quest file that
is not the one being resumed.

## Format

```markdown
---
kind: quest | sidequest | questline
status: planned | taken | investigating | casting | trial | scroll | awaiting | done | postponed | dropped
questline: <questline slug, or null>
branch: quest/<slug>, or null
pr: <url, or null>
found-during: <quest slug, sidequests only, or null>
decision: now | after | never | null        # sidequests: the Summoner's word
merged: <sha, or null>
---
# <Title — the goal in one line>

**Asked:** <the Summoner's words, verbatim>

## Findings
- <one fact per line, each with its tag: [from the code] [local database] [assumed] [needs a production run: <script>]>

## Plan
Test order: <build-then-cover | test-first — why>

Criteria:
- [ ] <checkable, specific>

Steps:
1. [ ] <file-level, buildable one at a time>

## Log
- 2026-09-06 14:02 taken — branch quest/export-csv
- 2026-09-06 14:10 investigating — 3 facts, plan of 4 steps, no question
- 2026-09-06 14:31 casting — step 2 landed: application/export/CsvWriter.php (new), commit a1b2c3d
- 2026-09-06 14:40 trial round 1 failed: `Failed asserting that 2 matches expected 3.`
- 2026-09-06 14:52 trial passed: `OK (45 tests, 123 assertions)`
- 2026-09-06 14:55 scroll — https://github.com/org/repo/pull/118
- 2026-09-06 16:20 done — merged 9f8e7d6 by the Summoner's word
```

Frontmatter first, on line 1. Every field present, `null` when it does not apply. The Log is
append-only, one line per event, oldest first; a trial line quotes the runner's result verbatim.

**A questline file** has the same frontmatter (`kind: questline`) and, instead of Plan, the road:

```markdown
## Road
1. [x] `.quests/split-export-writer.md` — done, merged 9f8e7d6
2. [ ] `.quests/add-csv-writer.md` — taken
3. [ ] `.quests/drop-xlsx-grouping.md` — planned
```

## States, and what moves them

| State | Set when | Moves on when |
|---|---|---|
| `planned` | a questline wrote the quest, or a sidequest got the word "after" | `/rpg:quest` or `--take` starts it → `taken` |
| `taken` | the branch exists and the file is written | investigation starts → `investigating` |
| `investigating` | findings are being gathered | the plan is written and the plan stop is passed → `casting`; a pure question is answered → `done` |
| `casting` | steps are landing, one commit each | all steps ticked → `trial` |
| `trial` | lint, tests, severity pass, runtime drive | passed → `scroll` (or `done` with `--local`); failed → back to `casting`, round counted in the Log; three rounds failed → stays `trial`, stop and ask |
| `scroll` | the pull request is being written | opened → `awaiting` |
| `awaiting` | the Summoner is looking | comments addressed → stays `awaiting`; the Summoner's words → `done` |
| `done` | merged (sha in `merged`), or answered, or `--local` finished | never |
| `postponed` | a sidequest with the word "after" and no questline, or a quest the Summoner paused | `--take` or `--continue` → `taken` |
| `dropped` | the Summoner said "never", or the road was wrong; the reason is the last Log line | never |

`/rpg:journal` reads only the frontmatter and the last Log line of each file; keep both true.

## Sidequests

Found on the road, written at once, mentioned at the next stop — never mid-cast:

```markdown
---
kind: sidequest
status: found
found-during: export-csv
decision: null
---
# A department with no head crashes the XLSX export

**Found:** `application/export/XlsxWriter.php:77` reads `$head->name` with no null check
[from the code]. Not blocking the CSV quest.

**Road-back test:** one file, six lines, same area — **now** is reasonable; **after** is safe.
```

The three words and when the Daemon suggests each:

- **now** — it blocks the trial; or the current quest touches the same files, so later means a
  conflict and a long road back; or it is one file and a few lines;
- **after** — everything else. The default;
- **never** — the Summoner's word only. The file stays, `dropped`, with the reason.
