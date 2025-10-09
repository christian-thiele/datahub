import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:flutter/material.dart';

class ResourceBoolFormField extends StatelessWidget {
  final ResourceField field;
  final InputDecoration decoration;
  final bool? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<bool?>? onChanged;

  const ResourceBoolFormField({
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
    return InputDecorator(
      decoration: decoration.copyWith(contentPadding: EdgeInsets.all(4)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Checkbox(
          tristate: value == null || field.nullable,
          value: value,
          onChanged: (v) => onChanged?.call(v),
        ),
      ),
    );
  }
}
