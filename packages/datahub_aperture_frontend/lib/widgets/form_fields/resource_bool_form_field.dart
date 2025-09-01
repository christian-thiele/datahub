import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:flutter/material.dart';

class ResourceBoolFormField extends StatelessWidget {
  final ResourceField field;
  final bool? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<bool>? onChanged;

  const ResourceBoolFormField({
    super.key,
    required this.field,
    this.value,
    this.error,
    required this.isChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        errorText: error,
        labelText: isChanged ? '${field.name} *' : field.name,
        labelStyle: TextStyle(fontWeight: isChanged ? FontWeight.bold : null),
        contentPadding: EdgeInsets.all(4)
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Checkbox(
          tristate: false,
          value: value ?? false,
          onChanged: (_) => onChanged?.call(!(value ?? false)),
        ),
      ),
    );
  }
}
