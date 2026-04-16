import 'package:flutter/material.dart';

class InfoBadge extends StatelessWidget {
  final Widget icon;
  final Widget label;
  final Color? color;
  final Color? foregroundColor;
  final double minWidth;

  const InfoBadge({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.foregroundColor,
    this.minWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final effectiveForegroundColor =
        foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
    return Container(
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: effectiveForegroundColor),
          child: IconTheme.merge(
            data: IconThemeData(color: effectiveForegroundColor, size: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [icon, label],
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressInfoBadge extends StatelessWidget {
  final Widget label;
  final double progress;
  final double minWidth;

  const ProgressInfoBadge({
    super.key,
    required this.label,
    required this.progress,
    required this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        InfoBadge(
          color: Theme.of(context).colorScheme.onPrimary,
          foregroundColor: Theme.of(context).colorScheme.primary,
          icon: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 1,
            ),
          ),
          label: Text('${(progress * 100).round()}%'),
          minWidth: minWidth,
        ),
        ClipRect(
          clipBehavior: Clip.antiAlias,
          clipper: _ProgressClipper(progress),
          child: InfoBadge(
            color: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 1,
              ),
            ),
            label: Text('${(progress * 100).round()}%'),
            minWidth: minWidth,
          ),
        ),
      ],
    );
  }
}

class _ProgressClipper extends CustomClipper<Rect> {
  final double progress;

  _ProgressClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(covariant _ProgressClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
