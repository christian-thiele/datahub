import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/data/entity_list_view.dart';
import 'package:datahub_aperture_frontend/widgets/data/user_entity_view.dart';
import 'package:datahub_aperture_frontend/widgets/data/value_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RevisionView extends StatelessWidget {
  final int currentVersion;
  final List<ResourceRevisionInfo> revisions;

  const RevisionView({
    super.key,
    required this.revisions,
    required this.currentVersion,
  });

  @override
  Widget build(BuildContext context) {
    final revision = revisions
        .where((e) => e.version == currentVersion)
        .firstOrNull;

    final now = DateTime.timestamp();
    final liveRevisionVersion = revisions
        .where((e) => e.live != null && !e.live!.isAfter(now))
        .map((e) => e.version)
        .fold<int?>(null, (max, v) => max == null || v > max ? v : max);

    final latestVersion = revisions
        .map((e) => e.version)
        .fold<int?>(null, (max, v) => max == null || v > max ? v : max);

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (revision != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _RevisionStatusCard(
              revision: revision,
              isCurrentLive: revision.version == liveRevisionVersion,
            ),
          ),
          _RevisionDetails(
            revision: revision,
            isLatest: revision.version == latestVersion,
          ),
          const Divider(height: 32),
        ],
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            S.of(context).revisionHistory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: EntityListView(
            entryBuilder: (context, index) {
              final item = revisions[index];
              final isCurrent = item.version == currentVersion;

              final isItemLive = item.version == liveRevisionVersion;
              final isItemScheduled =
                  item.live?.isAfter(DateTime.now()) ?? false;

              final IconData icon;
              final Color? iconColor;

              if (isCurrent) {
                icon = Icons.radio_button_checked;
                iconColor = Theme.of(context).colorScheme.primary;
              } else if (isItemLive) {
                icon = Icons.check_circle_outline;
                iconColor = Theme.of(context).colorScheme.primary;
              } else if (isItemScheduled) {
                icon = Icons.schedule;
                iconColor = Theme.of(context).colorScheme.tertiary;
              } else {
                icon = Icons.history;
                iconColor = null;
              }

              return EntityListEntry(
                onPressed: () => context.go('./?version=${item.version}'),
                icon: Icon(icon, color: iconColor),
                label: DateFormat.yMMMd().add_Hm().format(item.timestamp),
                subLabel: S.of(context).byUsername(item.userName),
              );
            },
            itemCount: revisions.length,
          ),
        ),
      ],
    );
  }
}

class _RevisionStatusCard extends StatelessWidget {
  final ResourceRevisionInfo revision;
  final bool isCurrentLive;

  const _RevisionStatusCard({
    required this.revision,
    required this.isCurrentLive,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = revision.live == null;
    final isScheduled = revision.live?.isAfter(DateTime.now()) ?? false;
    final isOutdated = !isDraft && !isScheduled && !isCurrentLive;

    final colorScheme = Theme.of(context).colorScheme;

    final String label;
    final IconData icon;
    final Color color;

    if (isDraft) {
      label = S.of(context).draft;
      icon = Icons.edit_note;
      color = colorScheme.secondary;
    } else if (isScheduled) {
      label = 'Scheduled';
      icon = Icons.schedule;
      color = colorScheme.tertiary;
    } else if (isOutdated) {
      label = 'Outdated';
      icon = Icons.history;
      color = colorScheme.outline;
    } else {
      label = 'Live';
      icon = Icons.check_circle_outline;
      color = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevisionDetails extends StatelessWidget {
  final ResourceRevisionInfo revision;
  final bool isLatest;

  const _RevisionDetails({required this.revision, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        ValueView(
          label: S.of(context).revisionVersion,
          value: Text(
            revision.version.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
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
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: !isLatest
                ? () => context.go('./?revertFrom=${revision.version}')
                : null,
            icon: const Icon(Icons.history, size: 18),
            label: Text(S.of(context).revert),
          ),
        ),
      ],
    );
  }
}
