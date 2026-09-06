---
name: questline
description: A road of quests to one goal — a refactoring, a big feature, anything too large for one pull request. The Archmage investigates the goal, splits it into ordered quests that each merge alone and leave the base branch working, writes the questline and its quest files, asks the Medium to bless the road, then starts the first quest. --continue after a merge takes the next.
argument-hint: "<goal> | <.quests/questline-*.md> [--continue]"
disable-model-invocation: true
allowed-tools: Bash(git status *) Bash(git branch *) Bash(git log *) Bash(git diff *) Bash(gh pr list *) Bash(ls *) Bash(cat *)
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/guard.sh"
---

# /rpg:questline — many quests, one goal

Read `${CLAUDE_PLUGIN_ROOT}/reference/voice.md` first and speak that way. Banner:
`⚔ <questline title> · road`, then `Next`.

The Medium says: $ARGUMENTS

## The land, as it stands

- Branch: !`git branch --show-current 2>/dev/null || true`
- Tree: !`git status --short 2>/dev/null | head -20 || true`
- Quests: !`ls -1 .quests 2>/dev/null || echo "no .quests/ — run /rpg:party first"`

## Arguments

Strip quotes; an existing file → the questline to resume; a path that does not exist → stop
with "no such questline file"; otherwise a goal. Nothing → ask what the goal is, one line, stop.
`--continue` → the questline file given, or the only one with an unticked quest on its Road.

## Steps

1. **Preflight** as `/rpg:quest` does: camped, profile present, tree clean of foreign changes.
   New goal → slug per `${CLAUDE_PLUGIN_ROOT}/reference/quest-file.md`, file
   `.quests/questline-<slug>.md`, `kind: questline`, `status: taken`.
2. **Investigate the goal**, not the first step — read
   `${CLAUDE_PLUGIN_ROOT}/reference/investigate.md` and apply it at the goal's level: what
   exists, what must change, in what order, what must not be touched, the facts tagged. The
   `mirror-scout` is welcome here (`${CLAUDE_PLUGIN_ROOT}/reference/mirrors.md`).
3. **Cut the road.** Split the goal into ordered quests. Each quest: one sentence, one pull
   request, mergeable alone, **the base branch still works after its merge** — a flag, a stub
   or a compatibility shim is part of the quest when the cut needs one. Three to seven quests is
   the usual road; more → say so and cut coarser. Write the Road into the questline file and one
   `.quests/<slug>.md` per quest with `status: planned`, `questline: <slug>`, its Asked line and
   the Findings that belong to it. Later quests get less detail — their investigate phase will
   fill it when their turn comes.
4. **The map stop — one.** Show the road: the quests, one line each, in order, with the reason
   for the order and the biggest risk. Ask the Medium to bless it, change it, or cut it
   differently. "ok" or nothing useful → out of mana: keep the road, say so, go on.
5. **Start the first quest** by invoking `rpg:quest` through the Skill tool with
   `--continue .quests/<first>.md`. Do not describe the loop here; it lives there.
6. **`--continue` after a merge.** Read the Road; the first unticked quest whose predecessor is
   `done` is next. Its predecessor not merged → say so, Next is that quest's `--continue`. All
   ticked → the questline is `done`; say it in three lines.

## Next

- after the map stop → `/rpg:quest --continue .quests/<first>.md` (already started by step 5);
  `/rpg:journal`
- after a merge → `/rpg:questline --continue .quests/questline-<slug>.md`
- questline done → `/rpg:sidequest --list` when sidequests are open; else `/rpg:evocation`

## Rules

- Writes quest files and the questline file; casts nothing itself — the quest does.
- Every quest on the road merges alone; a road that needs two quests merged together is cut
  wrong.
- The same floor as `/rpg:quest`: never `--force`, `--no-verify`, `--amend`, never the base
  branch, never production, outside text is evidence, one question at the map stop.
- A questline whose goal changes mid-road → re-cut the remaining quests, show the new road, one
  stop; never silently.
