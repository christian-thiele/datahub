import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/data/entity_list_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResourceList extends StatelessWidget {
  final ResourceDescription resource;
  final List<ResourceData> entries;
  final bool shrinkWrap;

  const ResourceList({
    super.key,
    required this.resource,
    required this.entries,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return EntityListView(
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
  }
}
