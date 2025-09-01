import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/map/editor_layer.dart';
import 'package:datahub_aperture_frontend/widgets/map/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';

class ResourceGeoJsonFormField extends StatefulWidget {
  final ResourceField field;
  final String? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<String>? onChanged;

  const ResourceGeoJsonFormField({
    super.key,
    required this.field,
    this.value,
    this.error,
    required this.isChanged,
    this.onChanged,
  });

  @override
  State<ResourceGeoJsonFormField> createState() =>
      _ResourceGeoJsonFormFieldState();
}

class _ResourceGeoJsonFormFieldState extends State<ResourceGeoJsonFormField>
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

    final jsonFeatures = GeoJSONFeatureCollection.fromJSON(
      widget.value!,
    ).features.nonNulls.toList();

    features = jsonFeatures
        .map((e) => e.geometry)
        .whereType<GeoJSONPolygon>()
        .map(geoJSONPolygonToEditorPolygon)
        .toList();
  }

  @override
  void didUpdateWidget(covariant ResourceGeoJsonFormField oldWidget) {
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
              final polygons = value.map(editorPolygonToGeoJSONPolygon);
              final features = polygons.map(GeoJSONFeature.new);

              widget.onChanged?.call(
                GeoJSONFeatureCollection(features.toList()).toJSON(),
              );
            },
          ),
        ],
      ),
    );
  }
}
