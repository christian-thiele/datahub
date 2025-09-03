import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DynamicMemoryImage extends StatelessWidget {
  final Uint8List? bytes;
  final Widget fallback;
  final double? width;
  final double? height;
  final Color? color;

  const DynamicMemoryImage({
    super.key,
    this.bytes,
    required this.fallback,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (bytes == null) {
      return fallback;
    }

    if (_looksLikeSvg(bytes!)) {
      return SvgPicture.memory(
        bytes!,
        errorBuilder: (context, _, _) => fallback,
        width: width,
        height: height,
        fit: BoxFit.contain,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.color)
            : null,
      );
    }

    return Image.memory(
      bytes!,
      errorBuilder: (context, _, _) => fallback,
      width: width,
      height: height,
      color: color,
    );
  }

  bool _looksLikeSvg(Uint8List bytes) {
    // Peek at the first ~512 bytes and look for "<svg"
    final head = bytes.sublist(0, bytes.length.clamp(0, 512));
    final s = utf8.decode(head, allowMalformed: true).toLowerCase().trimLeft();
    return s.startsWith('<svg') ||
        (s.startsWith('<?xml') && s.contains('<svg'));
  }
}
