import 'package:flutter/material.dart';
import 'package:tapll/tapll.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // privacyMode must match the project in Tapll (Settings -> Privacy); it cannot be changed later.
  await Tapll.configure(
    writeKey: 'av_example_key',
    privacyMode: PrivacyMode.productAnalytics,
    options: const TapllOptions(logLevel: TapllLogLevel.debug),
  );
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapll example',
      navigatorObservers: [TapllNavigatorObserver()],
      routes: {
        '/': (_) => const HomePage(),
        '/checkout': (_) => const CheckoutPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tapll example')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => Tapll.track('settings_changed', properties: {'setting': 'units'}),
              child: const Text('Track an event'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed('/checkout'),
              child: const Text('Open checkout (a screen)'),
            ),
            FilledButton(
              onPressed: () => Tapll.recordError('ExampleError', reason: 'recorded from the example'),
              child: const Text('Record an error'),
            ),
            FilledButton(
              onPressed: () => throw StateError('uncaught example error'),
              child: const Text('Throw an uncaught error'),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  static final checkout = Tapll.feature('checkout');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            checkout.start('checkout_started');
            checkout.success('order_placed', properties: {'items': 3});
          },
          child: const Text('Place order'),
        ),
      ),
    );
  }
}
