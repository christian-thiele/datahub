import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:flutter/material.dart';

import 'resource_form_field.dart';

class ResourceEnumFormField extends StatelessWidget {
  final ResourceField field;
  final InputDecoration decoration;
  final String? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<String?>? onChanged;

  const ResourceEnumFormField({
    super.key,
    required this.field,
    required this.decoration,
    this.value,
    this.error,
    required this.isChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: decoration,
      initialValue: value,
      items: [
        for (final value in field.enumValues ?? [])
          DropdownMenuItem<String>(child: Text(value), value: value),
      ],
      onChanged: onChanged != null ? (value) => onChanged?.call(value) : null,
    );
  }
}
