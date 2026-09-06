# Cast — build it, one step at a time

The second phase. It follows the quest file's Plan in order, ticks each step as it lands, and
commits per step. It does not think the problem through again; that was investigate's job. When
a step turns out to be wrong, it stops and says so.

## Before the first step

- The branch is `quest/<slug>` (preflight made it). Never cast on the base branch.
- `git status --short` shows only the Archmage's own work. Someone else's uncommitted changes
  → stop and ask; do not build on half-finished work that is not yours.
- Re-read the Plan's **Test order** line and follow it.

## Each step, in order

1. **Read** the files the step touches, and enough around them not to break the seam between
   new code and what it calls.
2. **Make the change.** Match the file being edited — its naming, its structure, its comment
   style. Consistency with the neighbours beats consistency with a style guide. Where the
   standards doc and the neighbours are silent: readable, then changeable, then extendable, then
   efficient. Write it yourself, install it as a dependency, or take it from code under the
   project's own licence with its header kept; anything under another licence needs the
   Medium's word first (`code-provenance.md`).
3. **Check it at once** — lint the changed file through `exec.prefix` if the profile has a
   `lint`; run the scoped test if one covers it. A mistake found now costs a minute; found four
   steps later it costs the afternoon.
4. **Tick the step** in the quest file, with one line on what actually landed:
   ```markdown
   2. [x] Add the CSV writer — `application/export/CsvWriter.php` (new), 61 lines
   ```
5. **Commit** — one commit per step is the default. Message in English, imperative, one line on
   what and, when it is not obvious, one on why.
6. **One line in the chat**: what landed, what is next. Never quiet for six steps.

**Test-first order:** each step starts with its test. Write it, run it, it must fail — and fail
for the right reason. A test that passes against code not yet written is testing nothing; find
out why before going on. Then the smallest change that makes it pass. The step is not done until
its test is green.

## Mirrors in the cast

When two or more remaining steps touch disjoint files and change no shared interface, summon one
`mirror-caster` per part, three at most, each with its file list and a do-not-touch list
(`mirrors.md`). The Archmage keeps the steps that bind the parts together — the command, the
wiring, the shared test — and the commits: a mirror's diff is read, its scoped test is re-run by
the Archmage, then committed by the Archmage. Not with `--no-mirrors`; not for a change under
about fifty lines.

## Stay inside the quest

Something unrelated and broken, noticed on the way → a sidequest file, `status: found`, mentioned
at the next stop with **now / after / never** (`quest-file.md`). Never fixed silently: scope
creep is how a reviewable change becomes an unreviewable one.

Something the plan needs but did not name — a helper, a migration, a version bump → part of the
current step; say so in its tick line.

## When a step is wrong

The code says the step cannot be done as written — the class does not exist, the table is
shaped differently, the neighbour already does it. **Stop.** Say what was found, propose the
correction to the Plan, and wait. Do not quietly build something different from what was
planned. If the correction is small and obvious, propose and proceed in the same message; if it
changes the road, it is a plan stop again, and the Next block says
`/rpg:quest --continue .quests/<slug>.md`.

A step already done — someone got there first → tick it with "already there", note it, move on.

## After the last step

Cover what was built, before the trial:

- the main path, asserted properly — not just that it runs;
- **the error paths**, the ones that get skipped: bad input, missing record, failed write, empty
  result;
- **the edges**: null, empty, zero, one, duplicates.

Copy the shape of a neighbouring test file. No tests and no test command in the repository → say
so, write the first one anyway if the profile shows a usable framework, and never invent a
harness that does not exist.

Then the things that break on a live site but not here:

- **Moodle plugins** — bump `$plugin->version` in `version.php` when anything under `classes/`
  was added or moved, or `db/` schema, caches or tasks changed.
- **Front-end sources** — run the profile's `build`.
- **Dependencies** — the lock file is committed beside the manifest, in the same commit.

Set `status: trial` in the quest file, one Log line, and go to `trial.md`.

## Rules that hold here

- Never `--force`, `--no-verify`, `--amend`. A failing hook means the code needs fixing.
- Never weaken or delete an existing test to get to green. If a test is wrong, say so and why.
- Never touch anything on the Plan's **Do not touch** list without a plan stop.
- Data-safety rules are not optional: anything writing in bulk has dry-run by default, is safe
  to run twice, has bounded scope and an expected row count that aborts when reality disagrees
  (`repo-profile.md`).
