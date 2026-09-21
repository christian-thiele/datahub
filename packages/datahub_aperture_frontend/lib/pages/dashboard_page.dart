import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/blocs/configuration_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = ApertureColors.of(context);

    return BasePage(
      child: BlocBuilder<ConfigurationCubit, ConfigurationState>(
        builder: (context, state) {
          final (resources, modules) = switch (state) {
            ConfigurationValue(:final resources, :final modules) => (
              resources,
              modules,
            ),
            _ => (const <ResourceDescription>[], const <ModuleDescription>[]),
          };

          return ListView(
            children: [
              const SizedBox(height: 8),
              _GradientTitle(
                text: S.of(context).dashboardTitle(Bootstrap.of(context).title),
                highlight: Bootstrap.of(context).title,
              ),
              const SizedBox(height: 6),
              Text(
                S.of(context).dashboardSubtitle,
                style: textTheme.bodyLarge?.copyWith(color: colors.textMuted),
              ),
              if (resources.isNotEmpty) ...[
                const SizedBox(height: 32),
                _SectionTitle(S.of(context).resources),
                _TileGrid(
                  children: [
                    for (final resource in resources)
                      _ShortcutTile(
                        icon: getIcon(resource.icon),
                        title: resource.namePlural ?? resource.name,
                        path: '/resources/${Uri.encodeComponent(resource.id)}',
                      ),
                  ],
                ),
              ],
              if (modules.isNotEmpty) ...[
                const SizedBox(height: 32),
                _SectionTitle(S.of(context).modules),
                _TileGrid(
                  children: [
                    for (final module in modules)
                      _ShortcutTile(
                        icon: getIcon(module.icon),
                        title: module.displayName,
                        path: '/modules/${Uri.encodeComponent(module.id)}',
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// A heading whose [highlight] is painted with the brand gradient.
class _GradientTitle extends StatelessWidget {
  final String text;
  final String highlight;

  const _GradientTitle({required this.text, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displaySmall;
    final index = text.indexOf(highlight);
    if (highlight.isEmpty || index < 0) {
      return Text(text, style: style);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, index)),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: ApertureColors.of(
                context,
              ).brandGradient.createShader,
              child: Text(highlight, style: style),
            ),
          ),
          TextSpan(text: text.substring(index + highlight.length)),
        ],
      ),
      style: style,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TileGrid extends StatelessWidget {
  final List<Widget> children;

  const _TileGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final columns = (constraints.maxWidth / 280).floor().clamp(1, 4);
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String path;

  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.path,
  }) : subtitle = null;

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.go(path),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 14,
            children: [
              IconTile(icon, size: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    /*
                    if (subtitle case final subtitle?)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    */
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, size: 16, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
