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
        BreakpointLayout(
          breakPoint: 1024,
          spacing: 12,
          layoutSpacing: 24,
          children: [
            for (final field in fields)
              LayoutItem(
                preferSide:
                    field.type == ResourceFieldType.geometry ||
                    field.type == ResourceFieldType.list,
                child: ResourceFormField(
                  field: field,
                  value: changes.containsKey(field)
                      ? changes[field]
                      : data.fieldData[field.id],
                  error: validations[field],
                  isChanged: changes.containsKey(field),
                  onChanged: field.readOnly
                      ? null
                      : (value) => onFieldValueChanged(field, value),
                ),
              ),
          ],
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
                    builder: (context) =>
                        ScheduleDialog(title: S.of(context).scheduleRevision),
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

class LayoutItem extends StatelessWidget {
  final bool preferSide;
  final Widget child;

  const LayoutItem({super.key, required this.child, this.preferSide = false});

  @override
  Widget build(BuildContext context) => child;
}

class BreakpointLayout extends StatelessWidget {
  final double breakPoint;
  final double spacing;
  final double layoutSpacing;

  final List<LayoutItem> children;

  const BreakpointLayout({
    super.key,
    required this.breakPoint,
    this.spacing = 0,
    this.layoutSpacing = 0,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > breakPoint) {
          late final Iterable<LayoutItem> left;
          late final Iterable<LayoutItem> right;

          if (children.any((e) => e.preferSide)) {
            left = children.where((e) => !e.preferSide);
            right = children.where((e) => e.preferSide);
          } else {
            left = children.take(children.length ~/ 2);
            right = children.skip(children.length ~/ 2);
          }

          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: layoutSpacing,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: spacing,
                  children: [for (final item in left) item],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: spacing,
                  children: [for (final item in right) item],
                ),
              ),
            ],
          );
        } else {
          return Column(
            spacing: spacing,
            children: [for (final item in children) item],
          );
        }
      },
    );
  }
}
