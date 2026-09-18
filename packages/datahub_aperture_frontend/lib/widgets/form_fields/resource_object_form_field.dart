import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:flutter/material.dart';

import 'group_decoration.dart';
import 'resource_form_field.dart';

class ResourceObjectFormField extends StatelessWidget {
  final ResourceField field;
  final InputDecoration decoration;
  final dynamic value;
  final String path;
  final Map<String, String> errors;
  final bool isChanged;
  final ValueChanged<dynamic>? onChanged;

  const ResourceObjectFormField({
    super.key,
    required this.field,
    required this.decoration,
    this.value,
    required this.path,
    this.errors = const {},
    required this.isChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GroupDecoration(
      decoration: decoration,
      hasNestedErrors: hasNestedErrors(errors, path),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (field.objectDescription?.isEmpty ?? true) Text('No Attributes'),

          for (final field in field.objectDescription!)
            ResourceFormField(
              field: field,
              path: memberPath(path, field.id),
              errors: errors,
              isChanged: false,
              value: value?[field.id],
              onChanged: onChanged != null
                  ? (v) {
                      final updated = Map<String, dynamic>.from(
                        value ?? <String, dynamic>{},
                      );
                      updated[field.id] = v;
                      onChanged?.call(updated);
                    }
                  : null,
            ),
        ],
      ),
    );
  }
}
