# NextCue

Disposable Flutter iOS Share Extension harness for ADR-003.

## Code style

Use platform-native tools; no extra formatter dependency is required.

```sh
make format # Dart formatter and Swift formatter
make lint   # Dart format check, Flutter analyzer, and strict Swift format check
```

`dart format` is Flutter's canonical Prettier equivalent. `flutter analyze`
uses `flutter_lints` through `analysis_options.yaml`. Xcode's Swift toolchain
provides `swift format` and `swift format lint`.
