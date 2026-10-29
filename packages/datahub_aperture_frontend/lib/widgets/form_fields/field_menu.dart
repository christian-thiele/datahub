import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:flutter/material.dart';

/// Shows [child] with a button next to it that opens a menu of actions on the
/// field, like setting it to null.
///
/// The menu has its own button instead of taking over the context menu, so
/// that the context menu of text stays as usual (the one of the browser on
/// the web). With a pointer, the button only shows while the field is hovered
/// or focused, on touch screens it always shows.
class FieldMenu extends StatefulWidget {
  /// The width the button takes next to the field.
  static const width = 40.0;

  /// The items of the menu, like [MenuItemButton]s.
  ///
  /// Without items no button is shown, but its space is kept, so the field
  /// lines up with fields that have one. `null` keeps no space.
  final List<Widget>? menuChildren;
  final Widget child;

  const FieldMenu({super.key, required this.menuChildren, required this.child});

  @override
  State<FieldMenu> createState() => _FieldMenuState();
}

class _FieldMenuState extends State<FieldMenu> {
  /// Has focus while something in the field (or its menu) has.
  final _focusNode = FocusNode(canRequestFocus: false, skipTraversal: true);
  bool _hovered = false;
  bool _focused = false;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    // Not Focus.onFocusChange, which is not called when the focused item of
    // the menu goes away with the menu.
    FocusManager.instance.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _focused) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  bool get _isTouch => switch (Theme.of(context).platform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.fuchsia => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final menuChildren = widget.menuChildren;
    if (menuChildren == null) {
      return widget.child;
    }

    final visible = _isTouch || _hovered || _focused || _open;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Focus(
        focusNode: _focusNode,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: widget.child),
            SizedBox(
              width: FieldMenu.width,
              child: menuChildren.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: 2, left: 4),
                      child: AnimatedOpacity(
                        opacity: visible ? 1 : 0,
                        duration: const Duration(milliseconds: 120),
                        alwaysIncludeSemantics: true,
                        child: MenuAnchor(
                          onOpen: () => setState(() => _open = true),
                          onClose: () {
                            if (mounted) {
                              setState(() => _open = false);
                            }
                          },
                          menuChildren: menuChildren,
                          builder: (context, controller, _) => IconButton(
                            onPressed: () => controller.isOpen
                                ? controller.close()
                                : controller.open(),
                            icon: const Icon(Icons.more_vert, size: 18),
                            tooltip: S.of(context).fieldActions,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
