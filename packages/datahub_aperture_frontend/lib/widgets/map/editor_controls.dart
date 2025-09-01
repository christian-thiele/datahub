import 'package:flutter/material.dart';

import 'editor_layer.dart';

class EditorControls extends StatelessWidget {
  final VoidCallback onFocusPressed;
  final VoidCallback onAddPressed;
  final VoidCallback onCancelPressed;
  final VoidCallback onCutPressed;
  final EditorMode mode;

  const EditorControls({
    super.key,
    required this.onFocusPressed,
    required this.onAddPressed,
    required this.onCancelPressed,
    required this.onCutPressed,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
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
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    iconSize: WidgetStatePropertyAll(16),
                  ),
                  onPressed: onFocusPressed,
                  icon: Icon(Icons.filter_center_focus),
                ),
                IconButton.filled(
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    iconSize: WidgetStatePropertyAll(16),
                  ),
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
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      iconSize: WidgetStatePropertyAll(16),
                    ),
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
