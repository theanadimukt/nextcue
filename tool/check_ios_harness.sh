#!/bin/sh
# Compatibility wrapper. The check itself lives in check_ios_harness.py so the same evidence
# can be produced on Linux, in CI, and on macOS without plutil or PlistBuddy.
set -eu

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if command -v python3 >/dev/null 2>&1; then
  exec python3 "$directory/check_ios_harness.py"
fi

printf '%s\n' 'python3 is required to run the iOS harness configuration check.' >&2
exit 1
