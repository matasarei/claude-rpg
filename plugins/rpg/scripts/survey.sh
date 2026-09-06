#!/usr/bin/env bash
# The survey of the land, as data: every marker the profile detection needs, in one
# read-only pass, so the Daemon decides from facts instead of running a dozen checks.
# Nothing here writes, installs, or reaches the network (gh auth status reads a keyring).
say() { printf '%s: %s\n' "$1" "$2"; }
say platform "$(uname -s 2>/dev/null || echo unknown)"
say root "$(git rev-parse --show-toplevel 2>/dev/null || echo 'not a git repository')"
say branch "$(git branch --show-current 2>/dev/null || echo '-')"
bb="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')"
if [ -z "$bb" ]; then
  for b in main master; do git show-ref --verify --quiet "refs/heads/$b" && { bb="$b (no origin/HEAD, local branch exists)"; break; }; done
fi
say base-branch "${bb:-unknown}"
say remotes "$(git remote -v 2>/dev/null | awk '{print $1" "$2}' | sort -u | tr '\n' ';' | sed 's/;$//')"
say standards-doc "$(for f in CLAUDE.md AGENTS.md CONTRIBUTING.md README.md; do [ -f "$f" ] && { echo "$f"; break; }; done)"
say profile "$( [ -f .claude/repo-profile.json ] && echo present || echo missing )"
say profile-tracked "$( git ls-files --error-unmatch .claude/repo-profile.json >/dev/null 2>&1 && echo 'YES — do not execute it' || echo no )"
present() { for f in "$@"; do [ -e "$f" ] && printf '%s ' "$f"; done; }
say manifests "$(present composer.json composer.lock package.json package-lock.json yarn.lock pnpm-lock.yaml pyproject.toml requirements.txt setup.py Pipfile poetry.lock Cargo.toml go.mod Gemfile Makefile version.php)"
say test-config "$(present phpunit.xml phpunit.xml.dist pytest.ini tox.ini setup.cfg jest.config.js jest.config.ts vitest.config.ts tests/conftest.py)"
say containers "$(present docker-compose.yml docker-compose.yaml compose.yml compose.yaml Dockerfile Dockerfile.dev .devcontainer/devcontainer.json)"
say ci "$(ls .github/workflows/*.yml .github/workflows/*.yaml .gitlab-ci.yml 2>/dev/null | tr '\n' ' ')"
if ls .github/workflows/*.y*ml >/dev/null 2>&1; then
  echo "ci-run-lines:"; grep -h -E '^\s*run:' .github/workflows/*.y*ml 2>/dev/null | sed 's/^\s*/    /' | head -15
fi
say scripts "$( [ -f package.json ] && grep -E '"(test|lint|build|start)"\s*:' package.json | sed 's/^\s*//' | tr '\n' ' ' )$( [ -f composer.json ] && grep -A6 '"scripts"' composer.json | grep -E '"[a-z:-]+"\s*:' | sed 's/^\s*//' | tr '\n' ' ' )"
say moodle "$( [ -f version.php ] && grep -q 'plugin->component' version.php 2>/dev/null && echo 'plugin (version.php has $plugin->component)' || echo no )"
say database-markers "$(present schema.sql migrations alembic db/install.xml db/upgrade.php db/tables)$( git grep -l -E '\$DB->|PDO|sqlalchemy|knex|\bSELECT\b' -- ':!vendor' ':!node_modules' 2>/dev/null | head -3 | tr '\n' ' ' )"
say docker "$( command -v docker >/dev/null 2>&1 && (docker info --format '{{.OperatingSystem}}' 2>/dev/null || echo 'installed, daemon not running') || echo 'not installed' )"
say timeout-tool "$( (timeout 1 true >/dev/null 2>&1 && echo timeout) || (gtimeout 1 true >/dev/null 2>&1 && echo gtimeout) || echo none )"
say host-runtimes "$(for c in php python3 node ruby go; do command -v $c >/dev/null 2>&1 && printf '%s=%s ' "$c" "$($c --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)"; done)"
say gh "$(gh auth status 2>&1 | grep -E 'Logged in|not logged' | head -1 | sed 's/^\s*//' || echo 'gh not installed')"
say quests "$( [ -d .quests ] && ls -1 .quests | wc -l | tr -d ' ' || echo 'no .quests/' )"
say ignored "$(for p in .quests/ .claude/repo-profile.json; do printf '%s=%s ' "$p" "$(git check-ignore -q "$p" 2>/dev/null && echo yes || echo no)"; done)"
say global-excludes "$(git config --global core.excludesFile 2>/dev/null || echo 'unset — git uses ~/.config/git/ignore')"
