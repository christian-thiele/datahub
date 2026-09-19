import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/date_time_form_field.dart';
import 'package:flutter/material.dart';

import 'aperture_dialog.dart';

class ScheduleDialog extends StatefulWidget {
  final String title;

  const ScheduleDialog({super.key, required this.title});

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();

  static Future<void> show(
    BuildContext context, {
    required String text,
    required void Function(DateTime) onSavePressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) =>
          ScheduleDialog(title: S.of(context).scheduleRevision),
    ).then((result) {
      if (result case DateTime liveDate) {
        onSavePressed.call(liveDate);
      }
    });
  }
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  DateTime value = DateTime.timestamp();

  @override
  Widget build(BuildContext context) {
    return ApertureDialog(
      title: widget.title,
      icon: Icons.schedule,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, value),
          child: Text(S.of(context).saveAndSchedule),
        ),
      ],
      child: DateTimeFormField(
        decoration: InputDecoration(prefixIcon: Icon(Icons.calendar_month)),
        value: value,
        onChanged: (value) {
          setState(() {
            this.value = value;
          });
        },
      ),
    );
  }
}
