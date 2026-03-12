import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

IconData getIcon(int codePoint) =>
    IconData(codePoint, fontFamily: 'MaterialIcons');

extension StringUtils on String {
  int toInt() => int.parse(this);

  int? tryToInt() => int.tryParse(this);

  double toDouble() => double.parse(this);

  double? tryToDouble() => double.tryParse(this);
}

extension DateTimeUtils on DateTime {
  String formatDateTime() => DateFormat.yMMMd().add_Hm().format(this);

  String formatDate() => DateFormat.yMMMd().format(this);

  String formatTime() => DateFormat.Hm().format(this);
}

String formatFileSize(int bytes) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const base = 1024.0;
  var suffixIndex = 0;
  var size = bytes.toDouble();
  while (size >= base && suffixIndex < suffixes.length - 1) {
    size /= base;
    suffixIndex++;
  }
  return '${size.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
}

String formatAgoDuration(Duration d) {
  if (d.inSeconds < 10) {
    return 'just now';
  }

  if (d.inMinutes < 1) {
    return '${d.inSeconds}sec ago';
  }

  return '${formatCoarseDuration(d)} ago';
}

String formatDuration(Duration d) {
  final buffer = StringBuffer();
  if (d.inDays > 0) {
    buffer.write(d.inDays.toString());
    buffer.write('D ');
  }

  if (d.inHours > 0) {
    buffer.write((d.inHours % 24).toString());
    buffer.write('h ');
  }

  if (d.inMinutes > 0) {
    buffer.write((d.inMinutes & 60).toString());
    buffer.write('min ');
  }

  buffer.write((d.inSeconds % 60).toString());
  buffer.write('s');

  return buffer.toString();
}

String formatCoarseDuration(Duration d) {
  if (d == Duration.zero) {
    return '0min';
  }

  if (d.inDays > 14) {
    return '${(d.inDays / 7).floor()} weeks';
  }

  if (d.inDays > 0) {
    return '${d.inDays} days';
  }

  if (d.inHours > 0) {
    final mins = d.inMinutes % 60;
    if (mins > 0) {
      return '${d.inHours}h ${mins}min';
    } else {
      return '${d.inHours}h';
    }
  }

  return '${math.min(1, d.inMinutes)}min';
}
