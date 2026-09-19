import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';

enum OptionsButtonVariant { primary, secondary, danger }

/// A button with an optional drop down menu of alternative options.
class OptionsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool menuEnabled;
  final List<Widget> menuChildren;
  final OptionsButtonVariant variant;

  const OptionsButton({
    super.key,
    this.onPressed,
    required this.child,
    required this.menuChildren,
    this.menuEnabled = true,
    this.variant = OptionsButtonVariant.primary,
  });

  static const _height = 36.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = ApertureColors.of(context);

    final (background, foreground, border) = switch (variant) {
      OptionsButtonVariant.primary => (scheme.primary, scheme.onPrimary, null),
      OptionsButtonVariant.secondary => (
        scheme.surface,
        colors.textStrong,
        colors.borderStrong,
      ),
      OptionsButtonVariant.danger => (
        scheme.surface,
        colors.danger,
        colors.borderStrong,
      ),
    };
    final disabledBackground = variant == OptionsButtonVariant.primary
        ? scheme.surfaceContainerHigh
        : scheme.surface;
    final disabledForeground = scheme.onSurface.withAlpha(97);

    final overlayColor = WidgetStateProperty.resolveWith((
      Set<WidgetState> states,
    ) {
      final base = variant == OptionsButtonVariant.primary
          ? scheme.onPrimary
          : foreground;
      if (states.contains(WidgetState.pressed)) {
        return base.withAlpha(31);
      }
      if (states.contains(WidgetState.hovered)) {
        return base.withAlpha(20);
      }
      if (states.contains(WidgetState.focused)) {
        return base.withAlpha(31);
      }
      return null;
    });

    final mainPart = SizedBox(
      height: _height,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: 14,
            right: menuChildren.isNotEmpty ? 10 : 16,
          ),
          child: child,
        ),
      ),
    );

    final sidePart = SizedBox(
      height: _height,
      width: 32,
      child: Center(child: Icon(Icons.expand_more)),
    );

    Widget divider(bool enabled) => Container(
      width: 1,
      height: _height,
      color: switch (variant) {
        OptionsButtonVariant.primary => scheme.onPrimary.withAlpha(
          enabled ? 90 : 40,
        ),
        _ => border,
      },
    );

    Widget pressable(Widget child, VoidCallback? onTap) {
      final effectiveForeground = onTap != null
          ? foreground
          : disabledForeground;
      return Material(
        color: onTap != null ? background : disabledBackground,
        child: DefaultTextStyle.merge(
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: effectiveForeground),
          child: IconTheme(
            data: IconThemeData(color: effectiveForeground, size: 18),
            child: InkWell(
              overlayColor: overlayColor,
              onTap: onTap,
              child: child,
            ),
          ),
        ),
      );
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ApertureThemeData.radius),
      side: border != null ? BorderSide(color: border) : BorderSide.none,
    );

    return MenuAnchor(
      menuChildren: menuChildren,
      alignmentOffset: Offset(0, 6),
      builder: (context, controller, _) => Material(
        clipBehavior: Clip.antiAlias,
        shape: shape,
        child: switch (onPressed) {
          final onMainPressed? => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              pressable(mainPart, onMainPressed),
              if (menuChildren.isNotEmpty) ...[
                divider(menuEnabled),
                pressable(sidePart, menuEnabled ? controller.open : null),
              ],
            ],
          ),
          null => pressable(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [mainPart, if (menuChildren.isNotEmpty) sidePart],
            ),
            menuEnabled ? controller.open : null,
          ),
        },
      ),
    );
  }
}
