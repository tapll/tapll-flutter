// Deprecated names from the Union era (package `union_analytics`). Kept for a minor or two so a
// migration is only "change the dependency and the import". Remove in 0.4.0.
//
// Dart does not allow static member access through a typedef (`Union.track` via `typedef Union =
// Tapll` is an error), so `Union` is a forwarding class, not an alias. The same limit applies to
// enums: use `TapllEnvironment` and `TapllLogLevel` directly.
import 'navigator_observer.dart';
import 'tapll.dart';
import 'types.dart';

@Deprecated('Use TapllOptions. Will be removed in 0.4.0.')
typedef UnionOptions = TapllOptions;

@Deprecated('Use TapllNavigatorObserver. Will be removed in 0.4.0.')
typedef UnionNavigatorObserver = TapllNavigatorObserver;

@Deprecated('Use TapllFeature. Will be removed in 0.4.0.')
typedef UnionFeature = TapllFeature;

/// Forwards every call to [Tapll].
@Deprecated('Use Tapll. Will be removed in 0.4.0.')
abstract final class Union {
  @Deprecated('Use Tapll.configure.')
  static Future<void> configure({
    required String writeKey,
    required PrivacyMode privacyMode,
    TapllOptions? options,
  }) =>
      Tapll.configure(
          writeKey: writeKey, privacyMode: privacyMode, options: options);

  @Deprecated('Use Tapll.track.')
  static void track(
    String name, {
    Map<String, Object> properties = const <String, Object>{},
    String? feature,
    FeatureRole? role,
    String? screen,
  }) =>
      Tapll.track(name,
          properties: properties, feature: feature, role: role, screen: screen);

  @Deprecated('Use Tapll.screen.')
  static void screen(
    String name, {
    Map<String, Object> properties = const <String, Object>{},
    String? feature,
  }) =>
      Tapll.screen(name, properties: properties, feature: feature);

  @Deprecated('Use Tapll.feature.')
  static TapllFeature feature(String key) => Tapll.feature(key);

  @Deprecated('Use Tapll.identify.')
  static void identify(String userId,
          {Map<String, String> traits = const <String, String>{}}) =>
      Tapll.identify(userId, traits: traits);

  @Deprecated('Use Tapll.reset.')
  static void reset() => Tapll.reset();

  @Deprecated('Use Tapll.setAnalyticsCollectionEnabled.')
  static void setAnalyticsCollectionEnabled(bool enabled) =>
      Tapll.setAnalyticsCollectionEnabled(enabled);

  @Deprecated('Use Tapll.optOut.')
  static void optOut() => Tapll.optOut();

  @Deprecated('Use Tapll.optIn.')
  static void optIn() => Tapll.optIn();

  @Deprecated('Use Tapll.handleDeepLink.')
  static void handleDeepLink(Uri uri) => Tapll.handleDeepLink(uri);

  @Deprecated('Use Tapll.recordError.')
  static void recordError(String type, {String? reason}) =>
      Tapll.recordError(type, reason: reason);

  @Deprecated('Use Tapll.setCrashKey.')
  static void setCrashKey(String key, String? value) =>
      Tapll.setCrashKey(key, value);

  @Deprecated('Use Tapll.leaveBreadcrumb.')
  static void leaveBreadcrumb(String name) => Tapll.leaveBreadcrumb(name);

  @Deprecated('Use Tapll.flush.')
  static Future<void> flush() => Tapll.flush();

  @Deprecated('Use Tapll.installId.')
  static Future<String?> get installId => Tapll.installId;
}
