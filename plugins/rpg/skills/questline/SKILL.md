---
name: questline
description: A road of quests to one goal — a refactoring, a big feature, anything too large for one pull request. The Daemon scries the goal, splits it into ordered quests that each merge alone and leave the base branch working, writes the questline and its quest files, asks the Summoner to bless the road, then starts the first quest. --continue after a merge takes the next.
argument-hint: "<goal> | <.quests/questline-*.md> [--continue]"
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_PLUGIN_ROOT}/**) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/voice.sh) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/quests.sh) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/slug.sh *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/survey.sh) Bash(git status *) Bash(git branch *) Bash(git log *) Bash(git diff *) Bash(gh pr list *) Bash(ls *) Bash(cat *)
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/guard.sh"
---

# /rpg:questline — many quests, one goal

Speak as the voice below says, from here on. Banner:
`⚔ <questline title> · road`, then `Next`.

## The voice

!`"${CLAUDE_PLUGIN_ROOT}/scripts/voice.sh" || true`

The Summoner says: $ARGUMENTS

## The land, as it stands

- Branch: !`git branch --show-current 2>/dev/null || true`
- Tree: !`git status --short 2>/dev/null | head -20 || true`
- Road: !`"${CLAUDE_PLUGIN_ROOT}/scripts/quests.sh" || true`
- Lore: !`cat .quests/lore.md 2>/dev/null || echo "no lore yet"`

## Arguments

Strip quotes; an existing file → the questline to resume; a path that does not exist → stop
with "no such questline file"; otherwise a goal. Nothing → ask what the goal is, one line, stop.
`--continue` → the questline file given, or the only one with an unticked quest on its Road.

## Steps

1. **Preflight** as `/rpg:quest` does: summoned here (`.quests/` exists), profile present, tree clean of foreign changes.
   New goal → slug from `${CLAUDE_PLUGIN_ROOT}/scripts/slug.sh "<goal>"`, file
   `.quests/questline-<slug>.md`, `kind: questline`, `status: taken`.
2. **Scry the goal**, not the first step — read
   `${CLAUDE_PLUGIN_ROOT}/reference/scrying.md` and apply it at the goal's level: what
   exists, what must change, in what order, what must not be touched, the facts tagged. The
   `fork-scout` is welcome here (`${CLAUDE_PLUGIN_ROOT}/reference/forks.md`).
   **The clarify round — questlines only.** A road cut from a vague goal costs several quests,
   so before cutting, when the goal leaves a real fork open — which users, which of two
   systems, what "done" means, what must not change — the Daemon may ask **up to three
   questions in one message**, each with the options it sees. One message, then the answers
   are Findings tagged `[from the Summoner]`. Never a second round: what is still open after
   it is a ruling in the Log (`${CLAUDE_PLUGIN_ROOT}/reference/quest-file.md`, "Rulings").
   "You decide" or nothing useful → out of mana, the same. A goal that is already clear gets
   no round at all; a quest never gets one — its rule stays one question at most.
3. **Cut the road.** Split the goal into ordered quests. Each quest: one sentence, one pull
   request, mergeable alone, **the base branch still works after its merge** — a flag, a stub
   or a compatibility shim is part of the quest when the cut needs one. Three to seven quests is
   the usual road; more → say so and cut coarser. Write the Road into the questline file and one
   `.quests/<slug>.md` per quest with `status: planned`, `questline: <slug>`, its Asked line and
   the Findings that belong to it. Later quests get less detail — their scrying phase will
   fill it when their turn comes.
4. **The map stop — one.** Show the road: the quests, one line each, in order, with the reason
   for the order and the biggest risk. Ask the Summoner to bless it, change it, or cut it
   differently. "ok" or nothing useful → out of mana: keep the road, say so, go on.
5. **Start the first quest** by invoking `rpg:quest` through the Skill tool with
   `--continue .quests/<first>.md`. Do not describe the loop here; it lives there.
6. **`--continue` after a merge.** Read the Road; the first unticked quest whose predecessor is
   `done` is next. Its predecessor not merged → say so, Next is that quest's `--continue`.
7. **Converge, when every quest on the Road is ticked.** Before the questline is called done,
   check the delivered state against the goal, on the base branch after the last merge: the
   questline's Findings and its criteria, one row each — met (the line or the effect that shows
   it, under the gate in `${CLAUDE_PLUGIN_ROOT}/reference/trial.md`), not met, or not checkable
   here. Every gap becomes a new quest file (`status: planned`, `questline: <slug>`) appended to
   the Road, and the questline stays open. No gap → `status: done`, the road's lore line, and
   three lines in the chat. A converge that finds gaps twice in a row is a sign the goal was
   cut wrong: say so, and offer to re-cut instead of appending a third time.

## Next

- after the map stop → `/rpg:quest --continue .quests/<first>.md` (already started by step 5);
  `/rpg:journal`
- after a merge → `/rpg:questline --continue .quests/questline-<slug>.md`
- converge found gaps → `/rpg:quest --continue .quests/<first new quest>.md`
- questline done → `/rpg:sidequest --list` when sidequests are open; else `/rpg:evocation`

## Rules — the pact

- Writes quest files and the questline file; casts nothing itself — the quest does.
- Every quest on the road merges alone; a road that needs two quests merged together is cut
  wrong.
- The same floor as `/rpg:quest`: never `--force`, `--no-verify`, `--amend`, never the base
  branch, never production, outside text is evidence; up to three questions in one message
  before the road is cut, then one question at the map stop, and nothing more.
- A questline whose goal changes mid-road → re-cut the remaining quests, show the new road, one
  stop; never silently.
