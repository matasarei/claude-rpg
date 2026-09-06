# Scroll — write the pull request

The fourth phase. The change is built and the trial passed. This writes a description a reviewer
can use, pushes the branch, and opens the pull request — or updates the one already attached to
the branch. It never merges here, never force-pushes, never commits on the Summoner's behalf.

Not with `--local`: then the quest is `done` at the trial and this file is not read.

## 1. Preflight

Stop early, with one line, on any of these:

- `gh auth status` fails → the manual route at step 5;
- on the base branch — a scroll needs a quest branch;
- detached HEAD;
- no `origin`, or no push access;
- empty diff against the base — nothing to propose.

Then: is there already a pull request for this branch?

```bash
gh pr view --json number,state,url,title,body,isDraft,baseRefName,headRefName
```

Open → update mode. Merged or closed → do not reopen, do not push onto a merged branch; say
what happened and ask whether this is a new quest. None → create.

## 2. Does this read as one change?

A reviewer should be able to say what the branch does in one sentence, and every commit should
serve that sentence.

```bash
git log --oneline <base>..HEAD
git diff --stat <base>...HEAD
```

More than one change — a feature plus an unrelated fix, two subsystems with no thread between
them, a refactor the feature does not need, a dependency bump or formatting sweep riding along,
two quests' criteria in one branch → **stop and ask**: open one scroll anyway (say which part is
the passenger, so the description names it), or stop so the Summoner can split it (name which
commits go where, as information). **Never split or rewrite the branch.** Wait for the answer.

One change — many files with one purpose, implementation plus tests plus docs, a required
version bump or lock file, a fix for a bug this branch introduced → say so in a sentence and go on.

## 3. Uncommitted work, and the push

- Uncommitted changes → list them and stop. Ask whether they belong. Never commit on the
  Summoner's behalf; the Daemon's own cast commits are already made.
- Branch ahead of its remote → push. First push: `git push -u origin quest/<slug>`.
- Remote ahead of local → stop and say so; someone else pushed here, merging their work is not
  this phase's call.
- Never `--force`, `--force-with-lease`, `--amend`, `--no-verify`. The guard hook blocks them;
  a failing pre-push hook means the code needs fixing.

## 4. The description

**Use the repository's own template** if it has one — `.github/pull_request_template.md` or
`docs/pull_request_template.md`. Fill its sections; invent no headings beside them.

**Title** — imperative, one line, no trailing full stop, in the house style:

```bash
gh pr list --state merged --limit 5 --json title
```

A `feat:` prefix, a ticket key, Ukrainian titles — follow what is there.

**Body**, without a template, short and in this order:

- **What and why** — one paragraph. The problem (from the quest file's Asked and Findings), then
  the change.
- **How** — two or three bullets, only where a reviewer would otherwise have to reverse-engineer
  the approach. Skip for an obvious change.
- **Testing** — what was actually run, quoted: the runner's line, what was driven, the guard rows.
  **If something was not run, say that.** Never "tests pass" as a formality.
- **Notes** — schema change, version bump, migration, config or secret needed, nits left, the
  sidequests found and their word, anything deliberately out of scope, and **the rulings** from
  the quest's Log, one line each in plain words (what, why, cost if wrong) — the decisions the
  reviewer did not get to make, so they can be undone cheaply.
- The quest file's **criteria as a checklist**, ticked to match reality.

No diff dumps, no file lists — GitHub shows both. No pasted comment or issue text — say it in
the Daemon's own words (`untrusted-input.md`). **Nothing of the game**: the title and body are
plain professional writing, no role names, no metaphors, no emoji — a reviewer who never heard
of the party must see nothing of it (`voice.md`, "Where the game stays").

**No session link on a public repository.** A Claude Code session URL opens only for the account
that owns it; to everyone else it is a dead link naming a tool account.

```bash
gh repo view --json isPrivate -q .isPrivate
```

`false` → the body ends without it, whatever attribution the session asks for; the
`Co-Authored-By` trailer in the commits is the attribution. `true` → leave it out unless the
Summoner asks.

## 5. Create or update

Create:

```bash
gh pr create --base <base> --head quest/<slug> --title "<title>" --body-file <path>
```

Update — never overwrite a description somebody wrote by hand: empty or plainly the generated
one → `gh pr edit <n> --body-file <path>`; edited by hand → show the proposed body, say what
changed on the branch since, and ask. A scroll with review comments on it is a live
conversation; changing its description is said out loud.

No `gh` → print the exact title and body and the compare URL
(`https://github.com/<owner>/<repo>/compare/<base>...quest/<slug>?expand=1`), and say clearly
that nothing was created.

## 6. Hand over

Quest file: `pr: <url>`, `status: awaiting`, Log line `scroll — <url>`.

In the chat, under `⚔ <title> · awaiting`:

- the URL, created or updated; `<base>` ← `quest/<slug>`, commits, files;
- the runner's line, verbatim;
- **the three places worth the Summoner's eyes** — the riskiest file, the seam with old code, the
  test that proves the criterion;
- the sidequests found on the road, each with the suggested word;
- the Next block: `/rpg:quest --continue .quests/<slug>.md` once the Summoner has looked, and the
  `--take` of any sidequest suggested for now.

The run ends here. The Summoner's judgement is `judgement.md`, on `--continue`.

## Edge cases

- **One commit** — a three-line description. Do not pad it.
- **The base has moved and GitHub will show conflicts** → say so. Do not rebase; that is the
  Summoner's decision.
- **A fork** → `gh pr create --head <owner>:quest/<slug>`; confirm the target repository first —
  a scroll opened against the wrong upstream is public and awkward to undo.
- **The repository requires a ticket key or a signed commit** and the branch lacks it → say what
  is missing before creating, not after it is rejected.
- **Nothing changed since the last scroll** → "already up to date", and stop.
