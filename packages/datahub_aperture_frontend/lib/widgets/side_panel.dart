import 'package:flutter/material.dart';

class SidePanel extends StatelessWidget {
  final Widget child;

  /// Fixed width of the panel, or null to fill the available width.
  final double? width;

  const SidePanel({super.key, required this.child, this.width = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }
}
