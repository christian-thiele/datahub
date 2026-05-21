import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogLine extends StatefulWidget {
  final String line;

  const LogLine({super.key, required this.line});

  @override
  State<LogLine> createState() => _LogLineState();
}

class _LogLineState extends State<LogLine> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Map<String, String> data = {};
    String? message;
    SeverityLevel? severityLevel;
    DateTime? timestamp;
    Map<String, dynamic>? decoded;

    try {
      decoded = jsonDecode(widget.line);
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
        timestamp = DateTime.tryParse(decoded['timestamp']?.toString() ?? '');
      } catch (e) {
        // ignore
      }
    }

    message ??= widget.line;

    return InkWell(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
        FocusScope.of(context).unfocus();
      },
      child: DefaultTextStyle.merge(
        style: GoogleFonts.jetBrainsMono(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                          SeverityLevel.error || SeverityLevel.fatal =>
                            Theme.of(context).colorScheme.error,
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
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries
                      .where(
                        (e) =>
                            !['msg', 'severity', 'timestamp'].contains(e.key),
                      )
                      .map(
                        (e) => Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${e.key}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: e.value),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
