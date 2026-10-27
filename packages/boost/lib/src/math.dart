import 'dart:math' as math;

import 'package:boost/boost.dart';

/// Rounds to given digit count.
///
/// If [digits] is positive, the number is rounded to the nth digit after the
/// decimal point. If [digits] is negative, the number is rounded to the nth
/// digit in front of the decimal point.
/// Rounds away from zero on n.5:
///  `round(35, -1) == 40` and `round(-35, -1) == -40`
///  `round(1.25, 1) == 1.3` and `round(-1.25, 1) == -1.3`
///
/// Rounding is applied to the decimal representation of [value] (the one
/// printed by `toString()`), so the result never carries floating point noise.
double round<T extends num>(T value, [int digits = 0]) {
  if (value is double && (value.isNaN || value.isInfinite)) {
    return value;
  }

  // Scaling by 10^digits is inexact for one sign of digits (0.01 has no exact
  // binary form) and misjudges ties, so the decimal digits are rounded instead.
  var text = value.toString();
  final negative = text.startsWith('-');
  if (negative) {
    text = text.substring(1);
  }

  // value == int.parse(text) * 10^exponent
  var exponent = 0;
  final e = text.indexOf('e');
  if (e >= 0) {
    exponent = int.parse(text.substring(e + 1));
    text = text.substring(0, e);
  }
  final dot = text.indexOf('.');
  if (dot >= 0) {
    exponent -= text.length - dot - 1;
    text = text.substring(0, dot) + text.substring(dot + 1);
  }

  // toString() pads large values with zeros ("9500000000000000000.0"), which
  // would overflow int.parse; without them a double has at most 17 digits.
  var end = text.length;
  while (end > 0 && text.codeUnitAt(end - 1) == 0x30) {
    end--;
  }
  exponent += text.length - end;
  text = text.substring(0, end);
  if (text.isEmpty) {
    return 0;
  }

  final drop = -exponent - digits;
  if (drop <= 0) {
    return value.toDouble();
  }
  final keep = text.length - drop;
  if (keep < 0) {
    return 0;
  }

  var kept = keep == 0 ? 0 : int.parse(text.substring(0, keep));
  if (text.codeUnitAt(keep) >= 0x35) {
    kept++;
  }
  if (kept == 0) {
    return 0;
  }
  return double.parse('${negative ? '-' : ''}${kept}e${exponent + drop}');
}

/// Clamps a value between a inclusive minimum and inclusive maximum.
///
/// [max] may not be smaller than [min].
T clamp<T extends num>(T value, T min, T max) {
  if (max < min) {
    throw BoostException('Min must be smaller than max!');
  }
  return math.min(max, math.max(min, value));
}

/// Converts degrees to radians.
///
/// 1° × π/180 = 0,01745 rad
double toRadians(num degrees) => degrees * math.pi / 180.0;

/// Converts radians to degrees.
///
/// 1 rad × 180/π = 57,296°
double toDegrees(num radians) => radians * 180.0 / math.pi;

extension IterableMathExtension<TValue extends num> on Iterable<TValue> {
  /// Returns the average value of all elements.
  double avg() {
    if (isEmpty) {
      return 0;
    }
    return map((e) => e.toDouble()).sum() / length;
  }
}

extension IntIterableMathExtension on Iterable<int> {
  /// Returns the sum of all elements.
  int sum() => fold(0, (v, e) => v + e);
}

extension DoubleIterableMathExtension on Iterable<double> {
  /// Returns the sum of all elements.
  double sum() => fold<double>(0.0, (v, e) => v + e);
}
