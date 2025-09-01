import 'package:flutter/material.dart';

class OverlayButton extends StatefulWidget {
  final Widget Function(BuildContext, VoidCallback) childBuilder;
  final Widget Function(BuildContext, VoidCallback) overlayBuilder;

  const OverlayButton({
    super.key,
    required this.childBuilder,
    required this.overlayBuilder,
  });

  @override
  State<OverlayButton> createState() => _TextFieldAnchorButtonState();
}

class _TextFieldAnchorButtonState extends State<OverlayButton> {
  final LayerLink _link = LayerLink();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  double _buttonHeight = 0.0;
  OverlayEntry? _entry;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openOverlay() {
    if (_entry != null) return;

    final render = context.findRenderObject() as RenderBox?;
    if (render != null) _buttonHeight = render.size.height;

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Tap outside to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
              ),
            ),

            // The anchored overlay
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: Offset(0, _buttonHeight) + const Offset(0, 8),
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: widget.overlayBuilder(context, _toggle),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);

    // Focus after insert so the keyboard pops and caret shows.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // Close when focus is lost (e.g., user taps elsewhere)
      _focusNode.addListener(() {
        if (!_focusNode.hasFocus) _removeOverlay();
      });
    });
  }

  void _removeOverlay() {
    _focusNode.removeListener(() {});
    _entry?.remove();
    _entry = null;
  }

  void _toggle() {
    if (_entry != null) {
      _removeOverlay();
    } else {
      _openOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: widget.childBuilder(context, _toggle),
    );
  }
}
