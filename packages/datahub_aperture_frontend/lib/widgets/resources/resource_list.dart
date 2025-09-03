import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/resource/resource_cubit.dart';
import 'package:datahub_aperture_frontend/models/view_models/paging.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/data/entity_list_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResourceList extends StatelessWidget {
  final ResourceDescription resource;
  final List<ResourceData> entries;
  final Paging? paging;
  final bool shrinkWrap;
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
  });

  @override
  Widget build(BuildContext context) {
    final listView = EntityListView(
      shrinkWrap: shrinkWrap,
      entryBuilder: (context, index) {
        final item = entries[index];
        return EntityListEntry(
          onPressed: () => context.go(
            '/resources/${Uri.encodeComponent(resource.id)}/view/${Uri.encodeComponent(item.id)}',
          ),
          icon: Icon(getIcon(resource.icon)),
          label: resource.displayField != null
              ? item.fieldData[resource.displayField].toString()
              : item.id,
          subLabel: resource.displayField != null ? item.id : null,
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
