import 'package:datahub_aperture_frontend/widgets/map/reference_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DraggableMarker extends Marker {
  DraggableMarker({
    super.key,
    required super.point,
    required super.width,
    required super.height,
    super.alignment,
    super.rotate,
    required Widget child,
    required ValueChanged<LatLng> onChanged,
  }) : super(
         child: DraggableMarkerWidget(onChanged: onChanged, child: child),
       );
}

class DraggableMarkerWidget extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final ValueChanged<LatLng> onChanged;

  const DraggableMarkerWidget({
    super.key,
    required this.child,
    required this.onChanged,
    this.width = 32,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Draggable<LatLng>(
        feedback: child,
        childWhenDragging: Opacity(opacity: 0.5, child: child),
        child: child,
        onDragEnd: (details) {
          final renderBox = ReferenceBox.of(context);
          final localPosition = renderBox?.globalToLocal(details.offset);

          if (localPosition != null) {
            final map = MapCamera.of(context);
            final location = map.screenOffsetToLatLng(
              localPosition + Offset(width / 2, height),
            );
            onChanged(location);
          }
        },
      ),
    );
  }
}
