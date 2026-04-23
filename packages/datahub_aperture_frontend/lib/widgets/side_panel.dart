import 'package:flutter/material.dart';

class SidePanel extends StatelessWidget {
  final Widget child;

  const SidePanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 280),
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }
}
