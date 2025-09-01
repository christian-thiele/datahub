import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final Widget child;

  const BasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(padding: EdgeInsets.all(16), child: child),
    );
  }
}
