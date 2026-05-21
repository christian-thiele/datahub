import 'dart:math';

import 'package:datahub_aperture_frontend/widgets/data/empty_list_view.dart';
import 'package:flutter/material.dart';

class EntityListView extends StatelessWidget {
  final EntityListEntry Function(BuildContext context, int index) entryBuilder;
  final int itemCount;
  final bool shrinkWrap;
  final Widget empty;

  const EntityListView({
    super.key,
    required this.entryBuilder,
    required this.itemCount,
    this.empty = const EmptyListView(),
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        if (itemCount > 0) {
          return entryBuilder(context, index);
        }

        return empty;
      },
      itemCount: max(1, itemCount),
      separatorBuilder: (context, _) => Divider(height: 0),
      shrinkWrap: shrinkWrap,
      clipBehavior: Clip.antiAlias,
    );
  }
}

class EntityListEntry extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final String? subLabel;

  const EntityListEntry({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: [
            IconTheme.merge(child: icon, data: IconThemeData(size: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subLabel case final subLabel?)
                    Text(
                      subLabel,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  Text(label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
