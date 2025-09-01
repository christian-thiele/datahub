import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetryPressed;

  const ErrorView({super.key, this.message, this.onRetryPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 512),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 8),
            Text(
              'An error occurred.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: 8),
            if (message case final message?)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 128),
                child: SingleChildScrollView(child: Text(message)),
              ),
            if (onRetryPressed case final onRetryPressed?)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton.icon(
                  onPressed: onRetryPressed,
                  icon: Icon(Icons.refresh),
                  label: Text('Try again'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
