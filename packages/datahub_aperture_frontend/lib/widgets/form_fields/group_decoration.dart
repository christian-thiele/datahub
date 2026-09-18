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
            style: TextStyle(color: isError ? colors.error : null),
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
            border: Border(
              left: BorderSide(color: isError ? colors.error : colors.outline),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
            child: child,
          ),
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
