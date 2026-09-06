---
type: llm
weight: 1
---

The journal must answer from the injected Road table, not by reading quest files.

Pass only if the transcript contains no Read, cat or sed call on a path under .quests/, and the
answer still names the sidequest side-null-head and the quest's ruling (the CSV writer beside the
XLSX one). Fail if a quest file was opened, or if the sidequest or the ruling is missing.
