#!/usr/bin/env python3
"""Cross-platform iOS harness configuration check.

Replaces the macOS-only plutil/PlistBuddy/awk shell check so the same evidence can be
produced on Linux, in CI, and on macOS. Verifies:

1. Runner and Share Extension entitlements and the extension property list are valid plists.
2. Both entitlements declare the same App Group as their first application group.
3. Every IPHONEOS_DEPLOYMENT_TARGET in the Xcode project is 15.0 and at least one exists.
4. The extension is built with APPLICATION_EXTENSION_API_ONLY = YES.
5. The extension is embedded as a Foundation extension.

Exit status is 0 only when every check passes.
"""

from __future__ import annotations

import plistlib
import re
import sys
from pathlib import Path

EXPECTED_DEPLOYMENT_TARGET = "15.0"
EXPECTED_APP_GROUP = "group.app.nextcue.share-spike"
APP_GROUP_KEY = "com.apple.security.application-groups"

REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
PROJECT_FILE = REPOSITORY_ROOT / "ios" / "Runner.xcodeproj" / "project.pbxproj"
RUNNER_ENTITLEMENTS = REPOSITORY_ROOT / "ios" / "Runner" / "Runner.entitlements"
EXTENSION_ENTITLEMENTS = REPOSITORY_ROOT / "ios" / "ShareExtension" / "ShareExtension.entitlements"
EXTENSION_INFO_PLIST = REPOSITORY_ROOT / "ios" / "ShareExtension" / "Info.plist"

failures: list[str] = []
passed: list[str] = []


def fail(message: str) -> None:
    failures.append(message)


def ok(message: str) -> None:
    passed.append(message)


def read_plist(path: Path, label: str) -> dict | None:
    try:
        with path.open("rb") as handle:
            return plistlib.load(handle)
    except FileNotFoundError:
        fail(f"{label}: missing file {path.relative_to(REPOSITORY_ROOT)}")
    except Exception as error:  # noqa: BLE001 - report any parse failure as a check failure
        fail(f"{label}: invalid property list ({error})")
    return None


def check_app_group(plist: dict | None, label: str) -> None:
    if plist is None:
        return
    groups = plist.get(APP_GROUP_KEY)
    if not isinstance(groups, list) or not groups:
        fail(f"{label}: {APP_GROUP_KEY} is missing or empty")
        return
    if groups[0] != EXPECTED_APP_GROUP:
        fail(f"{label}: first application group is {groups[0]!r}, expected {EXPECTED_APP_GROUP!r}")
        return
    ok(f"{label}: first application group is {EXPECTED_APP_GROUP}")


def main() -> int:
    for path, label in (
        (RUNNER_ENTITLEMENTS, "Runner entitlements"),
        (EXTENSION_ENTITLEMENTS, "Share Extension entitlements"),
        (EXTENSION_INFO_PLIST, "Share Extension Info.plist"),
    ):
        plist = read_plist(path, label)
        if plist is not None and label != "Share Extension Info.plist":
            ok(f"{label}: valid property list")
        elif plist is not None:
            ok(f"{label}: valid property list")

    runner = read_plist(RUNNER_ENTITLEMENTS, "Runner entitlements")
    extension = read_plist(EXTENSION_ENTITLEMENTS, "Share Extension entitlements")
    check_app_group(runner, "Runner entitlements")
    check_app_group(extension, "Share Extension entitlements")

    try:
        project = PROJECT_FILE.read_text(encoding="utf-8")
    except FileNotFoundError:
        fail(f"Xcode project: missing file {PROJECT_FILE.relative_to(REPOSITORY_ROOT)}")
        project = ""

    if project:
        targets = re.findall(r"IPHONEOS_DEPLOYMENT_TARGET = ([^;]+);", project)
        if not targets:
            fail("Xcode project: no IPHONEOS_DEPLOYMENT_TARGET found")
        else:
            mismatched = sorted({value.strip() for value in targets} - {EXPECTED_DEPLOYMENT_TARGET})
            if mismatched:
                fail(
                    "Xcode project: deployment targets "
                    f"{', '.join(mismatched)} do not match {EXPECTED_DEPLOYMENT_TARGET}"
                )
            else:
                ok(
                    f"Xcode project: all {len(targets)} deployment targets are "
                    f"{EXPECTED_DEPLOYMENT_TARGET}"
                )

        if "APPLICATION_EXTENSION_API_ONLY = YES;" in project:
            ok("Xcode project: extension-safe API enforcement is enabled")
        else:
            fail("Xcode project: APPLICATION_EXTENSION_API_ONLY = YES is missing")

        if "Embed Foundation Extensions" in project:
            ok("Xcode project: the extension is embedded as a Foundation extension")
        else:
            fail("Xcode project: Embed Foundation Extensions phase is missing")

    for message in passed:
        print(f"ok   {message}")
    for message in failures:
        print(f"FAIL {message}")

    if failures:
        print(f"\niOS harness configuration checks failed ({len(failures)}).")
        return 1
    print("\niOS harness configuration checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
