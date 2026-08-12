import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// Padding kept between the fitted geometry and the edges of the map.
const _fitPadding = EdgeInsets.all(64);

/// The zoom a fit stops at, so that fitting a single point does not zoom in
/// infinitely.
const _fitMaxZoom = 17.0;

extension GeoCameraFit on MapControllerImpl {
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

  /// Animates the camera so that all [positions] are visible.
  void fitPositions(Iterable<LatLng> positions) {
    final points = positions.toList();
    if (points.isEmpty) {
      return;
    }

    fitCameraAnimated(cameraFitOf(points));
  }
}

/// A fit showing all [positions], or a wide default view if there are none.
CameraFit cameraFitOf(Iterable<LatLng> positions) {
  final points = positions.toList();
  if (points.isEmpty) {
    return CameraFit.coordinates(coordinates: [LatLng(51, 11)], maxZoom: 4);
  }

  return CameraFit.bounds(
    bounds: LatLngBounds.fromPoints(points),
    padding: _fitPadding,
    maxZoom: _fitMaxZoom,
  );
}
