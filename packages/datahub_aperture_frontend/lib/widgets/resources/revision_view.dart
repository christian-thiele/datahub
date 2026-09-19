import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/data/entity_list_view.dart';
import 'package:datahub_aperture_frontend/widgets/data/user_entity_view.dart';
import 'package:datahub_aperture_frontend/widgets/data/value_view.dart';
import 'package:datahub_aperture_frontend/widgets/info_badge.dart';
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
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).revisionInfo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _RevisionStatusBadge(
                revision: revision,
                isCurrentLive: revision.version == liveRevisionVersion,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RevisionDetails(
            revision: revision,
            isLatest: revision.version == latestVersion,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(),
          ),
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

              final colors = ApertureColors.of(context);
              final IconData icon;
              final Color? iconColor;

              if (isCurrent) {
                icon = Icons.radio_button_checked;
                iconColor = colors.link;
              } else if (isItemLive) {
                icon = Icons.check_circle_outline;
                iconColor = colors.success;
              } else if (isItemScheduled) {
                icon = Icons.schedule;
                iconColor = colors.warning;
              } else {
                icon = Icons.history;
                iconColor = null;
              }

              return Material(
                color: isCurrent ? colors.accentSubtle : Colors.transparent,
                borderRadius: BorderRadius.circular(ApertureThemeData.radius),
                clipBehavior: Clip.antiAlias,
                child: EntityListEntry(
                  onPressed: () => context.go('./?version=${item.version}'),
                  icon: Icon(icon, color: iconColor),
                  label: DateFormat.yMMMd().add_Hm().format(item.timestamp),
                  subLabel: S.of(context).byUsername(item.userName),
                ),
              );
            },
            itemCount: revisions.length,
            dividers: false,
          ),
        ),
      ],
    );
  }
}

class _RevisionStatusBadge extends StatelessWidget {
  final ResourceRevisionInfo revision;
  final bool isCurrentLive;

  const _RevisionStatusBadge({
    required this.revision,
    required this.isCurrentLive,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = revision.live == null;
    final isScheduled = revision.live?.isAfter(DateTime.now()) ?? false;
    final isOutdated = !isDraft && !isScheduled && !isCurrentLive;

    final colors = ApertureColors.of(context);

    final (label, icon, color, background) = switch (null) {
      _ when isDraft => (
        S.of(context).draft,
        Icons.edit_note,
        colors.link,
        colors.accentSubtle,
      ),
      _ when isScheduled => (
        S.of(context).scheduled,
        Icons.schedule,
        colors.warning,
        colors.warningSubtle,
      ),
      _ when isOutdated => (
        S.of(context).outdated,
        Icons.history,
        colors.textMuted,
        Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      _ => (
        S.of(context).live,
        Icons.check_circle_outline,
        colors.success,
        colors.successSubtle,
      ),
    };

    return StatusPill(
      label: label,
      icon: icon,
      color: color,
      background: background,
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
