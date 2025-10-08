import 'package:flutter/material.dart';

class GroupDecoration extends StatelessWidget {
  final InputDecoration decoration;
  final Widget child;
  final VoidCallback? onAddPressed;

  const GroupDecoration({
    super.key,
    required this.decoration,
    required this.child,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isError = decoration.errorText != null;
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: isError ? Theme.of(context).colorScheme.error : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          if (decoration.label != null || onAddPressed != null)
            Row(
              children: [
                ?decoration.label,
                Spacer(),
                if (onAddPressed != null)
                  IconButton(onPressed: onAddPressed, icon: Icon(Icons.add)),
              ],
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
