import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double? iconSize;
  final Color? iconColor;
  final bool leading;
  final TextStyle? style;

  const IconText(
    this.icon,
    this.text, {
    super.key,
    this.iconSize,
    this.iconColor,
    this.leading = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        if (leading) Icon(icon, size: iconSize, color: iconColor),
        Flexible(child: Text(text, style: style)),
        if (!leading) Icon(icon, size: iconSize, color: iconColor),
      ],
    );
  }
}
