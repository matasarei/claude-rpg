#!/usr/bin/env bash
# Prints the voice reference so a skill can inject it at invocation time:
#   !`"${CLAUDE_PLUGIN_ROOT}/scripts/voice.sh" || true`
# A bundled script is the documented way to bring a plugin file into a skill;
# a bare `cat` of a path outside the working directory is refused by the harness.
here="$(cd "$(dirname "$0")" && pwd)"
cat "$here/../reference/voice.md"
