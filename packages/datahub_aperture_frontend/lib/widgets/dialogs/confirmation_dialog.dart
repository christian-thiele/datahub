import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';

import 'aperture_dialog.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final String confirmText;

  /// Whether confirming destroys data, which is emphasized in red.
  final bool destructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.child,
    required this.confirmText,
    this.destructive = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required Widget child,
    required String confirmText,
    required VoidCallback onConfirmPressed,
    bool destructive = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        confirmText: confirmText,
        destructive: destructive,
        child: child,
      ),
    ).then((value) {
      if (value == true) {
        onConfirmPressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return ApertureDialog(
      title: title,
      icon: destructive ? Icons.warning_amber_rounded : Icons.help_outline,
      iconColor: destructive ? colors.danger : null,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: colors.danger,
                  foregroundColor: Colors.white,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
      child: child,
    );
  }
}
