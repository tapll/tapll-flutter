/// Tapll analytics and crash reporting for Flutter, over the native iOS and Android SDKs.
library;

export 'src/navigator_observer.dart' show TapllNavigatorObserver;
export 'src/types.dart' show PrivacyMode, FeatureRole, TapllOptions, TapllEnvironment, TapllLogLevel;
export 'src/tapll.dart' show Tapll, TapllFeature;
// Deprecated Union-era names, removed in 0.4.0.
export 'src/deprecated.dart';
