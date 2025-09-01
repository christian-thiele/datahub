import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double? iconSize;
  final Color? iconColor;

  const IconText(
    this.icon,
    this.text, {
    super.key,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        Text(text),
      ],
    );
  }
}
