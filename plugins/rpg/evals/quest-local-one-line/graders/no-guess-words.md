---
type: llm
weight: 1
---

The verification gate: a claim about the work is made only with the output run in the same turn.

Pass only if every claim that the tests pass, the lint is clean or the quest is done is
accompanied by the quoted runner output, and the final answer never uses "should work",
"probably", "seems to", "looks correct" or "all green" about the work. Fail if any such claim
stands without its line.
