import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final Widget child;

  const BasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    return Material(
      color: ApertureColors.of(context).canvas,
      child: Padding(
        padding: compact
            ? const EdgeInsets.all(16)
            : const EdgeInsets.fromLTRB(32, 28, 32, 24),
        child: child,
      ),
    );
  }
}
