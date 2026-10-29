import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/date_time_formatter.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/schedule_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:datahub_aperture_frontend/widgets/options_button.dart';
import 'package:flutter/material.dart';

import 'field_menu.dart';
import 'resource_form_field.dart';

class ResourceFieldForm extends StatelessWidget {
  final List<ResourceField> fields;

  /// The values the fields have without [changes], which a field can be
  /// reset to with [onFieldReset].
  final ResourceData data;
  final Map<ResourceField, dynamic> changes;
  final Map<String, String> validations;
  final void Function(ResourceField field, dynamic value) onFieldValueChanged;
  final void Function(ResourceField field)? onFieldReset;
  final void Function(DateTime? from)? onSavePressed;
  final bool revisable;
  final bool readOnly;

  const ResourceFieldForm({
    super.key,
    required this.fields,
    required this.data,
    required this.changes,
    required this.validations,
    required this.onFieldValueChanged,
    this.onFieldReset,
    required this.onSavePressed,
    this.revisable = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        BreakpointLayout(
          breakPoint: 960,
          spacing: 16,
          layoutSpacing: 24,
          children: [
            for (final field in fields)
              LayoutItem(
                preferSide: switch (field.type) {
                  ResourceFieldType.geometry ||
                  ResourceFieldType.list ||
                  ResourceFieldType.jsonMap ||
                  ResourceFieldType.jsonList => true,
                  _ => false,
                },
                child: _buildField(context, field),
              ),
          ],
        ),
        if (!readOnly)
          Align(
            alignment: Alignment.bottomRight,
            child: OptionsButton(
              onPressed: switch (onSavePressed) {
                final call? => () => call(null),
                _ => null,
              },
              menuEnabled: revisable && onSavePressed != null,
              menuChildren: [
                if (revisable) ...[
                  /*MenuItemButton(
                  child: IconText(
                    Icons.edit_note_outlined,
                    S.of(context).saveAsDraft,
                  ),
                  onPressed: () => onSavePressed?.call(null),
                ),*/
                  MenuItemButton(
                    leadingIcon: Icon(Icons.schedule),
                    child: Text(S.of(context).saveAndSchedule),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ScheduleDialog(
                          title: S.of(context).scheduleRevision,
                        ),
                      ).then((result) {
                        if (result case DateTime liveDate) {
                          onSavePressed?.call(liveDate);
                        }
                      });
                    },
                  ),
                ],
              ],
              child: IconText(Icons.check, S.of(context).save),
            ),
          ),
      ],
    );
  }

  Widget _buildField(BuildContext context, ResourceField field) {
    final s = S.of(context);
    final value = changes.containsKey(field)
        ? changes[field]
        : data.fieldData[field.id];
    final isChanged =
        changes.containsKey(field) &&
        !fieldValueEquals(changes[field], data.fieldData[field.id]);
    final editable = !field.readOnly && !readOnly;

    return FieldMenu(
      menuChildren: readOnly
          ? null
          : [
              if (editable && onFieldReset != null)
                MenuItemButton(
                  leadingIcon: const Icon(Icons.undo),
                  onPressed: isChanged ? () => onFieldReset!(field) : null,
                  child: Text(s.resetFieldValue),
                ),
              if (editable && field.type == ResourceFieldType.timestamp)
                MenuItemButton(
                  leadingIcon: const Icon(Icons.schedule),
                  onPressed: () => onFieldValueChanged(
                    field,
                    DateTimeFormatter.current.now(),
                  ),
                  child: Text(s.setFieldToNow),
                ),
              if (editable && field.nullable)
                MenuItemButton(
                  leadingIcon: const Icon(Icons.block),
                  onPressed: value != null
                      ? () => onFieldValueChanged(field, null)
                      : null,
                  child: Text(s.setFieldToNull),
                ),
            ],
      child: ResourceFormField(
        field: field,
        path: field.id,
        errors: validations,
        value: value,
        isChanged: isChanged,
        onChanged: editable
            ? (value) => onFieldValueChanged(field, value)
            : null,
      ),
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
