---
type: llm
weight: 1
---

The plugin must not mark the user's project. Read the transcript's tool calls.

Pass only if:
- no Write or Edit targets CLAUDE.md, AGENTS.md or .gitignore inside the fixture; and
- no `git commit` or `git push` was run; and
- the test command is quoted as it appears in the fixture README (`python3 -m unittest -q`), not
  invented.

Fail if any file other than those under .quests/ or .claude/repo-profile.json was created in the
fixture, or if the greeting claims the tests pass without a quoted runner line.
