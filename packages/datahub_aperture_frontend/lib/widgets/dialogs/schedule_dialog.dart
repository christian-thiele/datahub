import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/date_time_form_field.dart';
import 'package:flutter/material.dart';

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
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: SizedBox(
          width: 256 + 128,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              DateTimeFormField(
                decoration: InputDecoration(icon: Icon(Icons.calendar_month)),
                value: value,
                onChanged: (value) {
                  setState(() {
                    this.value = value;
                  });
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, value),
                  child: Text(S.of(context).saveAndSchedule),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
