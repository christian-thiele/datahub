import 'dart:typed_data';

import 'package:datahub_aperture_frontend/utils/utils.dart';
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

    if (looksLikeSvg(bytes!)) {
      return SvgPicture.memory(
        bytes!,
        errorBuilder: (context, _, _) => fallback,
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
    }

    return Image.memory(
      bytes!,
      errorBuilder: (context, _, _) => fallback,
      width: width,
      height: height,
    );
  }
}
