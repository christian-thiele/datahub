import 'dart:io';

import 'package:datahub_aperture/api.dart';
import 'package:test/test.dart';

void main() {
  test('apertureVersion matches pubspec version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*(\S+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec)?.group(1);

    expect(
      apertureVersion,
      version,
      reason:
          'Run "dart run tool/generate_aperture_version.dart" '
          'from the workspace root.',
    );
  });
}
