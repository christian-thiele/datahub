import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:flutter/material.dart';

class EmptyListView extends StatelessWidget {
  const EmptyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Text(
          S.of(context).noElements,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
