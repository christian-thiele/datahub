import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';

/// The common layout of dialogs: a title, content and actions at the bottom.
class ApertureDialog extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget child;
  final List<Widget> actions;
  final double width;

  const ApertureDialog({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
    this.actions = const [],
    this.width = 400,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    final effectiveIconColor = iconColor ?? colors.link;
    return Dialog(
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              Row(
                spacing: 12,
                children: [
                  if (icon case final icon?)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          effectiveIconColor.withAlpha(28),
                          Theme.of(context).colorScheme.surface,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 18, color: effectiveIconColor),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodyLarge,
                child: child,
              ),
              if (actions.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: actions,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
