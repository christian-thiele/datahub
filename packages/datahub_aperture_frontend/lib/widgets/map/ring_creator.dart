import 'package:datahub_aperture_frontend/widgets/map/editor_layer.dart';
import 'package:datahub_aperture_frontend/widgets/map/polygon_painter.dart';
import 'package:datahub_aperture_frontend/widgets/map/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'handle.dart';

class RingCreator extends StatefulWidget {
  final ValueChanged<List<LatLng>> onDone;
  final VoidCallback onCancel;

  const RingCreator({super.key, required this.onDone, required this.onCancel});

  @override
  State<RingCreator> createState() => _RingCreatorState();
}

class _RingCreatorState extends State<RingCreator> {
  final ring = <LatLng>[LatLng(0, 0)];

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.escape:
            widget.onCancel();
            return KeyEventResult.handled;
          case LogicalKeyboardKey.enter:
          case LogicalKeyboardKey.numpadEnter:
            widget.onDone(ring.take(ring.length - 1).toList());
            return KeyEventResult.handled;
          default:
            return KeyEventResult.ignored;
        }
      },
      child: Builder(
        builder: (context) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              Focus.of(context).requestFocus();
              final renderBox = context.findRenderObject() as RenderBox;
              final offset = renderBox.globalToLocal(details.globalPosition);
              setState(() {
                ring.add(MapCamera.of(context).screenToWorld(offset));
              });
            },
            onSecondaryTap: () => widget.onDone(ring),
            child: Stack(
              children: [
                PolygonPainter(polygon: EditorPolygon(bounds: ring)),
                MouseRegion(
                  onHover: (event) {
                    setState(() {
                      ring.last = MapCamera.of(
                        context,
                      ).screenToWorld(event.localPosition);
                    });
                  },
                  child: MobileLayerTransformer(
                    child: Stack(
                      children: [
                        for (final pos in ring)
                          Handle.positioned(context, position: pos),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
