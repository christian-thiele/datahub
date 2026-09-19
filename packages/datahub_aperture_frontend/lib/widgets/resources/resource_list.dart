import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/view_models/paging.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/data/entity_list_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResourceList extends StatelessWidget {
  final ResourceDescription resource;
  final List<ResourceData> entries;
  final Paging? paging;
  final bool shrinkWrap;
  final ValueChanged<ResourceData>? onResourceClicked;
  final VoidCallback? onFirstPressed;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;
  final VoidCallback? onLastPressed;

  const ResourceList({
    super.key,
    required this.resource,
    required this.entries,
    this.shrinkWrap = false,
    this.paging,
    this.onFirstPressed,
    this.onPreviousPressed,
    this.onNextPressed,
    this.onLastPressed,
    this.onResourceClicked,
  });

  @override
  Widget build(BuildContext context) {
    final listView = EntityListView(
      shrinkWrap: shrinkWrap,
      entryBuilder: (context, index) {
        final item = entries[index];
        return ResourceListEntry(
          onPressed: switch (onResourceClicked) {
            final callback? => () => callback(item),
            _ => () => context.go(
              '/resources/${Uri.encodeComponent(resource.id)}/view/${Uri.encodeComponent(item.id)}',
            ),
          },
          resource: resource,
          element: item,
        );
      },
      itemCount: entries.length,
    );

    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (shrinkWrap) listView else Expanded(child: listView),
        if (paging case final paging?)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              IconButton(
                onPressed: paging.offset > 0 ? onFirstPressed : null,
                icon: Icon(Icons.skip_previous),
              ),
              IconButton(
                onPressed: paging.offset > 0 ? onPreviousPressed : null,
                icon: Icon(Icons.chevron_left),
              ),
              Text(paging.toString()),
              IconButton(
                onPressed: paging.hasMore ? onNextPressed : null,
                icon: Icon(Icons.chevron_right),
              ),
              IconButton(
                onPressed: paging.hasMore ? onLastPressed : null,
                icon: Icon(Icons.skip_next),
              ),
            ],
          ),
      ],
    );
  }
}

class ResourceListEntry extends StatelessWidget {
  final VoidCallback onPressed;
  final ResourceDescription resource;
  final ResourceData element;

  const ResourceListEntry({
    super.key,
    required this.onPressed,
    required this.resource,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    final fields = resource.displayFields
        .map((id) => resource.fields.singleWhere((e) => e.id == id))
        .toList();

    return InkWell(
      onTap: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: IconTheme.merge(
              child: Icon(getIcon(resource.icon)),
              data: IconThemeData(size: 16),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    getElementTitle(resource, element),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      for (final field in fields)
                        _FieldValue(
                          fieldName: field.name,
                          value: fieldValueToDisplayText(
                            field,
                            element.fieldData[field.id],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldValue extends StatelessWidget {
  final String fieldName;
  final String value;

  const _FieldValue({required this.fieldName, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$fieldName: ', style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
