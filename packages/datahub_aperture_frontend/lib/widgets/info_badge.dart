import 'package:flutter/material.dart';

/// A small rounded label with an icon, tinted in [color].
class InfoBadge extends StatelessWidget {
  final Widget icon;
  final Widget label;

  /// The accent colour, defaults to the primary colour.
  final Color? color;

  /// Colour of text and icon, defaults to [color].
  final Color? foregroundColor;

  /// Background colour, defaults to a tint of [color].
  final Color? backgroundColor;
  final double minWidth;

  const InfoBadge({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.foregroundColor,
    this.backgroundColor,
    this.minWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? scheme.primary;
    final effectiveForegroundColor = foregroundColor ?? effectiveColor;
    final effectiveBackgroundColor =
        backgroundColor ??
        Color.alphaBlend(
          effectiveColor.withAlpha(
            scheme.brightness == Brightness.dark ? 46 : 26,
          ),
          scheme.surface,
        );
    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: effectiveForegroundColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: effectiveForegroundColor, size: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [icon, label],
            ),
          ),
        ),
      ),
    );
  }
}

/// An [InfoBadge] with an icon and a text label.
class StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? background;

  const StatusPill({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) => InfoBadge(
    icon: Icon(icon),
    label: Text(label),
    color: color,
    backgroundColor: background,
  );
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
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        InfoBadge(
          icon: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              color: scheme.primary,
              strokeWidth: 1.5,
            ),
          ),
          label: Text('${(progress * 100).round()}%'),
          minWidth: minWidth,
        ),
        ClipRect(
          clipBehavior: Clip.antiAlias,
          clipper: _ProgressClipper(progress),
          child: InfoBadge(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            icon: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                color: scheme.onPrimary,
                strokeWidth: 1.5,
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
