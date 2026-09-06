# Trial — does the spell hold?

The third phase. Tests passing and a change working are different claims; the trial makes both,
separately, and says which one it can back. A failed trial sends the quest back to cast. Three
rounds at most; then the Daemon stops and asks.

Everything runs the way `exec.md` says: through `exec.prefix`, wrapped in `timeoutTool`. A hang
is a failure. On `exec.kind: host`, every result line says so.

## 1. Lint the changed files

If the profile has `lint`, run it over every changed file. A lint failure is a **BLOCKER**,
quoted verbatim. Mind the version: a newer linter than the project targets proves only that the
newer version can read it — say so when the profile records the mismatch. No `lint` → say the
trial is unlinted.

## 2. Run the tests

The profile's `testScoped` for what changed first, then `test` in full if it is quick. Wrapped in
`timeoutTool`; when there is none, say the hang cannot be bounded — never drop the bound silently.

- **Quote the runner's result line.** `OK (43 tests, 118 assertions)` is evidence; "tests pass"
  is not.
- **A timeout is a failure.** Capture what it was doing.
- **Fails on the base branch too** → `PRE-EXISTING`; prove it by running the same command
  there, and do not blame this quest for it.
- **No tests in the repository** → say `MISSING`, plainly. An absence of tests is never
  reported as tests passing.

## 3. Read the diff as a reviewer would

Rank what changed by risk and read down the list until five files have been read in full;
everything else is judged from the diff, and the trial says which:

1. anything writing to the database, handling money, grades or records of record, changing
   schema, touching authentication or permissions, or building a file users download — read
   fully, plus the unchanged code around it;
2. modifications to code that already existed;
3. new loops, searches, aggregations, anything parsing external input;
4. new self-contained files with straightforward logic — the diff is enough;
5. tests — enough to judge what they prove;
6. markdown, JSON, lock files, translations — diff only.

Skip `vendor/`, `node_modules/`, build output, anything generated.

Apply the standards doc's own rules — the repository's conventions win, inconsistent ones
included. Every finding gets one of three severities:

- **BLOCKER** — do not open the scroll. A secret committed; a change that silently loses or
  corrupts data; a mass write with no bounded scope or no dry-run; a data fix that duplicates on
  a second run; a removed or renamed function still called elsewhere (grep for it); user input
  reaching SQL, a shell, the filesystem, HTML or a spreadsheet cell unescaped; an entry point
  with no login or permission check; a record reachable by changing an id; a state change with
  no CSRF token; a block from a codebase under a different licence with no word on record; a
  Moodle `classes/`, `db/`, cache or task change with no `version.php` bump.
- **WARNING** — fix before the scroll. New logic with no test; the same block copied a third
  time; an error path nobody handles; a value that can be null and is not checked; a loop that
  can run forever on unexpected data; a comment explaining *what* instead of *why*; work that
  may outlast a page load run inline in a web request when the project has a background
  mechanism.
- **NIT** — noted in the scroll's description, not fixed here. Naming, ordering, a clearer way to
  say the same thing.

Every BLOCKER and WARNING is backed by the line that proves it. Cannot quote it → drop it one
severity and mark `[unverified]`.

## 4. The security pass

Part of every trial, not a mode. Read the added lines against `security-checklist.md`:

1. run its mechanical sweep over the diff — hits are leads, open the file at each; misses are
   not clearance;
2. for every changed entry point — page, route, controller action, AJAX handler, external
   function, CLI script — answer the checklist's four questions by reading: where is the login
   check, where is the permission check and against which context, where is the token check on
   a state change, where does each request value end up. "Nowhere" is a finding;
3. for every file read in full in step 3, walk the checklist sections that apply.

