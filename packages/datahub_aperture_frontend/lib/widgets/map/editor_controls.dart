import 'package:flutter/material.dart';

import 'editor_layer.dart';

class EditorControls extends StatelessWidget {
  final VoidCallback onFocusPressed;
  final VoidCallback onAddPressed;
  final VoidCallback onCancelPressed;
  final VoidCallback onCutPressed;
  final bool readOnly;
  final EditorMode mode;

  const EditorControls({
    super.key,
    required this.onFocusPressed,
    required this.onAddPressed,
    required this.onCancelPressed,
    required this.onCutPressed,
    required this.mode,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      visualDensity: VisualDensity.compact,
      iconSize: WidgetStatePropertyAll(16),
      backgroundColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.primaryContainer,
      ),
      foregroundColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );

    return Stack(
      children: [
        Align(
          alignment: AlignmentGeometry.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                IconButton.filled(
                  style: style,
                  onPressed: onFocusPressed,
                  icon: Icon(Icons.filter_center_focus),
                ),
                if (!readOnly)
                  IconButton.filled(
                    style: style,
                    onPressed: switch (mode) {
                      EditorMode.create => onCancelPressed,
                      _ => onAddPressed,
                    },
                    icon: switch (mode) {
                      EditorMode.create => Icon(Icons.cancel_outlined),
                      _ => Icon(Icons.add),
                    },
                  ),
                if (mode == EditorMode.edit)
                  IconButton.filled(
                    style: style,
                    onPressed: onCutPressed,
                    icon: Icon(Icons.cut),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
