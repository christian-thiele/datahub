import 'package:flutter/material.dart';

class ValueView extends StatelessWidget {
  final String label;
  final Widget value;

  const ValueView({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        value,
      ],
    );
  }
}
