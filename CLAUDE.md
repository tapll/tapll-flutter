# tapll-flutter

Flutter plugin `tapll`: a thin Dart wrapper over the native Tapll SDKs (`tapll-ios`, `tapll-android`).

## Rules

- **The contract lives in `union-panel/packages/contract`** (event and crash schemas). The cross-SDK agreement is
  `union-panel/docs/Engineering/SDK-PLATFORMS.md`. This repo changes neither.
- **Wrappers forward only.** No transport, no queue, no retry, no sessions, no privacy logic, no ingest URL.
  Every call becomes one method-channel message to the native SDK, which is the only thing that talks to ingest.
  Dart validates property values lightly; the native SDK stays the authority.
- Native bridge calls only: `setWrapper` (before `configure`) and `recordManagedError`
  (`@_spi(Wrapper) import Tapll` on iOS, `Tapll.Wrapper` on Android). Nothing else non-public.
- The public Dart API is what the Tapll panel's setup prompt tells customers to call
  (`union-panel/apps/panel/src/features/onboarding/sdk-prompt.ts`, `case 'flutter'` and `const DART`).
  A change to it is a change to that prompt.
- Calls never throw into app code. A missing or failing native side is logged in debug and ignored.
- `lib/src/version.dart` must equal `pubspec.yaml` and the podspec version (`test/version_test.dart`).
- English only in code, docs and strings.

## Layout

- `lib/` Dart API; `lib/src/stack_parser.dart` parses Dart stacks (in_app rule documented there).
- `ios/TapllCore/` Swift: argument mapping and dispatch, no Flutter import, `swift test` runs on the host.
  It declares the `tapll-ios` dependency (GitHub URL, from 0.4.0).
- `ios/tapll/` Flutter's SwiftPM plugin package (channel glue only). `ios/tapll.podspec` exists
  but CocoaPods is not a supported install path (tapll-ios has no podspec).
- `android/` Kotlin: `Arguments.kt` (mapping, JUnit tested) and `TapllPlugin.kt` (dispatch).
- `example/` configures Tapll, tracks a screen and an event.

## Commands

```sh
flutter test                                   # Dart tests
cd ios/TapllCore && swift test        # iOS mapping tests
cd example/android && ./gradlew :tapll:testDebugUnitTest   # Android mapping tests
cd example && flutter build apk --debug && flutter build ios --debug --no-codesign
```

Android env: `ANDROID_HOME=/opt/homebrew/share/android-commandlinetools`, `JAVA_HOME=/opt/homebrew/opt/openjdk@17`.
Against an unreleased tapll-android: `./gradlew :tapll:publishToMavenLocal` there and add `mavenLocal()` to the example's repositories.

## Known quirk: checkout directory name

Flutter's SwiftPM integration names a path plugin's symlink after the checkout directory and requires it to equal
the package name. In a directory called `tapll-flutter`, `flutter build ios` in `example/` fails with
"unable to override package 'tapll' because its identity 'tapll-flutter' ...". Build iOS from a checkout
or symlink-free copy whose directory is named `tapll` (for example
`rsync -a --exclude build --exclude .dart_tool ./ ../tapll/`). Pub-hosted installs are not affected.

## Release checklist

1. tapll-ios tagged `0.5.0`: in `ios/TapllCore/Package.swift` switch to
   `.package(url: "https://github.com/tapll/tapll-ios", from: "0.5.0")`.
2. `com.tapll:tapll:0.2.0` on Maven Central: drop `mavenLocal()` from the example.
3. Bump version in pubspec, podspec, `lib/src/version.dart`, CHANGELOG. `dart pub publish --dry-run`.
