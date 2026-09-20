#!/bin/sh
set -eu

project=ios/Runner.xcodeproj/project.pbxproj
runner_entitlements=ios/Runner/Runner.entitlements
extension_entitlements=ios/ShareExtension/ShareExtension.entitlements
expected_group=group.app.nextcue.share-spike

plutil -lint "$runner_entitlements" "$extension_entitlements" ios/ShareExtension/Info.plist >/dev/null

runner_group=$(/usr/libexec/PlistBuddy -c 'Print :com.apple.security.application-groups:0' "$runner_entitlements")
extension_group=$(/usr/libexec/PlistBuddy -c 'Print :com.apple.security.application-groups:0' "$extension_entitlements")
[ "$runner_group" = "$expected_group" ]
[ "$extension_group" = "$expected_group" ]

awk '
  /IPHONEOS_DEPLOYMENT_TARGET =/ {
    value = $3
    gsub(/;/, "", value)
    if (value != "15.0") exit 1
    found = 1
  }
  END { if (!found) exit 1 }
' "$project"

awk '
  /APPLICATION_EXTENSION_API_ONLY = YES;/ { safe = 1 }
  /Embed Foundation Extensions/ { embedded = 1 }
  END { if (!safe || !embedded) exit 1 }
' "$project"

printf '%s\n' 'iOS harness configuration checks passed.'
