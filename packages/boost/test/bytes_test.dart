import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  test('toHexString', _toHexStringTest);
  test('collect', _collectTest);
}

void _toHexStringTest() {
  final bytes = Uint8List.fromList([22, 255, 0, 32, 12]);
  expect(bytes.toHexString(), equals('16ff00200c'));
}

void _collectTest() async {
  final byteStream = Stream.fromIterable([
    [22, 255, 0, 32, 12],
    [255, 0, 22, 12, 32],
    [22, 255, 0, 32, 12],
  ]);
  final bytes = await byteStream.collect();
  expect(
      bytes,
      orderedEquals([
        22,
        255,
        0,
        32,
        12,
        255,
        0,
        22,
        12,
        32,
        22,
        255,
        0,
        32,
        12,
      ]));
}
