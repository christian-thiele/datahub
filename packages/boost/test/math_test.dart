import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  test('round', _roundTest);
  test('clamp', _clampTest);
  test('deg <-> rad', _degRadTest);
}

void _roundTest() {
  expect(round(0), equals(0));
  expect(round(10), equals(10));
  expect(round(10, -2), equals(0));
  expect(round(10, 2), equals(10));
  expect(round(1.25, 1), equals(1.3));
  expect(round(-1.25, 1), equals(-1.3));
  expect(round(545, -1), equals(550));
  expect(round(545, -2), equals(500));
  expect(round(545, 0), equals(545));
  expect(round(545, 2), equals(545));
  expect(round(545, -3), equals(1000));

  expect(round(double.infinity, 2), equals(double.infinity));
  expect(round(double.negativeInfinity, 2), equals(double.negativeInfinity));
  expect(round(double.nan, 2), isNaN);
}

void _clampTest() {
  expect(clamp(5, 10, 20), equals(10));
  expect(clamp(10, 10, 20), equals(10));
  expect(clamp(15, 10, 20), equals(15));
  expect(clamp(20, 10, 20), equals(20));
  expect(clamp(25, 10, 20), equals(20));

  expect(clamp(5.0, 10.0, 20.0), equals(10.0));
  expect(clamp(10.0, 10.0, 20.0), equals(10.0));
  expect(clamp(15.0, 10.0, 20.0), equals(15.0));
  expect(clamp(20.0, 10.0, 20.0), equals(20.0));
  expect(clamp(25.0, 10.0, 20.0), equals(20.0));
}

void _degRadTest() {
  final values = {
    0: 0,
    90: 1.5707963267948966,
    180: 3.141592653589793,
    360: 6.283185307179586,
    720: 12.566370614359172,
  };

  for (final pair in values.entries) {
    expect(toRadians(pair.key), pair.value);
    expect(toDegrees(pair.value), pair.key);
  }
}
