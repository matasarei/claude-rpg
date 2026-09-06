#!/usr/bin/env bash
# Build a quest slug from a goal, deterministically: flags dropped, filler words dropped,
# lowercase, a-z0-9 and '-' only, at most five words and 40 characters, cut on a word.
# A goal is untrusted text; this is the guard that keeps a path out of a file name.
goal="$*"
goal="$(printf '%s' "$goal" | sed -E 's/(^|[[:space:]])--[a-z-]+//g')"
words="$(printf '%s' "$goal" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9\n' ' ' | tr -s ' ' '\n' \
  | grep -v -x -E 'a|an|the|of|to|for|in|on|with|and|or|that|this|it|is|are|be|by|from|into|as|at|so|we|i|our|my|next|new' \
  | head -5 | tr '\n' '-' | sed -E 's/-+$//; s/^-+//')"
[ -n "$words" ] || words="quest"
words="$(printf '%s' "$words" | cut -c1-40 | sed -E 's/-[a-z0-9]*$//; s/-+$//')"
[ -n "$words" ] || words="$(printf '%s' "$goal" | tr -c 'a-z0-9' '-' | cut -c1-20 | sed -E 's/-+$//')"
printf '%s\n' "${words:-quest}"