A security finding names `path:line`, the input that demonstrates it (`'`, `../`, `<b>`, another
user's id, the request with its token removed), and the fix. Never "consider validation".

## 5. Do the tests mean anything?

For every test in the diff, and every production change that should have one:

- no assertion, or a trivial one → WARNING;
- a throw, guard or error return added, and nothing asserts the failure → WARNING;
- new inputs with no test for null, empty, zero, one, duplicate → WARNING on grades, money or
  records; NIT otherwise;
- real clocks, unseeded randomness, `sleep()` → WARNING;
- mutates globals, environment or shared fixtures without restoring → WARNING;
- the code under test mocked away (raw SQL tested only with the database mocked) → WARNING.

## 6. Drive the real thing

Tests prove the code for a well-behaved caller. This step runs it, using the profile's
`runtime`:

- **`cli`** — run it twice: once with bad input (a clear error *and* a non-zero exit code —
  check the code directly, a pipe hides it), once for real. Check the effect: the row written,
  the file produced, the output correct.
- **`http`** — request the route. Status, then effect. A browser if there is one, else `curl`,
  and say the check was request-level.
- **`library`** — call the public API with ordinary and edge inputs.
- **`hosted`** — a Moodle plugin or similar cannot run without its host. Say behaviour was not
  verified; do what can be done: lint every changed file, confirm the `version.php` bump,
  confirm every new class sits where its namespace says, read every entry point for its
  `require_login()`, `require_capability()`, `require_sesskey()`.

Then the adversarial checks the change makes relevant: run twice, empty result, already
processed record, unexpected null. Anything writing in bulk: dry-run changes nothing, second
run is a no-op.

**The guards**, one minimal local probe each, only on the project's own test accounts, only
where the change touched them: no session → refused; the account without the permission →
refused and no effect; another account's id → refused; token removed, then as `GET` → refused
both times; `'`, `"`, `<b>x</b>` → stored literally, shown as `&lt;b&gt;`; `../` → refused;
`limit=100000000` → capped; any error body → generic, no trace. Each row: passed with the code
that proved it, failed as a finding, or skipped with a category (`SETUP`, `MISSING`, `HOSTED`,
`EXTERNAL`, `DATA`, `PRE-EXISTING`) and one line on the way out. Never against a host the
Summoner does not control, never with a real person's account.

Restore what was changed, in reverse order, even when the trial failed halfway.

## Claims need fresh evidence

A claim about the work is made only with the output that proves it, run in **this** turn. Not
a run from earlier, not a partial run, not a fork's word, not "it should".

| The claim | What proves it | Not enough |
|---|---|---|
| the tests pass | the runner's result line from this turn, 0 failures | an earlier run; "should pass now" |
| the lint is clean | the linter's output, 0 errors | a partial run over one file |
| the build works | the build command, exit 0 | the lint passing; the log "looks fine" |
| the bug is fixed | the original symptom re-run, now correct | the code changed; the test passes once |
| a fork is done | its diff and its scoped test line, checked by the Daemon | its report saying "done" |
| a criterion is met | the line or the effect that shows it, one per criterion | the tests passing |
| the guard holds | the refused request with its status or exit code | the guard being present in the code |

**Words that betray a guess**, and are therefore not said about the work: "should", "probably",
"seems to", "looks correct", "I am confident", "all green", "done" or "perfect" before the
proof, and any wording that implies success without a line under it. When the proof is not
there, the Daemon says what it actually has — "not run", "not checked", "round 2 failed on this
line" — and the trial stays open. A tired round at the cap is reported as failed, not rounded up.

## 7. Verdict, and the loop

Write to the quest file's Log one line: `trial round <n> passed: <runner line>` or
`trial round <n> failed: <the first failing line or the blocker>`.

- **Passed, no BLOCKER, no WARNING** → `status: scroll` (or `done` with `--local`, and the chat
  says the trial passed and nothing was pushed). Nits go into the scroll's Notes.
- **Failed, or a BLOCKER or WARNING** → `status: casting`, back to `cast.md` with the findings
  as steps. Fix the smallest thing that resolves each, one commit each. This is round `n+1`.
- **Round 3 failed** → stop. Under the banner, say what still fails, quote it, say what the
  Daemon thinks it is and whether that is a **proven cause** or a **hypothesis**. The Next block
  offers `/rpg:evocation "<what fails>"` and `/rpg:quest --continue .quests/<slug>.md`. A fourth
  attempt on a tired premise rarely lands, and whether to keep going is the Summoner's call.

In the chat, when it passed, one block: the runner's line, what was driven and what it did, the
guard rows that were checked, what was judged from the diff alone, what was skipped and why. A
trial with no security line is an unfinished trial. Never report a check that did not run.
