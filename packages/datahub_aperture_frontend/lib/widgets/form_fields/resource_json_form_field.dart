import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/widgets/json_editor/json_editor.dart';
import 'package:flutter/material.dart';

class ResourceJsonFormField extends StatelessWidget {
  final ResourceField field;
  final InputDecoration decoration;
  final dynamic value;
  final String? error;
  final bool isChanged;
  final ValueChanged<dynamic>? onChanged;

  const ResourceJsonFormField({
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
    return JsonEditor(
      value: value,
      root: field.jsonRoot,
      decoration: decoration,
      onChanged: onChanged,
    );
  }
}
