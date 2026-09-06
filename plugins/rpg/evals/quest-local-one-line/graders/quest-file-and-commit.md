---
type: llm
weight: 1
---

Read the transcript's tool calls and results.

Pass only if:
- a file under .quests/ was written whose frontmatter ends with `status: done`, whose criteria are
  ticked, and whose steps carry Create:, Modify: or Test: lines;
- at least one `git commit` was run on a branch named quest/…, and the commit message's first
  line is a plain imperative summary with no emoji and none of the words Daemon, Summoner, quest,
  spell, scroll (a light touch is allowed only in later lines of the body);
- no `git push` and no `gh pr` command was run.

Fail if any of the three is missing.
