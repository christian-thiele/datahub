import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/filter/search_field.dart';
import 'package:datahub_aperture_frontend/widgets/filter/text_filter_section.dart';
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
      builder: (context, controller, _) => OutlinedButton.icon(
        style: _toolbarButtonStyle,
        icon: Icon(Icons.filter_list, size: 18),
        label: Text('Add Filter'),
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
      builder: (context, controller, _) => OutlinedButton.icon(
        style: _toolbarButtonStyle,
        icon: Icon(
          sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
        ),
        label: Text('Sort by ${sortField?.name}'),
        onPressed: () {
          controller.isOpen ? controller.close() : controller.open();
        },
      ),
      menuChildren: [
        for (final field in sortFields)
          Builder(
            builder: (context) {
              final isSelected = field.id == sortField?.id;
              return MenuItemButton(
                trailingIcon: isSelected
                    ? Icon(
                        sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                        color: ApertureColors.of(context).link,
                      )
                    : null,
                child: Text(field.name),
                onPressed: () =>
                    onSortSelect(field, isSelected ? !sortAscending : true),
              );
            },
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final buttons = [
              filterButton,
              if (sortFields.isNotEmpty) sortButton,
            ];
            final searchField = switch (onSearchSubmit) {
              final onSearchSubmit? => SearchField(
                value: search,
                onSubmit: onSearchSubmit,
              ),
              null => null,
            };

            if (constraints.maxWidth < 560) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  ?searchField,
                  Wrap(spacing: 8, runSpacing: 8, children: buttons),
                ],
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                if (searchField != null)
                  Expanded(child: searchField)
                else
                  Spacer(),
                ...buttons,
              ],
            );
          },
        ),
        if (filters.isNotEmpty)
          Wrap(
            runSpacing: 8,
            spacing: 8,
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            children: [
              for (final (idx, filter) in filters.indexed)
                RawChip(
                  avatar: Icon(Icons.filter_alt_outlined),
                  label: Text(filterDescription(filter)),
                  onDeleted: () => onRemove(idx),
                  deleteIcon: Icon(Icons.close, size: 16),
                ),
            ],
          ),
      ],
    );
  }

  static final _toolbarButtonStyle = OutlinedButton.styleFrom(
    minimumSize: Size(0, 40),
    padding: EdgeInsets.symmetric(horizontal: 14),
  );
}
