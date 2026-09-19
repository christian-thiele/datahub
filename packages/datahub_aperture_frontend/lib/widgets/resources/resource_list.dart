import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/models/view_models/paging.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/data/entity_list_view.dart';
import 'package:datahub_aperture_frontend/widgets/page_header.dart';
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

    return Card(
      child: Column(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (shrinkWrap) listView else Expanded(child: listView),
          if (paging case final paging?) ...[
            const Divider(),
            PagingBar(
              paging: paging,
              onFirstPressed: onFirstPressed,
              onPreviousPressed: onPreviousPressed,
              onNextPressed: onNextPressed,
              onLastPressed: onLastPressed,
            ),
          ],
        ],
      ),
    );
  }
}

class PagingBar extends StatelessWidget {
  final Paging paging;
  final VoidCallback? onFirstPressed;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;
  final VoidCallback? onLastPressed;

  const PagingBar({
    super.key,
    required this.paging,
    this.onFirstPressed,
    this.onPreviousPressed,
    this.onNextPressed,
    this.onLastPressed,
  });

  @override
  Widget build(BuildContext context) {
    final from = paging.length > 0 ? paging.offset + 1 : paging.offset;
    final to = paging.offset + paging.length;
    final label = switch (paging.total) {
      final total? => S.of(context).pageOf(from, to, total),
      null => S.of(context).pageFrom(from, to),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        spacing: 2,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Spacer(),
          IconButton(
            onPressed: paging.offset > 0 ? onFirstPressed : null,
            icon: Icon(Icons.first_page),
          ),
          IconButton(
            onPressed: paging.offset > 0 ? onPreviousPressed : null,
            icon: Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: paging.hasMore ? onNextPressed : null,
            icon: Icon(Icons.chevron_right),
          ),
          IconButton(
            onPressed: paging.hasMore ? onLastPressed : null,
            icon: Icon(Icons.last_page),
          ),
        ],
      ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 14,
          children: [
            IconTile(getIcon(resource.icon), size: 34),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 2,
                children: [
                  Text(
                    getElementTitle(resource, element),
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (fields.isNotEmpty)
                    Wrap(
                      spacing: 16,
                      runSpacing: 2,
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
            Icon(
              Icons.chevron_right,
              size: 18,
              color: ApertureColors.of(context).textMuted,
            ),
          ],
        ),
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
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$fieldName ',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
