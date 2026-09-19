import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';

class GroupDecoration extends StatelessWidget {
  final InputDecoration decoration;
  final Widget child;
  final VoidCallback? onAddPressed;
  final bool hasNestedErrors;

  const GroupDecoration({
    super.key,
    required this.decoration,
    required this.child,
    this.onAddPressed,
    this.hasNestedErrors = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final errorText = decoration.errorText;
    final isError = errorText != null || hasNestedErrors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (decoration.label != null || onAddPressed != null)
          DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isError ? colors.error : null,
            ),
            child: Row(
              children: [
                ?decoration.label,
                Spacer(),
                if (onAddPressed != null)
                  IconButton(onPressed: onAddPressed, icon: Icon(Icons.add)),
              ],
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(ApertureThemeData.radius),
            border: Border.all(
              color: isError ? colors.error : colors.outlineVariant,
            ),
          ),
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
        if (errorText != null)
          Text(
            errorText,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.error),
          ),
      ],
    );
  }
}
