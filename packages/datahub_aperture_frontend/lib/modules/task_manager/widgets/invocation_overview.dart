import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'duration_card.dart';
import 'log_line.dart';

class InvocationOverview extends StatelessWidget {
  final TaskModel task;

  const InvocationOverview({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 8,
          children: [
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scheduled',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      task.scheduledAt.formatDateTime() ?? '-',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Started',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      task.startedAt?.formatDateTime() ?? '-',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            DurationCard(task: task),
          ],
        ),
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'invocationId: ',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontFamily:
                                  GoogleFonts.jetBrainsMono().fontFamily,
                            ),
                      ),
                      TextSpan(
                        text: task.invocationId.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final property in task.parameters.entries)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${property.key}: ',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontFamily:
                                    GoogleFonts.jetBrainsMono().fontFamily,
                              ),
                        ),
                        TextSpan(
                          text: property.value.toString(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontFamily:
                                    GoogleFonts.jetBrainsMono().fontFamily,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Card.outlined(
            child: SelectionArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) =>
                    LogLine(line: task.messages[index]),
                itemCount: task.messages.length,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
