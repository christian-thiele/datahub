import 'package:datahub/config.dart';
import 'package:datahub_aperture_frontend/blocs/auth_cubit/auth_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SideBarEntry {
  final IconData icon;
  final String label;
  final String path;

  SideBarEntry({required this.icon, required this.label, required this.path});
}

class SideBarSection {
  final String title;
  final List<SideBarEntry> entries;

  SideBarSection({required this.title, required this.entries});
}

class SideBar extends StatelessWidget {
  /// Width below which the side bar only shows icons.
  static const compactBreakpoint = 960.0;

  final List<SideBarSection> sections;

  final VoidCallback? refreshPressed;

  const SideBar({super.key, required this.sections, this.refreshPressed});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    final location = GoRouter.of(context).state.matchedLocation;
    final compact = MediaQuery.sizeOf(context).width < compactBreakpoint;
    final environment = Bootstrap.of(context).environment;

    bool isSelected(SideBarEntry entry) =>
        location == entry.path || location.startsWith('${entry.path}/');

    return Container(
      width: compact ? 68 : 248,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 72,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20),
              child: Row(
                spacing: 8,
                children: [
                  Flexible(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.go('/'),
                      child: BrandLogo(height: 32, compact: compact),
                    ),
                  ),
                  if (!compact && environment != Environment.prod)
                    _EnvironmentBadge(environment: environment),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final (index, section) in sections.indexed)
                  if (section.entries.isNotEmpty) ...[
                    if (compact)
                      Padding(
                        padding: EdgeInsets.only(
                          top: index == 0 ? 0 : 12,
                          bottom: 12,
                        ),
                        child: index == 0
                            ? const SizedBox.shrink()
                            : const Divider(),
                      )
                    else
                      _SectionHeader(
                        title: section.title,
                        action: index == 0 && refreshPressed != null
                            ? IconButton(
                                onPressed: refreshPressed,
                                icon: const Icon(Icons.refresh, size: 16),
                                tooltip: S.of(context).reloadConfiguration,
                                visualDensity: VisualDensity.compact,
                              )
                            : null,
                      ),
                    for (final entry in section.entries)
                      _SideBarItem(
                        icon: entry.icon,
                        label: entry.label,
                        compact: compact,
                        selected: isSelected(entry),
                        onPressed: () => context.go(entry.path),
                      ),
                  ],
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) => _SideBarItem(
                icon: Icons.logout,
                label: S.of(context).logout,
                compact: compact,
                selected: false,
                onPressed: state is AuthStateAuthorized
                    ? () => context.read<AuthCubit>().logout()
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 6),
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}

class _SideBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback? onPressed;

  const _SideBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    final foreground = selected ? colors.link : colors.textMuted;

    final item = Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? colors.accentSubtle : Colors.transparent,
        borderRadius: BorderRadius.circular(ApertureThemeData.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(ApertureThemeData.radius),
          onTap: onPressed,
          child: SizedBox(
            height: 38,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                spacing: 12,
                children: [
                  Icon(icon, size: 18, color: foreground),
                  if (!compact)
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? colors.link : colors.textStrong,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (compact) {
      return Tooltip(
        message: label,
        preferBelow: false,
        verticalOffset: 0,
        margin: const EdgeInsets.only(left: 56),
        child: item,
      );
    }

    return item;
  }
}

class _EnvironmentBadge extends StatelessWidget {
  final Environment environment;

  const _EnvironmentBadge({required this.environment});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.warningSubtle,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        environment.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.warning,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
