#!/usr/bin/env bash
# Builds the fixture inside the eval scaffold: a tiny Python module with one unittest test,
# committed on main, with no remote. The agent never sees a path into the plugin repository.
set -euo pipefail
git init -q -b main
cat > greet.py <<'PY'
def greet(name: str) -> str:
    return f"Hello, {name}!"
PY
cat > test_greet.py <<'PY'
import unittest
from greet import greet


class GreetTest(unittest.TestCase):
    def test_greet(self):
        self.assertEqual(greet("Summoner"), "Hello, Summoner!")


if __name__ == "__main__":
    unittest.main()
PY
printf '# sandbox\n\nA tiny Python module. Test: `python3 -m unittest -q`.\n' > README.md
git -c user.name=fixture -c user.email=fixture@example.invalid add -A
git -c user.name=fixture -c user.email=fixture@example.invalid commit -q -m "Init fixture"
mkdir -p .quests
cat > .quests/export-csv.md <<'MD'
---
kind: quest
status: awaiting
questline: null
branch: quest/export-csv
pr: https://github.com/example/repo/pull/118
found-during: null
decision: null
merged: null
---
# Export departments as CSV

**Asked:** export departments as CSV

## Findings
- the export writes XLSX only [from the code]

## Map
Criteria:
- [x] a CSV writer exists
- [ ] departments with the same name stay apart

## Log
- 2026-09-06 14:02 taken — branch quest/export-csv
- 2026-09-06 14:08 ruling — CSV writer beside the XLSX one — they share three lines — cost if wrong: one refactor
- 2026-09-06 14:55 scroll — https://github.com/example/repo/pull/118
MD
cat > .quests/side-null-head.md <<'MD'
---
kind: sidequest
status: found
questline: null
branch: null
pr: null
found-during: export-csv
decision: null
merged: null
---
# A department with no head crashes the XLSX export

**Found:** `XlsxWriter.php:77` reads `$head->name` with no null check [from the code].
MD
