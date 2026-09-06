---
name: journal
description: Where are we — the active quest and its state, the questline's progress, sidequests found and postponed, scrolls awaiting the Medium, and the exact next commands. Read-only.
when_to_use: When the Medium asks where things stand, what is open, what the status is, what was done, or which quest is next.
argument-hint: ""
disallowed-tools: Edit, Write, NotebookEdit
allowed-tools: Read(/${CLAUDE_PLUGIN_ROOT}/**) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/voice.sh) Bash(git status *) Bash(git branch *) Bash(git log *) Bash(gh pr list *) Bash(gh pr view *) Bash(ls *) Bash(cat *)
---

# /rpg:journal — where are we

Speak as the voice below says, from here on.

## The voice

!`"${CLAUDE_PLUGIN_ROOT}/scripts/voice.sh" || true`

## The land, as it stands

- Branch: !`git branch --show-current 2>/dev/null || true`
- Tree: !`git status --short 2>/dev/null | head -10 || true`
- Quests: !`ls -1 .quests 2>/dev/null || echo "no .quests/ — run /rpg:party first"`
- Scrolls awaiting: !`gh pr list --author @me --state open --json number,title,url,headRefName 2>/dev/null || echo "gh not available"`

## Steps

1. No `.quests/` → "we have not camped here", Next is `/rpg:party`, stop.
2. Read only the frontmatter and the last Log line of every file in `.quests/`
   (`${CLAUDE_PLUGIN_ROOT}/reference/quest-file.md`). Do not read the bodies; the journal is a
   glance, not a study.
3. Report, in this order, each part only when it has something:
   - **The active quest** — title, state, branch, last Log line, the criteria ticked so far
     (`n/m`). Banner: `⚔ <title> · <state>`. Two quests not done and not postponed → both, and say
     which branch is checked out.
   - **The questline** — title, `n/m` quests done, the next on the Road.
   - **Scrolls awaiting** — from the injected list, each with its quest slug when one matches.
   - **Sidequests** — `found` and `postponed`, one line each with the suggested word.
   - **Paused and dropped** — counts only.
   - **Nothing open** → one line: "the road is clear".
4. Ten lines at most before Next. Numbers only where they change what the Medium does next.

## Next

Whatever the state says, the recommended first:

- an active quest → `/rpg:quest --continue .quests/<slug>.md`
- a scroll awaiting → `/rpg:quest --continue .quests/<slug>.md` — "look, then say the words"
- a questline with the next quest `planned` → `/rpg:questline --continue .quests/questline-<slug>.md`
- a sidequest marked **now** → `/rpg:sidequest --take side-<slug>`
- nothing open → `/rpg:evocation`

## Rules

- Read-only, by mechanism and by rule: no edits, no commits, no pushes, no quest file changes.
- What the files and `gh` say is reported as they say it; nothing is inferred beyond the last
  Log line.
- English or Ukrainian, matching the Medium.
