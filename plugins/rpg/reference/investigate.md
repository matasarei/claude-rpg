# Investigate — read the land before casting

The first phase of a quest. Its output is the quest file's **Findings** and **Plan**, and one
short hand-over in the chat. It writes no production code. The only file it may create besides
the quest file is one throwaway read-only script, untracked, used to answer a question about the
data.

## 1. Understand what is really asked

The words people use do not always match what they need. Classify first:

| It is really a | Signals | What the quest owes |
|---|---|---|
| **bug** | "wrong", "broken", "should not", a description of something that happened | the **cause**, proven, then the fix |
| **feature** | "add", "support", "we need to be able to" | a **design**: where it hooks in, what it touches, in what order |
| **question** | "how many", "why does", "is it possible", "can we" | the **answer**, with evidence. Usually no code changes — the quest ends here, `done`, no branch |
| **data fix** | "these records are wrong", "recalculate", "stuck" | how many rows, why, and a **safe** strategy: dry-run by default, safe to run twice, bounded scope with an expected row count |
| **questline** | a goal that cannot end in one mergeable pull request | say so, stop, and offer `/rpg:questline "<goal>"` |

Too vague to classify → one question, then wait. That is the only question this phase may
ask before the plan stop.

## 2. Find the code

Take two to four distinctive terms from the goal and search for them. Read what they hit: the
entry points, the classes involved, the tests that already cover the area. Read the standards
doc named in the profile for the conventions the plan must follow.

**Check whether the work is already done.** An existing command, script or function that solves
this is the best possible finding: point at it, write it in Findings, and the quest is `done`.

Five files read in full at most. Everything else is judged from the search hits. When the area
is large and unfamiliar and five is not enough, summon a `mirror-scout` (`mirrors.md`) — unless
`--no-mirrors` was passed, in which case say the read was capped.

## 3. Check the facts

A cause not verified is a guess. Say which one is being stated.

Where a claim rests on data — how many rows, what states exist, whether this actually happens,
what the schema really looks like — check it, with what the profile says this project has: a
database in the local container, a fixture set, a small read-only script run through
`exec.prefix` (`exec.md`).

- **Local data only.** Never point anything at a live system. A question only production can
  answer becomes a read-only script, left untracked, with the exact command written in Findings
  for the Medium to run.
- **Anything written here reads and never writes.**
- **Tag every fact:** `[from the code]`, `[local database]`, `[assumed]`, `[needs a production
  run: <script>]`. An untagged number is treated as true by everyone downstream.

No database at all → say so and lean on the code.

## 4. Decide the road

For most quests, reason it through: the code is read, the facts are checked, pick the approach
that fits this codebase and say why in one line.

For a genuinely open design question — several defensible approaches, or a change that is hard
to reverse — two or three options in a short table with their trade-offs, a recommendation, and
what would change it. That table goes to the Medium at the plan stop; it is the one case where
the stop is a question rather than a notice.

**Breaking a tie.** Where the standards doc states design priorities, apply them. Where it is
silent: easier to read, then easier to change, then easier to extend, then cheaper to run — and
say which decided it.

**Where does long work run?** With `runtime.kind` `http` or `hosted`, a person is waiting on a
page. For every step that may take longer than a page should — an export, a bulk write, a call
to an outside service, mail — ask whether that person has to wait. If not, the design uses the
background mechanism the code already has: grep for `queue`, `task`, `job`, `cron`, `worker`,
name what was found, and say how the user learns the work is done. None found → an open question
in the plan, not a reason to invent one. For `cli` or `library` the question does not arise.

## 5. Write the plan into the quest file

```markdown
## Findings
- <fact> [tag]

## Plan
Test order: build-then-cover | test-first — <why: the Medium asked / the standards doc requires it / the neighbours do it>

Criteria:
- [ ] <checkable, specific — what the trial proves and what the scroll ticks>
- [ ] <for background work: the request returns without waiting, and how the result is reached>

Steps:
1. [ ] <ordered, file-level, real paths and names, buildable one at a time>

Do not touch:
- <files, tables or behaviour that must stay as they are, and why>

Open questions:
1. <numbered, each answerable — or "none">
```

Real file paths, real function and class names, an order, and an explicit list of what not to
touch. A plan the cast phase cannot follow without thinking the problem through again is not
finished.

**Test-first** when the Medium asked for it, the standards doc requires it, or the neighbours
visibly do it (every feature lands with its test in the same commit). Otherwise build, then cover.

## 6. The plan stop — one at most

In the chat, under the banner `⚔ <title> · investigating`: the plan in eight lines or fewer —
the finding, the road, the steps by name, the biggest risk.

- **Plan clear, no open question** → say "The plan is clear. I cast now." and go on. Do not
  wait for a reply.
- **One thing genuinely blocks** — a design fork the Medium must choose, a fact only production
  can give, a "do not touch" that the goal seems to need → one question, with the options, and
  wait. The Log gets `plan stop — asked: <question>`; the Next block offers
  `/rpg:quest --continue .quests/<slug>.md`.
- The Medium answers "you decide" or nothing useful → out of mana: pick, say why in one line,
  go (`voice.md`).

A question that could be answered by reading more code is not a question. Read the code.

## Sidequests found here

Something broken or missing that the goal does not need → `.quests/side-<slug>.md`, `status:
found`, mentioned at the plan stop with **now / after / never** and the road-back test
(`quest-file.md`). Not fixed here.
