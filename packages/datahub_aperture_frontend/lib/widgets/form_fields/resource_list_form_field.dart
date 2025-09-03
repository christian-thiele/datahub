import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/utils/immutable_list_utils.dart';
import 'package:flutter/material.dart';

import 'group_decoration.dart';
import 'resource_form_field.dart';

class ResourceListFormField extends StatelessWidget {
  final ResourceField field;
  final InputDecoration decoration;
  final List<dynamic>? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<List<dynamic>?>? onChanged;

  const ResourceListFormField({
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
    // TODO error handling
    final elementField = field.objectDescription!.firstWhere(
      (e) => e.id == 'element',
    );
    final entries = value ?? [];

    return GroupDecoration(
      decoration: decoration,
      onAddPressed: () => onChanged?.call(entries.copyWithAdded(null)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (entries.isEmpty) Text(S.of(context).noElements),

          for (final (index, entry) in entries.indexed)
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Expanded(
                  child: ResourceFormField(
                    field: elementField,
                    isChanged: false,
                    value: entry,
                    onChanged: onChanged != null
                        ? (v) => onChanged?.call(
                            entries.copyWithReplaced(index, v),
                          )
                        : null,
                  ),
                ),
                if (onChanged != null)
                  IconButton(
                    onPressed: () =>
                        onChanged?.call(entries.copyWithRemoved(index)),
                    icon: Icon(Icons.delete_outline),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
