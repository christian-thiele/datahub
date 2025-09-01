import 'package:datahub_aperture_frontend/widgets/form_fields/date_time_form_field.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:flutter/material.dart';

class ResourceTimestampFormField extends StatelessWidget {
  final ResourceField field;
  final String? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<String>? onChanged;

  const ResourceTimestampFormField({
    super.key,
    required this.field,
    required this.value,
    this.error,
    this.isChanged = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DateTimeFormField(
      decoration: InputDecoration(
        errorText: error,
        labelText: isChanged ? '${field.name} *' : field.name,
        labelStyle: TextStyle(fontWeight: isChanged ? FontWeight.bold : null),
      ),
      value: value != null ? DateTime.tryParse(value!) : null,
      onChanged: onChanged != null
          ? (date) => onChanged?.call(date.toIso8601String())
          : null,
    );
  }
}
