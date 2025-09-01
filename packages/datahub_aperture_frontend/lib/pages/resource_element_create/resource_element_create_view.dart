import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_field_form.dart';
import 'package:flutter/material.dart';

class ResourceElementCreateView extends StatelessWidget {
  final List<ResourceField> fields;
  final Map<ResourceField, String> validations;
  final ResourceData data;
  final Map<ResourceField, dynamic> changes;
  final void Function(ResourceField field, dynamic value) onFieldValueChanged;
  final void Function(DateTime?)? onSavePressed;

  const ResourceElementCreateView({
    super.key,
    required this.fields,
    required this.data,
    required this.changes,
    this.validations = const {},
    required this.onFieldValueChanged,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ResourceFieldForm(
        fields: fields,
        data: data,
        changes: changes,
        validations: validations,
        onFieldValueChanged: onFieldValueChanged,
        onSavePressed: onSavePressed,
      ),
    );
  }
}
