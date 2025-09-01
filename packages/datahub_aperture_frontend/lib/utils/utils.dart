import 'package:flutter/widgets.dart';

IconData getIcon(int codePoint) =>
    IconData(codePoint, fontFamily: 'MaterialIcons');

extension StringUtils on String {
  int toInt() => int.parse(this);

  int? tryToInt() => int.tryParse(this);

  double toDouble() => double.parse(this);

  double? tryToDouble() => double.tryParse(this);
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
