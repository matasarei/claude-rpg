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
