import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/widgets/filter/search_field.dart';
import 'package:datahub_aperture_frontend/widgets/filter/text_filter_section.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:flutter/material.dart';

import 'bool_filter_section.dart';
import 'double_filter_section.dart';
import 'int_filter_section.dart';

class FilterView extends StatelessWidget {
  final List<ResourceField> filterFields;
  final List<ResourceField> sortFields;
  final List<FilterModel> filters;
  final ResourceField? sortField;
  final bool sortAscending;
  final void Function(int) onRemove;
  final void Function(FilterModel) onAdd;
  final void Function(ResourceField?, bool) onSortSelect;
  final ValueChanged<String>? onSearchSubmit;
  final String search;

  const FilterView({
    super.key,
    required this.filterFields,
    required this.sortFields,
    required this.filters,
    required this.sortField,
    required this.sortAscending,
    required this.onRemove,
    required this.onAdd,
    required this.onSortSelect,
    this.onSearchSubmit,
    this.search = '',
  });

  @override
  Widget build(BuildContext context) {
    final filterButton = MenuAnchor(
      alignmentOffset: Offset(0, 8),
      builder: (context, controller, _) => ActionChip(
        label: IconText(Icons.filter_alt_outlined, 'Add Filter', iconSize: 16),
        onPressed: () {
          controller.isOpen ? controller.close() : controller.open();
        },
      ),
      menuChildren: [
        for (final field in filterFields)
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
    );

    final sortButton = MenuAnchor(
      alignmentOffset: Offset(0, 8),
      builder: (context, controller, _) => ActionChip(
        label: IconText(Icons.sort, 'Sort by ${sortField?.name}', iconSize: 16),
        onPressed: () {
          controller.isOpen ? controller.close() : controller.open();
        },
      ),
      menuChildren: [
        for (final field in sortFields)
          Builder(
            builder: (context) {
              return MenuItemButton(
                child: Text(field.name),
                onPressed: () => onSortSelect(field, true),
              );
            },
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (onSearchSubmit case final onSearchSubmit?)
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              Expanded(
                child: SearchField(value: search, onSubmit: onSearchSubmit),
              ),
            ],
          ),
        Wrap(
          runSpacing: 8,
          spacing: 8,
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          children: [
            filterButton,
            if (sortFields.isNotEmpty) sortButton,

            for (final (idx, filter) in filters.indexed)
              RawChip(
                label: Text(filterDescription(filter)),
                onDeleted: () => onRemove(idx),
              ),
          ],
        ),
      ],
    );
  }
}
