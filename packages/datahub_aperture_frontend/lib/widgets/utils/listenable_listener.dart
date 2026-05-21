import 'package:flutter/material.dart';

class ListenableListener extends StatefulWidget {
  final Listenable listenable;
  final VoidCallback onEvent;
  final Widget child;

  const ListenableListener({
    super.key,
    required this.listenable,
    required this.onEvent,
    required this.child,
  });

  @override
  State<ListenableListener> createState() => _ListenableListenerState();
}

class _ListenableListenerState extends State<ListenableListener> {
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onEvent);
  }

  @override
  void didUpdateWidget(covariant ListenableListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onEvent);
      widget.listenable.addListener(_onEvent);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.listenable.removeListener(_onEvent);
  }

  // proxy because widget.onEvent can change
  void _onEvent() => widget.onEvent();

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
