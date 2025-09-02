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
double round<T extends num>(T value, [int digits = 0]) {
  if (value is double && (value.isNaN || value.isInfinite)) {
    return value;
  }

  final p = math.pow(10, 0 - digits);
  return ((value / p).round() * p).toDouble();
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
