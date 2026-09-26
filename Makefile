.PHONY: format lint check check-format check-analyze check-test check-ios-config check-apple swift-test ios-build help

SWIFT_SOURCES := \
	ios/Runner \
	ios/RunnerTests \
	ios/ShareExtension \
	ios/SharePayloadKit/Package.swift \
	ios/SharePayloadKit/Sources \
	ios/SharePayloadKit/Tests

# Rewrites sources in place. Requires the Dart and Swift toolchains.
format:
	dart format .
	swift format --in-place --recursive --parallel $(SWIFT_SOURCES)

# Strict formatting and analysis check. Requires the Dart and Swift toolchains.
lint:
	dart format --output=none --set-exit-if-changed .
	flutter analyze
	swift format lint --strict --recursive --parallel $(SWIFT_SOURCES)

# Automated evidence that needs no Apple toolchain, simulator, or device.
# CI runs exactly these commands, so they are the implementation gate for every task.
check: check-format check-analyze check-test check-ios-config

check-format:
	dart format --output=none --set-exit-if-changed .

check-analyze:
	flutter analyze

check-test:
	flutter test

# Cross-platform replacement for the former macOS-only shell check.
check-ios-config:
	python3 tool/check_ios_harness.py

# Apple-toolchain evidence. Requires macOS with Xcode; the macOS CI job runs the same work.
# Passing this does not prove device behavior; see docs/verification/DEFERRED_EVIDENCE.md.
check-apple: swift-test ios-build

swift-test:
	cd ios/SharePayloadKit && swift test

ios-build:
	flutter build ios --release --no-codesign

help:
	@echo "make check        - automated evidence, runs on Linux and in CI"
	@echo "make check-apple  - Swift tests and unsigned iOS build (macOS only)"
	@echo "make format       - rewrite Dart and Swift formatting"
	@echo "make lint         - strict formatting and analysis check"
