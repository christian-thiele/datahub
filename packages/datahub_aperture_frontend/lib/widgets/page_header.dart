import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Breadcrumb {
  final String label;
  final String? path;

  const Breadcrumb(this.label, [this.path]);
}

/// Title row at the top of a page, with optional breadcrumbs and actions.
class PageHeader extends StatelessWidget {
  /// Width below which the actions are placed below the title.
  static const _stackedBreakpoint = 560.0;

  final String title;
  final Widget? leading;
  final List<Breadcrumb> breadcrumbs;
  final List<Widget> actions;

  const PageHeader({
    super.key,
    required this.title,
    this.leading,
    this.breadcrumbs = const [],
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        if (breadcrumbs.isNotEmpty) _Breadcrumbs(breadcrumbs: breadcrumbs),
        LayoutBuilder(
          builder: (context, constraints) {
            final titleRow = ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  if (!kIsWeb && context.canPop()) const _BackButton(),
                  ?leading,
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (actions.isNotEmpty &&
                      constraints.maxWidth >= _stackedBreakpoint)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: actions,
                    ),
                ],
              ),
            );

            if (actions.isEmpty || constraints.maxWidth >= _stackedBreakpoint) {
              return titleRow;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                titleRow,
                Wrap(spacing: 8, runSpacing: 8, children: actions),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  final List<Breadcrumb> breadcrumbs;

  const _Breadcrumbs({required this.breadcrumbs});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    final style = Theme.of(context).textTheme.labelMedium;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        for (final (index, crumb) in breadcrumbs.indexed) ...[
          if (index > 0)
            Icon(Icons.chevron_right, size: 14, color: colors.textMuted),
          if (crumb.path case final path?)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.go(path),
                child: Text(crumb.label, style: style),
              ),
            )
          else
            Flexible(
              child: Text(
                crumb.label,
                style: style?.copyWith(color: colors.textStrong),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ],
    );
  }
}

/// An icon on a tinted, rounded square.
class IconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? background;

  const IconTile(
    this.icon, {
    super.key,
    this.size = 36,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? colors.accentSubtle,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: color ?? colors.link),
    );
  }
}
