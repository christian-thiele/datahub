import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';

class EmptyListView extends StatelessWidget {
  const EmptyListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_outlined, color: colors.textMuted),
            ),
            Text(
              S.of(context).noElements,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
