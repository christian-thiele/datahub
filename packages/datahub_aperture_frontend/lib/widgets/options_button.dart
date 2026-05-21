import 'package:flutter/material.dart';

class OptionsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool menuEnabled;
  final List<Widget> menuChildren;

  const OptionsButton({
    super.key,
    this.onPressed,
    required this.child,
    required this.menuChildren,
    this.menuEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabledBackgroundColor = Theme.of(context).colorScheme.primary;
    final disabledBackgroundColor = Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha(31);

    final enabledForegroundColor = Theme.of(context).colorScheme.onPrimary;
    final disabledForegroundColor = Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha(97);

    final overlayColor = WidgetStateProperty.resolveWith((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return Theme.of(context).colorScheme.onPrimary.withAlpha(26);
      }
      if (states.contains(WidgetState.hovered)) {
        return Theme.of(context).colorScheme.onPrimary.withAlpha(20);
      }
      if (states.contains(WidgetState.focused)) {
        return Theme.of(context).colorScheme.onPrimary.withAlpha(26);
      }
      return null;
    });

    final mainPart = SizedBox(
      height: 32,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 24, right: 16),
          child: child,
        ),
      ),
    );

    final sidePart = SizedBox(
      height: 32,
      width: 32,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Icon(Icons.arrow_drop_down),
        ),
      ),
    );

    final divider = Container(
      decoration: BoxDecoration(
        border: Border(
          right: Divider.createBorderSide(
            context,
            color: enabledForegroundColor.withAlpha(200),
          ),
        ),
      ),
      height: 32,
      width: 0,
    );

    Widget pressable(Widget child, VoidCallback? onTap) => Material(
      color: onTap != null ? enabledBackgroundColor : disabledBackgroundColor,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: onTap != null
              ? enabledForegroundColor
              : disabledForegroundColor,
        ),
        child: IconTheme(
          data: IconThemeData(
            color: onTap != null
                ? enabledForegroundColor
                : disabledForegroundColor,
            size: 20,
          ),
          child: InkWell(
            hoverColor: Theme.of(context).colorScheme.onPrimary.withAlpha(13),
            overlayColor: overlayColor,
            onTap: onTap,
            child: child,
          ),
        ),
      ),
    );

    return MenuAnchor(
      menuChildren: menuChildren,
      alignmentOffset: Offset(0, 8),
      builder: (context, controller, _) => Material(
        clipBehavior: Clip.antiAlias,
        shape: StadiumBorder(),
        child: switch (onPressed) {
          final onMainPressed? => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              pressable(mainPart, onMainPressed),
              if (menuEnabled) divider,
              pressable(sidePart, menuEnabled ? controller.open : null),
            ],
          ),
          null => pressable(
            Row(mainAxisSize: MainAxisSize.min, children: [mainPart, sidePart]),
            menuEnabled ? controller.open : null,
          ),
        },
      ),
    );
  }
}
