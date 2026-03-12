import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogLine extends StatelessWidget {
  final String line;

  const LogLine({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    Map<String, String> data = {};
    String? message;
    SeverityLevel? severityLevel;
    DateTime? timestamp;
    Map<String, dynamic>? decoded;

    try {
      decoded = jsonDecode(line);
    } catch (_) {}

    if (decoded != null) {
      try {
        data = decoded.map((k, v) => MapEntry(k, v.toString()));
        severityLevel = findEnum(
          decoded['severity'],
          SeverityLevel.values,
          ignoreCase: true,
        );
        message = decoded['msg']?.toString() ?? '';
        timestamp = DateTime.parse(decoded['timestamp']);
      } catch (e) {
        // ignore
      }
    }

    message ??= line;

    return DefaultTextStyle.merge(
      style: GoogleFonts.jetBrainsMono(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        spacing: 4,
        children: [
          if (timestamp != null)
            Text.rich(TextSpan(text: '${timestamp.formatDateTime()} ')),
          if (severityLevel != null)
            Text.rich(
              TextSpan(
                text: severityLevel.name.padRight(8, ' ').toUpperCase(),
                style: TextStyle(
                  color: switch (severityLevel) {
                    SeverityLevel.error || SeverityLevel.fatal => Theme.of(
                      context,
                    ).colorScheme.error,
                    SeverityLevel.warning => Colors.orange,
                    SeverityLevel.info => Colors.blue,
                    SeverityLevel.trace => Colors.green,
                    SeverityLevel.debug => Colors.green,
                  },
                ),
              ),
            ),
          Expanded(child: Text.rich(TextSpan(text: message))),
        ],
      ),
    );
  }
}
