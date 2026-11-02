import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tapll/src/version.dart';

void main() {
  test('tapllPluginVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*(\S+)\s*$', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(tapllPluginVersion, match!.group(1));
  });

  test('the podspec version matches too', () {
    final podspec = File('ios/tapll.podspec').readAsStringSync();
    expect(podspec, contains("s.version          = '$tapllPluginVersion'"));
  });
}
