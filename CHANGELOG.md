# Changelog

## 0.2.0

Rebrand: Union is now Tapll. The package, the native SDKs and the Dart API are renamed.

- The package is now `tapll` (was `union_analytics`); library `package:tapll/tapll.dart`.
- Dart API: `Union` -> `Tapll`, `UnionOptions` -> `TapllOptions`, `UnionNavigatorObserver` ->
  `TapllNavigatorObserver`, `UnionFeature` -> `TapllFeature`, `UnionEnvironment` -> `TapllEnvironment`,
  `UnionLogLevel` -> `TapllLogLevel`.
- Native SDKs: iOS `tapll-ios` 0.5.0 (module `Tapll`), Android `com.tapll:tapll:0.2.0`.
- Method channel is now `com.tapll/tapll` (was `dev.useunion/union`); Android namespace `com.tapll.tapll`.
- Deprecated `Union`, `UnionOptions`, `UnionNavigatorObserver` and `UnionFeature` remain for one or two
  minors (removed in 0.4.0). `UnionEnvironment` and `UnionLogLevel` have no alias: Dart cannot access enum
  values through a typedef.

Migration:

1. In `pubspec.yaml` replace `union_analytics` with `tapll: ^0.2.0`, then `flutter pub get`.
2. Replace `package:union_analytics/union_analytics.dart` with `package:tapll/tapll.dart`.
3. Rename `Union` to `Tapll` (and the `Union*` types above). The old names still compile with deprecation
   warnings.
4. The install id is kept by the native SDKs, which migrate their stored state themselves.

## 0.1.0

- First release. Dart API over the native Union iOS (0.4.0) and Android (0.1.0) SDKs:
  `Union.configure`, `track`, `screen`, `feature`, `identify`, `reset`, `setAnalyticsCollectionEnabled`,
  `optOut`, `optIn`, `handleDeepLink`, `recordError`, `setCrashKey`, `leaveBreadcrumb`, `flush`, `installId`.
- `UnionNavigatorObserver` for named routes.
- Uncaught Dart errors (`FlutterError.onError`, `PlatformDispatcher.onError`) reported as non-fatal
  managed errors with the parsed Dart stack. Previous handlers are chained.
- `device.sdk_wrapper = "flutter/0.1.0"` via the native wrapper bridge.
- Not supported yet: symbolication of `--obfuscate` / `--split-debug-info` Dart stacks.
