.PHONY: format lint

SWIFT_SOURCES := \
	ios/Runner \
	ios/RunnerTests \
	ios/ShareExtension \
	ios/SharePayloadKit/Package.swift \
	ios/SharePayloadKit/Sources \
	ios/SharePayloadKit/Tests

format:
	dart format .
	swift format --in-place --recursive --parallel $(SWIFT_SOURCES)

lint:
	dart format --output=none --set-exit-if-changed .
	flutter analyze
	swift format lint --strict --recursive --parallel $(SWIFT_SOURCES)
