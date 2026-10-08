import 'dart:convert';

import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// JSON data, formatted.
class JsonText extends StatelessWidget {
  final Object? data;

  const JsonText(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(ApertureThemeData.radiusSmall),
      ),
      child: SelectableText(
        const JsonEncoder.withIndent('  ').convert(data),
        style: GoogleFonts.jetBrainsMono(fontSize: 12, height: 1.5),
      ),
    );
  }
}
