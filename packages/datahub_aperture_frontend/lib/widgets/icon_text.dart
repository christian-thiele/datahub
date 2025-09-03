import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double? iconSize;
  final Color? iconColor;
  final bool leading;

  const IconText(
    this.icon,
    this.text, {
    super.key,
    this.iconSize,
    this.iconColor,
    this.leading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        if (leading) Icon(icon, size: iconSize, color: iconColor),
        Text(text),
        if (!leading) Icon(icon, size: iconSize, color: iconColor),
      ],
    );
  }
}
