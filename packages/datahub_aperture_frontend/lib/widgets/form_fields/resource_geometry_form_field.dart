import 'package:datahub/data.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/map/editor_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide Polygon;
import 'package:latlong2/latlong.dart';

class ResourceGeometryFormField extends StatefulWidget {
  final ResourceField field;
  final Geometry? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<Geometry?>? onChanged;

  const ResourceGeometryFormField({
    super.key,
    required this.field,
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
    if (widget.value == null) {
      return;
    }

    features = [];
    if (widget.value case Polygon polygon) {
      features.add(
        EditorPolygon(
          bounds: polygon.rings.first.points.map((e) => LatLng(e.y, e.x)),
          holes: polygon.rings
              .skip(1)
              .map((e) => e.points.map((e) => LatLng(e.y, e.x))),
        ),
      );
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
    return SizedBox(
      height: 384,
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(initialCameraFit: _initialFit()),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'net.datahubproject.aperture',
          ),
          EditorLayer(
            features: features,
            onChanged: (List<EditorPolygon> value) {
              if (value.isEmpty) {
                widget.onChanged?.call(null);
              } else if (value.length == 1) {
                widget.onChanged?.call(value.first.toGeometry());
              }
            },
          ),
        ],
      ),
    );
  }
}
