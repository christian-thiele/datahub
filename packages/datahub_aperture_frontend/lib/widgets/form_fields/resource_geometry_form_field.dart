import 'package:datahub/data.dart';
import 'package:datahub_aperture_frontend/widgets/map/editor_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide Polygon;
import 'package:latlong2/latlong.dart';

class ResourceGeometryFormField extends StatefulWidget {
  final InputDecoration decoration;
  final Geometry? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<Geometry?>? onChanged;

  const ResourceGeometryFormField({
    super.key,
    required this.decoration,
    this.value,
    this.error,
    required this.isChanged,
    this.onChanged,
  });

  @override
  State<ResourceGeometryFormField> createState() =>
      _ResourceGeometryFormFieldState();
}

class _ResourceGeometryFormFieldState extends State<ResourceGeometryFormField>
    with SingleTickerProviderStateMixin {
  late final MapControllerImpl _controller;
  var features = <EditorPolygon>[];

  @override
  void initState() {
    super.initState();
    _controller = MapControllerImpl();
    _update();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update() {
    features = [];
    if (widget.value case Polygon polygon) {
      features.add(
        EditorPolygon(
          bounds: unclose(
            polygon.rings.first.points.map((e) => LatLng(e.y, e.x)).toList(),
          ),
          holes: polygon.rings
              .skip(1)
              .map(
                (e) => unclose(e.points.map((e) => LatLng(e.y, e.x)).toList()),
              ),
        ),
      );
    }
  }

  List<LatLng> unclose(List<LatLng> points) {
    if (points.length > 1 && points.first == points.last) {
      return points.take(points.length - 1).toList();
    } else {
      return points;
    }
  }

  @override
  void didUpdateWidget(covariant ResourceGeometryFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _update();
    }
  }

  CameraFit _initialFit() {
    if (features.isEmpty) {
      return CameraFit.coordinates(coordinates: [LatLng(51, 11)], maxZoom: 5);
    }

    return CameraFit.bounds(
      bounds: LatLngBounds.fromPoints([
        for (final feature in features) ...feature.bounds,
      ]),
      padding: EdgeInsets.all(64),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = switch (InputDecorationTheme.of(context).border) {
      OutlineInputBorder(:final borderRadius) => borderRadius,
      _ => BorderRadius.zero,
    };

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: SizedBox(
              height: 384,
              child: FlutterMap(
                mapController: _controller,
                options: MapOptions(initialCameraFit: _initialFit()),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'net.datahubproject.aperture',
                  ),
                  EditorLayer(
                    features: features,
                    onChanged: widget.onChanged != null
                        ? (List<EditorPolygon> value) {
                            if (value.isEmpty) {
                              widget.onChanged?.call(null);
                            } else if (value.length == 1) {
                              widget.onChanged?.call(value.first.toGeometry());
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: InputDecorator(
              decoration: widget.decoration,
              child: SizedBox(height: 392),
            ),
          ),
        ),
      ],
    );
  }
}
