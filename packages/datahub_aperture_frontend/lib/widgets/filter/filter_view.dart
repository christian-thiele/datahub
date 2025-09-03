import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/widgets/filter/text_filter_section.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:flutter/material.dart';

import 'bool_filter_section.dart';
import 'double_filter_section.dart';
import 'int_filter_section.dart';

class FilterView extends StatelessWidget {
  final List<ResourceField> fields;
  final List<FilterModel> filters;
  final void Function(int) onRemove;
  final void Function(FilterModel) onAdd;

  const FilterView({
    super.key,
    required this.fields,
    required this.filters,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 8,
      spacing: 8,
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      children: [
        MenuAnchor(
          alignmentOffset: Offset(0, 8),
          builder: (context, controller, _) => ActionChip(
            label: IconText(
              Icons.filter_alt_outlined,
              'Add Filter',
              iconSize: 16,
            ),
            onPressed: () {
              controller.isOpen ? controller.close() : controller.open();
            },
          ),
          menuChildren: [
            for (final field in fields)
              Builder(
                builder: (context) {
                  return SubmenuButton(
                    alignmentOffset: Offset(8, 0),
                    menuChildren: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: switch (field.type) {
                          ResourceFieldType.int => IntFilterSection(
                            name: field.name,
                            onSubmit: (type, value) {
                              MenuController.maybeOf(context)?.close();
                              onAdd(FilterModel(field, type, value));
                            },
                          ),
                          ResourceFieldType.double => DoubleFilterSection(
                            name: field.name,
                            onSubmit: (type, value) {
                              MenuController.maybeOf(context)?.close();
                              onAdd(FilterModel(field, type, value));
                            },
                          ),
                          ResourceFieldType.bool => BoolFilterSection(
                            name: field.name,
                            onSubmit: (type, value) {
                              MenuController.maybeOf(context)?.close();
                              onAdd(FilterModel(field, type, value));
                            },
                          ),

                          _ => TextFilterSection(
                            name: field.name,
                            onSubmit: (type, value) {
                              MenuController.maybeOf(context)?.close();
                              onAdd(FilterModel(field, type, value));
                            },
                          ),
                        },
                      ),
                    ],
                    child: Text(field.name),
                  );
                },
              ),
          ],
        ),

        for (final (idx, filter) in filters.indexed)
          RawChip(
            label: Text(filterDescription(filter)),
            onDeleted: () => onRemove(idx),
          ),

        /*
        for (final field in filter.fields)
          OverlayButton(
            childBuilder: (context, toggle) => RawChip(
              padding: EdgeInsets.fromLTRB(4, 4, 0, 4),
              onDeleted: filter.values.containsKey(field) ? onRemove() : null,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text(
                    filter.values.containsKey(field)
                        ? '${field.name}: ${filter.values[field]}'
                        : field.name,
                  ),
                  if (!filter.values.containsKey(field))
                    Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
              onPressed: toggle,
            ),
            overlayBuilder: (_, toggle) => SizedBox(
              width: 256,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: filter?.values[field]?.toString(),
                  onFieldSubmitted: (value) {
                    context.read<ResourceCubit>().addFilter(field, value);
                    toggle();
                  },
                ),
              ),
            ),
          ),*/
      ],
    );
  }
}
