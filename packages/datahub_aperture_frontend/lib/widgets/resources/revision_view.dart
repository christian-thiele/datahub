import 'package:datahub_aperture_frontend/blocs/resource_element/resource_element_edit_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/data/entity_list_view.dart';
import 'package:datahub_aperture_frontend/widgets/data/user_entity_view.dart';
import 'package:datahub_aperture_frontend/widgets/data/value_view.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RevisionView extends StatelessWidget {
  final String currentId;
  final List<ResourceRevisionInfo> revisions;

  const RevisionView({
    super.key,
    required this.revisions,
    required this.currentId,
  });

  @override
  Widget build(BuildContext context) {
    final revision = revisions.where((e) => e.id == currentId).firstOrNull;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (revision != null) ...[
          Text(
            S.of(context).revisionInfo,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (revision.live == null) Chip(label: Text(S.of(context).draft)),
          if (revision.live?.isAfter(DateTime.now()) ?? false)
            Chip(label: Text('Scheduled')),

          ValueView(label: S.of(context).revisionId, value: Text(revision.id)),
          ValueView(
            label: S.of(context).timestamp,
            value: Text(DateFormat.yMMMd().add_Hm().format(revision.timestamp)),
          ),
          if (revision.live != null)
            ValueView(
              label: revision.live!.isBefore(DateTime.timestamp())
                  ? S.of(context).liveSince
                  : S.of(context).liveFrom,
              value: Text(DateFormat.yMMMd().add_Hm().format(revision.live!)),
            ),
          ValueView(
            label: S.of(context).author,
            value: UserEntityView(id: revision.userId, name: revision.userName),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () =>
                context.read<ResourceElementEditCubit>().revertToRevision(
                      revision.id,
                    ),
            child: IconText(Icons.history, S.of(context).revert),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            S.of(context).revisionHistory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 256,
          child: EntityListView(
            entryBuilder: (context, index) {
              final revision = revisions[index];
              return EntityListEntry(
                onPressed: () => context.go('./?revision=${revision.id}'),
                icon: Icon(Icons.edit_outlined),
                label: DateFormat.yMMMd().add_Hm().format(revision.timestamp),
                subLabel: S.of(context).byUsername(revision.userName),
              );
            },
            itemCount: revisions.length,
          ),
        ),
      ],
    );
  }
}
