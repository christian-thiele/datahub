import 'package:datahub_aperture_frontend/widgets/map/editor_layer.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';

extension MapControllerExtension on MapControllerImpl {
  void fitCameraAnimated(
    CameraFit target, {
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOutCubicEmphasized,
    Offset offset = Offset.zero,
  }) {
    final fit = target.fit(camera);
    moveAndRotateAnimatedRaw(
      fit.center,
      fit.zoom,
      fit.rotation,
      duration: duration,
      offset: offset,
      curve: curve,
      hasGesture: false,
      source: MapEventSource.mapController,
    );
  }
}

extension MapCameraUtils on MapCamera {
  Offset worldToScreen(LatLng latLng) {
    return projectAtZoom(latLng) - pixelOrigin;
  }

  LatLng screenToWorld(Offset offset) {
    return unprojectAtZoom(offset + pixelOrigin);
  }
}

extension MapControllerImplUtils on MapControllerImpl {
  void fitBounds(LatLngBounds bounds) {
    fitCameraAnimated(
      CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(64)),
    );
  }

  void focusOn(EditorPolygon feature) {
    fitBounds(LatLngBounds.fromPoints(feature.bounds));
  }

  void focusOnAll(Iterable<EditorPolygon> features) {
    if (features.isNotEmpty) {
      fitBounds(
        LatLngBounds.fromPoints([
          for (final feature in features) ...feature.bounds,
        ]),
      );
    }
  }
}

EditorPolygon geoJSONPolygonToEditorPolygon(GeoJSONPolygon e) {
  return EditorPolygon(
    bounds: e.coordinates.first.map((e) => LatLng(e[1], e[0])),
    holes: [
      for (final hole in e.coordinates.skip(1))
        hole.map((e) => LatLng(e[1], e[0])),
    ],
  );
}

GeoJSONPolygon editorPolygonToGeoJSONPolygon(EditorPolygon e) {
  return GeoJSONPolygon([
    [
      ...e.bounds.map((e) => [e.longitude, e.latitude]),
    ],
    ...e.holes.map(
      (e) => [
        ...e.map((e) => [e.longitude, e.latitude]),
      ].toList(),
    ),
  ]);
}
