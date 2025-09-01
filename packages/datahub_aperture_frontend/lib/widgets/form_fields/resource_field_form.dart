import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/schedule_dialog.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:datahub_aperture_frontend/widgets/options_button.dart';
import 'package:flutter/material.dart';

import 'resource_form_field.dart';

class ResourceFieldForm extends StatelessWidget {
  final List<ResourceField> fields;
  final ResourceData data;
  final Map<ResourceField, dynamic> changes;
  final Map<ResourceField, String> validations;
  final void Function(ResourceField field, dynamic value) onFieldValueChanged;
  final void Function(DateTime? revisionLive)? onSavePressed;

  const ResourceFieldForm({
    super.key,
    required this.fields,
    required this.data,
    required this.changes,
    required this.validations,
    required this.onFieldValueChanged,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        for (final field in fields)
          ResourceFormField(
            field: field,
            value: changes[field] ?? data.fieldData[field.id],
            error: validations[field],
            isChanged: changes.containsKey(field),
            onChanged: field.readOnly
                ? null
                : (value) => onFieldValueChanged(field, value),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: OptionsButton(
            onPressed: switch (onSavePressed) {
              final call? => () => call(DateTime.timestamp()),
              _ => null,
            },
            menuEnabled: onSavePressed != null,
            menuChildren: [
              MenuItemButton(
                child: IconText(
                  Icons.edit_note_outlined,
                  S.of(context).saveAsDraft,
                ),
                onPressed: () => onSavePressed?.call(null),
              ),
              MenuItemButton(
                child: IconText(Icons.schedule, S.of(context).saveAndSchedule),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ScheduleDialog(),
                  ).then((result) {
                    if (result case DateTime liveDate) {
                      onSavePressed?.call(liveDate);
                    }
                  });
                },
              ),
            ],
            child: IconText(Icons.save, S.of(context).save),
          ),
        ),
      ],
    );
  }
}
