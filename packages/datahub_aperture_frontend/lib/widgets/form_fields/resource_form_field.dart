import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:flutter/material.dart';

import 'resource_bool_form_field.dart';
import 'resource_double_form_field.dart';
import 'resource_geometry_form_field.dart';
import 'resource_int_form_field.dart';
import 'resource_text_form_field.dart';
import 'resource_file_form_field.dart';
import 'resource_timestamp_form_field.dart';

class ResourceFormField extends StatelessWidget {
  final ResourceField field;
  final String? error;
  final dynamic value;
  final bool isChanged;
  final ValueChanged<dynamic>? onChanged;

  const ResourceFormField({
    super.key,
    required this.field,
    this.value,
    this.error,
    required this.isChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return switch (field.type) {
      ResourceFieldType.text => ResourceTextFormField(
        field: field,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.int => ResourceIntFormField(
        field: field,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.bool => ResourceBoolFormField(
        field: field,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.double => ResourceDoubleFormField(
        field: field,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.timestamp => ResourceTimestampFormField(
        field: field,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.geometry => ResourceGeometryFormField(
        field: field,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
      ResourceFieldType.file => ResourceFileFormField(
        field: field,
        value: value,
        isChanged: isChanged,
        onChanged: onChanged,
        error: error,
      ),
    };
  }
}
