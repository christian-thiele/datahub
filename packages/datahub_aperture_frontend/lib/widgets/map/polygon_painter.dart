import 'dart:math';

import 'package:datahub_aperture_frontend/widgets/map/editor_layer.dart';
import 'package:datahub_aperture_frontend/widgets/map/utils.dart';
import 'package:boost/boost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

class PolygonPainter extends StatelessWidget {
  final EditorPolygon polygon;
  final VoidCallback? onSelect;

  const PolygonPainter({super.key, required this.polygon, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: onSelect,
      child: MobileLayerTransformer(
        child: CustomPaint(
          painter: _Painter(
            camera: camera,
            polygon: polygon,
            colorScheme: Theme.of(context).colorScheme,
          ),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final MapCamera camera;
  final EditorPolygon polygon;
  final ColorScheme colorScheme;

  _Painter({
    required this.camera,
    required this.polygon,
    required this.colorScheme,
  });

  late final fillPaint = Paint()
    ..color = colorScheme.primaryContainer.withAlpha(150)
    ..style = PaintingStyle.fill;

  late final linePaint = Paint()
    ..color = colorScheme.primary
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final linePath = Path();

    final loop = <LatLng>[...polygon.bounds];
    linePath.addPolygon([...polygon.bounds.map(camera.worldToScreen)], true);
    for (final hole in polygon.holes) {
      final closest = loop.indexed.min((e) => _dirtyDistance(hole.first, e.$2));
      loop.insertAll(closest.$1 + 1, [...hole, hole.first, closest.$2]);
      linePath.addPolygon([...hole.map(camera.worldToScreen)], true);
    }

    final fillPath = Path();
    fillPath.addPolygon(loop.map(camera.worldToScreen).toList(), true);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  double _dirtyDistance(LatLng p1, LatLng p2) {
    final dx = p1.longitude - p2.longitude;
    final dy = p1.latitude - p2.latitude;
    return sqrt(dx * dx + dy * dy);
  }

  @override
  bool shouldRepaint(covariant _Painter oldDelegate) {
    return oldDelegate.polygon != polygon ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.camera != camera;
  }

  @override
  bool? hitTest(Offset position) {
    return polygon.isPointInside(camera.screenToWorld(position));
  }
}
