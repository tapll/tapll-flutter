// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter_test/flutter_test.dart';
import 'package:tapll/tapll.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChannelRecorder rec;

  setUp(() => rec = ChannelRecorder());
  tearDown(() => rec.dispose());

  test('deprecated Union forwards to the Tapll channel', () async {
    Union.track('legacy_event', properties: {'a': 1});
    Union.reset();
    await Union.flush();
    expect(rec.calls.map((c) => c.method), ['track', 'reset', 'flush']);
    expect(rec.args(0)['name'], 'legacy_event');
  });

  test('deprecated type aliases resolve to the Tapll types', () {
    const UnionOptions options = TapllOptions();
    expect(options, isA<TapllOptions>());
    expect(UnionNavigatorObserver(), isA<TapllNavigatorObserver>());
  });
}
