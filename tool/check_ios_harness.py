#!/usr/bin/env python3
"""Cross-platform iOS harness configuration check.

Replaces the macOS-only plutil/PlistBuddy/awk shell check so the same evidence can be
produced on Linux, in CI, and on macOS. Verifies:

1. Runner and Share Extension entitlements and the extension property list are valid plists.
2. Both entitlements declare the same App Group as their first application group.
3. Every IPHONEOS_DEPLOYMENT_TARGET in the Xcode project is the iOS 15.0 floor, so the
   Runner and the Share Extension cannot drift apart or follow Xcode's recommended target.
4. The extension is built with APPLICATION_EXTENSION_API_ONLY = YES.
5. The extension is embedded as a Foundation extension.
6. SharePayloadKit is a member of the expected number of build phases.
7. The extension enqueues the envelope before completing the request, so the durable handoff
   is written before the host application is told the share succeeded.
8. Runner's delegate still observes foreground entry and exposes the import status and retry
   channels.

Checks 6 to 8 are structural proxies for behavior that can only be proven on a device; they
guard against silent removal, not against runtime failure. See
docs/verification/DEFERRED_EVIDENCE.md for the device rows they stand in for.

Exit status is 0 only when every check passes.
"""

from __future__ import annotations

import plistlib
import re
import sys
from pathlib import Path

EXPECTED_DEPLOYMENT_TARGET = "15.0"
EXPECTED_APP_GROUP = "group.app.nextcue.share-spike"
EXPECTED_SHARE_PAYLOAD_MEMBERSHIPS = 4
APP_GROUP_KEY = "com.apple.security.application-groups"

REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
PROJECT_FILE = REPOSITORY_ROOT / "ios" / "Runner.xcodeproj" / "project.pbxproj"
RUNNER_ENTITLEMENTS = REPOSITORY_ROOT / "ios" / "Runner" / "Runner.entitlements"
EXTENSION_ENTITLEMENTS = REPOSITORY_ROOT / "ios" / "ShareExtension" / "ShareExtension.entitlements"
EXTENSION_INFO_PLIST = REPOSITORY_ROOT / "ios" / "ShareExtension" / "Info.plist"
EXTENSION_CONTROLLER = REPOSITORY_ROOT / "ios" / "ShareExtension" / "ShareViewController.swift"
RUNNER_DELEGATE = REPOSITORY_ROOT / "ios" / "Runner" / "AppDelegate.swift"

RUNNER_DELEGATE_REQUIREMENTS = (
    "UIApplication.willEnterForegroundNotification",
    'case "getImportStatus"',
    'case "retryImport"',
)

failures: list[str] = []
passed: list[str] = []


def fail(message: str) -> None:
    failures.append(message)


def ok(message: str) -> None:
    passed.append(message)


def read_text(path: Path, label: str) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        fail(f"{label}: missing file {path.relative_to(REPOSITORY_ROOT)}")
    except Exception as error:  # noqa: BLE001 - report any read failure as a check failure
        fail(f"{label}: unreadable ({error})")
    return ""


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


def check_deployment_targets(project: str) -> None:
    targets = re.findall(r"IPHONEOS_DEPLOYMENT_TARGET = ([^;]+);", project)
    if not targets:
        fail("Xcode project: no IPHONEOS_DEPLOYMENT_TARGET found")
        return
    mismatched = sorted({value.strip() for value in targets} - {EXPECTED_DEPLOYMENT_TARGET})
    if mismatched:
        fail(
            f"Xcode project: deployment targets {', '.join(mismatched)} do not match "
            f"{EXPECTED_DEPLOYMENT_TARGET}; Xcode's recommended target is not the iOS floor"
        )
        return
    ok(f"Xcode project: all {len(targets)} deployment targets are {EXPECTED_DEPLOYMENT_TARGET}")


def check_share_payload_memberships(project: str) -> None:
    count = project.count("SharePayloadKit.swift in Sources")
    if count != EXPECTED_SHARE_PAYLOAD_MEMBERSHIPS:
        fail(
            f"Xcode project: SharePayloadKit.swift has {count} build-file references, expected "
            f"{EXPECTED_SHARE_PAYLOAD_MEMBERSHIPS} (one file reference plus each build phase "
            "membership)"
        )
        return
    ok("Xcode project: SharePayloadKit is a member of the expected build phases")


def check_extension_write_order() -> None:
    source = read_text(EXTENSION_CONTROLLER, "Share Extension controller")
    if not source:
        return
    enqueue = source.find(".enqueue(envelope)")
    complete = source.find("completeRequest(returningItems:")
    if enqueue < 0:
        fail("Share Extension controller: the envelope is never enqueued")
        return
    if complete < 0:
        fail("Share Extension controller: the extension request is never completed")
        return
    if enqueue > complete:
        fail(
            "Share Extension controller: the request completes before the envelope is enqueued, "
            "so an accepted share can be lost"
        )
        return
    ok("Share Extension controller: the durable handoff is written before the request completes")


def check_runner_delegate() -> None:
    source = read_text(RUNNER_DELEGATE, "Runner delegate")
    if not source:
        return
    missing = [item for item in RUNNER_DELEGATE_REQUIREMENTS if item not in source]
    if missing:
        fail(f"Runner delegate: missing {', '.join(missing)}")
        return
    ok("Runner delegate: foreground import and the status/retry channels are present")


def main() -> int:
    for path, label in (
        (RUNNER_ENTITLEMENTS, "Runner entitlements"),
        (EXTENSION_ENTITLEMENTS, "Share Extension entitlements"),
        (EXTENSION_INFO_PLIST, "Share Extension Info.plist"),
    ):
        if read_plist(path, label) is not None:
            ok(f"{label}: valid property list")

    check_app_group(read_plist(RUNNER_ENTITLEMENTS, "Runner entitlements"), "Runner entitlements")
    check_app_group(
        read_plist(EXTENSION_ENTITLEMENTS, "Share Extension entitlements"),
        "Share Extension entitlements",
    )

    project = read_text(PROJECT_FILE, "Xcode project")
    if project:
        check_deployment_targets(project)

        if "APPLICATION_EXTENSION_API_ONLY = YES;" in project:
            ok("Xcode project: extension-safe API enforcement is enabled")
        else:
            fail("Xcode project: APPLICATION_EXTENSION_API_ONLY = YES is missing")

        if "Embed Foundation Extensions" in project:
            ok("Xcode project: the extension is embedded as a Foundation extension")
        else:
            fail("Xcode project: Embed Foundation Extensions phase is missing")

        check_share_payload_memberships(project)

    check_extension_write_order()
    check_runner_delegate()

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
