import 'dart:math';

import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  test('round', _roundTest);
  test('round without floating point noise', _roundNoiseTest);
  test('clamp', _clampTest);
  test('deg <-> rad', _degRadTest);
  test('sum', _sumTest);
  test('avg', _avgTest);
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

void _roundNoiseTest() {
  // positive digits: dividing by 10^-digits (0.01) is inexact
  expect(round(870.55225352, 2), equals(870.55));
  expect(round(-870.55225352, 2), equals(-870.55));
  expect(round(-63758.76088004, 6), equals(-63758.76088));
  expect(round(913168.4957863368, 5), equals(913168.49579));

  // negative digits: multiplying by 10^digits (0.01) is inexact
  expect(round(6513720.8283, -5), equals(6500000));
  expect(round(-64200005, -5), equals(-64200000));
  expect(round(1250, -2), equals(1300));
  expect(round(-1250, -2), equals(-1300));
  expect(round(1234.5, -2), equals(1200));

  // ties are decided on the decimal representation
  expect(round(0.5), equals(1));
  expect(round(-0.5), equals(-1));
  expect(round(2.5), equals(3));
  expect(round(1.005, 2), equals(1.01));
  expect(round(2.675, 2), equals(2.68));
  expect(round(12703.87755, 4), equals(12703.8776));
  expect(round(-8374.3095, 3), equals(-8374.31));
  expect(round(1.15, 1), equals(1.2));

  // values that are already precise enough stay untouched
  expect(round(1.5, 5), equals(1.5));
  expect(round(0.1 + 0.2, 17), equals(0.1 + 0.2));
  expect(round(1e-10, 25), equals(1e-10));
  expect(round(1e300, 2), equals(1e300));
  expect(round(123456789012345678.0, 2), equals(123456789012345678.0));

  // magnitudes beyond int64 and digit counts beyond double range
  expect(round(1e300, -298), equals(1e300));
  expect(round(1.25e300, -299), equals(1.3e300));
  expect(round(9200000000000000000, -18), equals(9e18));
  expect(round(9500000000000000000.0, -19), equals(1e19));
  expect(round(9223372036854775807, -19), equals(1e19));
  expect(round(-9223372036854775808, -19), equals(-1e19));
  expect(round(9223372036854775807, -1), equals(9.22337203685477581e18));
  expect(round(9500000000000000000.0), equals(9.5e18));
  expect(round(9500000000000000000.0, -18), equals(1e19));
  expect(round(123456789012345678000.0, -3), equals(123456789012345680000.0));
  expect(round(5, -400), equals(0));
  expect(round(5.0, 400), equals(5.0));
  expect(round(0, 400), equals(0));
  expect(round(5e-324, 2), equals(0));
  expect(round(-0.4), equals(0));
  expect(round(-0.4).isNegative, isFalse);
  expect(round(1e-7, 7), equals(1e-7));
  expect(round(1.5e-7, 7), equals(2e-7));

  // the result never prints more digits than requested, nor fewer zeros
  final random = Random(42);
  for (var i = 0; i < 5000; i++) {
    final digits = random.nextInt(9);
    final value = (random.nextDouble() - 0.5) * 2e6;
    final text = round(value, digits).toString();
    expect(text.split('.').last.length, lessThanOrEqualTo(max(digits, 1)),
        reason: 'round($value, $digits) = $text');
  }
  for (var i = 0; i < 5000; i++) {
    final digits = -random.nextInt(6) - 1;
    final value = (random.nextDouble() - 0.5) * 2e8;
    final result = round(value, digits);
    expect(result % pow(10, -digits), equals(0),
        reason: 'round($value, $digits) = $result');
    expect((result - value).abs(), lessThanOrEqualTo(pow(10, -digits) / 2));
  }
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

void _sumTest() {
  expect(Iterable.generate(0, (i) => i).sum(), equals(0));
  expect(Iterable.generate(1, (i) => 1).sum(), equals(1));
  expect(Iterable.generate(10, (i) => i).sum(), equals(45));
  expect(Iterable.generate(10, (i) => i * 0.5).sum(), equals(22.5));
}

void _avgTest() {
  expect(Iterable.generate(0, (i) => i).avg(), equals(0));
  expect(Iterable.generate(1, (i) => 1).avg(), equals(1));
  expect(Iterable.generate(11, (i) => i).avg(), equals(5));
  expect(Iterable.generate(11, (i) => i * 0.5).avg(), equals(2.5));
}
