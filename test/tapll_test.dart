import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapll/tapll.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChannelRecorder rec;

  setUp(() => rec = ChannelRecorder());
  tearDown(() => rec.dispose());

  group('configure', () {
    test('sends wrapper name and version together with the key, mode and options', () async {
      await Tapll.configure(
        writeKey: 'av_key',
        privacyMode: PrivacyMode.strictAnonymous,
        options: const TapllOptions(
          environment: TapllEnvironment.testflight,
          logLevel: TapllLogLevel.debug,
          crashReporting: false,
          hangDetection: false,
          inAppPackages: ['my_feature'],
        ),
      );
      expect(rec.calls.map((c) => c.method), ['configure']);
      expect(rec.args(0), {
        'writeKey': 'av_key',
        'privacyMode': 'strict_anonymous',
        'wrapperName': 'flutter',
        'wrapperVersion': '0.2.0',
        'options': {
          'environment': 'testflight',
          'logLevel': 'debug',
          'crashReporting': false,
          'hangDetection': false,
          'inAppPackages': ['my_feature'],
        },
      });
    });

    test('defaults: product analytics, crash reporting and hang detection on, no overrides', () async {
      await Tapll.configure(writeKey: 'k', privacyMode: PrivacyMode.productAnalytics);
      expect(rec.args(0)['privacyMode'], 'product_analytics');
      expect(rec.args(0)['options'], {
        'environment': null,
        'logLevel': null,
        'crashReporting': true,
        'hangDetection': true,
        'inAppPackages': <String>[],
      });
    });
  });

  group('track and screen', () {
    test('track forwards name, properties, feature, role and screen', () async {
      Tapll.track(
        'order_placed',
        properties: {'items': 3, 'total': 9.5, 'gift': true, 'plan': 'pro'},
        feature: 'checkout',
        role: FeatureRole.success,
        screen: 'Checkout',
      );
      await settle();
      expect(rec.calls.single.method, 'track');
      expect(rec.args(0), {
        'name': 'order_placed',
        'properties': {'items': 3, 'total': 9.5, 'gift': true, 'plan': 'pro'},
        'feature': 'checkout',
        'role': 'success',
        'screen': 'Checkout',
      });
    });

    test('track with no extras sends nulls and empty properties', () async {
      Tapll.track('settings_changed');
      await settle();
      expect(rec.args(0), {
        'name': 'settings_changed',
        'properties': <String, Object>{},
        'feature': null,
        'role': null,
        'screen': null,
      });
    });

    test('invalid property values are dropped, valid ones kept', () async {
      Tapll.track('e', properties: {
        'ok': 'x',
        'nan': double.nan,
        'inf': double.infinity,
        'list': [1, 2],
        'map': {'a': 1},
        'when': DateTime(2026),
        'n': 1,
      });
      await settle();
      expect((rec.args(0)['properties'] as Map), {'ok': 'x', 'n': 1});
    });

    test('screen forwards name, properties and feature', () async {
      Tapll.screen('Checkout', properties: {'step': 2}, feature: 'checkout');
      await settle();
      expect(rec.calls.single.method, 'screen');
      expect(rec.args(0), {'name': 'Checkout', 'properties': {'step': 2}, 'feature': 'checkout'});
    });
  });

  group('feature handle', () {
    test('role methods map to track with the feature key and role', () async {
      final checkout = Tapll.feature('checkout');
      checkout.discovery('checkout_seen');
      checkout.start('checkout_started');
      checkout.use('shipping_selected');
      checkout.success('order_placed', properties: {'items': 3});
      checkout.failure('payment_failed', properties: {'reason': 'card_declined'});
      await settle();
      expect(rec.calls.map((c) => c.method), everyElement('track'));
      expect(
        [for (var i = 0; i < 5; i++) '${rec.args(i)['name']}:${rec.args(i)['role']}:${rec.args(i)['feature']}'],
        [
          'checkout_seen:discovery:checkout',
          'checkout_started:start:checkout',
          'shipping_selected:use:checkout',
          'order_placed:success:checkout',
          'payment_failed:failure:checkout',
        ],
      );
      expect(rec.args(3)['properties'], {'items': 3});
      expect(rec.args(4)['properties'], {'reason': 'card_declined'});
    });

    test('feature.screen maps to screen with the feature', () async {
      Tapll.feature('checkout').screen('Checkout', properties: {'a': 'b'});
      await settle();
      expect(rec.calls.single.method, 'screen');
      expect(rec.args(0), {'name': 'Checkout', 'properties': {'a': 'b'}, 'feature': 'checkout'});
    });

    test('handles with the same key are equal', () {
      expect(Tapll.feature('a'), Tapll.feature('a'));
      expect(Tapll.feature('a'), isNot(Tapll.feature('b')));
    });
  });

  group('identity, privacy and the rest', () {
    test('identify and reset', () async {
      Tapll.identify('user_1', traits: {'plan': 'pro'});
      Tapll.identify('user_2');
      Tapll.reset();
      await settle();
      expect(rec.calls.map((c) => c.method), ['identify', 'identify', 'reset']);
      expect(rec.args(0), {'userId': 'user_1', 'traits': {'plan': 'pro'}});
      expect(rec.args(1), {'userId': 'user_2', 'traits': <String, String>{}});
      expect(rec.calls[2].arguments, isNull);
    });

    test('collection switches', () async {
      Tapll.setAnalyticsCollectionEnabled(false);
      Tapll.optOut();
      Tapll.optIn();
      await settle();
      expect(rec.calls.map((c) => c.method), ['setAnalyticsCollectionEnabled', 'optOut', 'optIn']);
      expect(rec.args(0), {'enabled': false});
    });

    test('handleDeepLink sends scheme, host and path only', () async {
      Tapll.handleDeepLink(Uri.parse('myapp://open/item/42?token=secret&x=1#frag'));
      await settle();
      expect(rec.calls.single.method, 'handleDeepLink');
      expect(rec.args(0), {'url': 'myapp://open/item/42'});
    });

    test('handleDeepLink with https', () async {
      Tapll.handleDeepLink(Uri.parse('https://example.com/a/b?utm=1'));
      await settle();
      expect(rec.args(0), {'url': 'https://example.com/a/b'});
    });

    test('recordError, crash keys and breadcrumbs', () async {
      Tapll.recordError('PaymentFailed', reason: 'card_declined');
      Tapll.recordError('Other');
      Tapll.setCrashKey('plan', 'pro');
      Tapll.setCrashKey('plan', null);
      Tapll.leaveBreadcrumb('opened_cart');
      await settle();
      expect(rec.calls.map((c) => c.method),
          ['recordError', 'recordError', 'setCrashKey', 'setCrashKey', 'leaveBreadcrumb']);
      expect(rec.args(0), {'type': 'PaymentFailed', 'reason': 'card_declined'});
      expect(rec.args(1), {'type': 'Other', 'reason': null});
      expect(rec.args(2), {'key': 'plan', 'value': 'pro'});
      expect(rec.args(3), {'key': 'plan', 'value': null});
      expect(rec.args(4), {'name': 'opened_cart'});
    });

    test('flush completes after the native reply', () async {
      await Tapll.flush();
      expect(rec.calls.single.method, 'flush');
    });
  });

  group('installId', () {
    test('returns the native id', () async {
      rec.dispose();
      rec = ChannelRecorder(replies: {'getInstallId': (_) => 'abc-123'});
      expect(await Tapll.installId, 'abc-123');
      expect(rec.calls.single.method, 'getInstallId');
    });

    test('is null when the native side has none (strict anonymous, not configured)', () async {
      expect(await Tapll.installId, isNull);
    });
  });

  group('calls never throw into app code', () {
    test('PlatformException from native is swallowed', () async {
      rec.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.tapll/tapll'),
        (call) async => throw PlatformException(code: 'boom', message: 'native failed'),
      );
      await Tapll.configure(writeKey: 'k', privacyMode: PrivacyMode.productAnalytics);
      Tapll.track('e');
      Tapll.screen('s');
      await Tapll.flush();
      expect(await Tapll.installId, isNull);
    });

    test('a missing plugin (no native side registered) is swallowed', () async {
      rec.dispose();
      await Tapll.configure(writeKey: 'k', privacyMode: PrivacyMode.productAnalytics);
      Tapll.track('e');
      Tapll.identify('u');
      await Tapll.flush();
      expect(await Tapll.installId, isNull);
    });
  });
}
