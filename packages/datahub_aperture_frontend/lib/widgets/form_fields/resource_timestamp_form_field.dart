import 'package:datahub/data.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/date_time_form_field.dart';
import 'package:flutter/material.dart';

class ResourceTimestampFormField extends StatelessWidget {
  final InputDecoration decoration;
  final dynamic value;
  final String? error;
  final bool isChanged;
  final ValueChanged<DateTime>? onChanged;

  const ResourceTimestampFormField({
    super.key,
    required this.decoration,
    required this.value,
    this.error,
    this.isChanged = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DateTimeFormField(
      decoration: decoration,
      value: JsonDataCodec().decodeDateTime(value),
      onChanged: onChanged,
    );
  }
}
