import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetryPressed;

  const ErrorView({super.key, this.message, this.onRetryPressed});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.dangerSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 24, color: colors.danger),
            ),
            SizedBox(height: 16),
            Text(
              S.maybeOf(context)?.errorOccurred ?? 'Something went wrong.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (message case final message?) ...[
              SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 128),
                child: SingleChildScrollView(
                  child: Text(
                    message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            if (onRetryPressed case final onRetryPressed?)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: OutlinedButton.icon(
                  onPressed: onRetryPressed,
                  icon: Icon(Icons.refresh),
                  label: Text(S.maybeOf(context)?.tryAgain ?? 'Try again'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
