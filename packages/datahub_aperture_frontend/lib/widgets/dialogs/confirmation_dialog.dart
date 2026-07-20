import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final String confirmText;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.child,
    required this.confirmText,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required Widget child,
    required String confirmText,
    required VoidCallback onConfirmPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        confirmText: confirmText,
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
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: SizedBox(
          width: 256 + 128,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodyLarge,
                child: child,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(confirmText),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(S.of(context).cancel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
