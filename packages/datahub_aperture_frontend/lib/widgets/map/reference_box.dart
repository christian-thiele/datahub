import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ReferenceBox extends StatefulWidget {
  final Widget child;
  final void Function(Offset offset, LatLng latLng)? onTap;

  const ReferenceBox({super.key, required this.child, this.onTap});

  static RenderBox? of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_ReferenceBoxInherited>();
    return inherited?.renderBox;
  }

  @override
  State<ReferenceBox> createState() => _ReferenceBoxState();
}

class _ReferenceBoxState extends State<ReferenceBox> {
  @override
  Widget build(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    return _ReferenceBoxInherited(renderBox: renderBox, child: widget.child);
  }
}

class _ReferenceBoxInherited extends InheritedWidget {
  final RenderBox? renderBox;

  const _ReferenceBoxInherited({required this.renderBox, required super.child});

  @override
  bool updateShouldNotify(_ReferenceBoxInherited oldWidget) =>
      oldWidget.renderBox != renderBox;
}
