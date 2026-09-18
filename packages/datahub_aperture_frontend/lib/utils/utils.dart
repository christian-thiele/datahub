import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

IconData getIcon(int codePoint) =>
    // ignore: non_const_argument_for_const_parameter
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
    buffer.write((d.inMinutes % 60).toString());
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

bool looksLikeSvg(Uint8List bytes) {
  // Peek at the first ~512 bytes and look for "<svg"
  final head = bytes.sublist(0, bytes.length.clamp(0, 512));
  final s = utf8.decode(head, allowMalformed: true).toLowerCase().trimLeft();
  return s.startsWith('<svg') || (s.startsWith('<?xml') && s.contains('<svg'));
}
