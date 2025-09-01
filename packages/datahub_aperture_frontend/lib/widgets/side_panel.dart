import 'package:flutter/material.dart';

class SidePanel extends StatelessWidget {
  final Widget child;

  const SidePanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 256, maxWidth: 256),
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );
  }
}
