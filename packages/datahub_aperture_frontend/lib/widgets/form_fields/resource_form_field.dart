import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_type_restriction.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:flutter/material.dart';

import 'resource_bool_form_field.dart';
import 'resource_double_form_field.dart';
import 'resource_enum_form_field.dart';
import 'resource_file_form_field.dart';
import 'resource_geometry_form_field.dart';
import 'resource_int_form_field.dart';
import 'resource_list_form_field.dart';
import 'resource_object_form_field.dart';
import 'resource_text_form_field.dart';
import 'resource_timestamp_form_field.dart';

class ResourceFormField extends StatelessWidget {
  final ResourceField field;
  final String? error;
  final dynamic value;
  final bool isChanged;
  final ValueChanged? onChanged;

  const ResourceFormField({
    super.key,
    required this.field,
    this.value,
    this.error,
    this.isChanged = false,
    this.onChanged,
  });

  InputDecoration decoration(BuildContext context) {
    final Widget? label;
    if (field.name.isNotEmpty) {
      if (isChanged) {
        label = IconText(
          Icons.circle_sharp,
          field.name,
          iconSize: 6,
          leading: false,
          iconColor: Theme.of(context).colorScheme.primary,
        );
      } else {
        label = Text(field.name);
      }
    } else {
      label = null;
    }

    return InputDecoration(
      errorText: error,
      label: label,
      labelStyle: TextStyle(fontWeight: isChanged ? FontWeight.bold : null),
      enabledBorder: switch ((field.readOnly, isChanged)) {
        (true, _) => OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        (false, true) => OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        _ => null,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldDecoration = decoration(context);
    return switch (field.type) {
      ResourceFieldType.string => ResourceTextFormField(
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
        lookup: field.lookup,
      ),
      ResourceFieldType.int => ResourceIntFormField(
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
        lookup: field.lookup,
      ),
      ResourceFieldType.bool => ResourceBoolFormField(
        field: field,
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.double => ResourceDoubleFormField(
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.timestamp => ResourceTimestampFormField(
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.stringEnum => ResourceEnumFormField(
        field: field,
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.geometry => ResourceGeometryFormField(
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
        // ResourceField does not describe the accepted geometry types yet, so
        // the editor offers all of them.
        restriction: const GeoTypeRestriction.any(),
      ),
      ResourceFieldType.object => ResourceObjectFormField(
        field: field,
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.list => ResourceListFormField(
        field: field,
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.bytes => ResourceFileFormField(
        decoration: fieldDecoration,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
    };
  }
}
