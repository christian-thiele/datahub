import 'dart:math';
import 'dart:ui';

import 'package:datahub_aperture_frontend/blocs/geo_editor/geo_editor_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'model/geo_feature.dart';

/// Something on the map the pointer can act on.
@immutable
sealed class GeoTarget {
  const GeoTarget();
}

/// The body of a feature, hit outside of any of its handles.
class GeoFeatureTarget extends GeoTarget {
  final int index;

  const GeoFeatureTarget(this.index);

  @override
  bool operator ==(Object other) =>
      other is GeoFeatureTarget && other.index == index;

  @override
  int get hashCode => index.hashCode;
}

/// An existing vertex of the selected feature.
class GeoVertexTarget extends GeoTarget {
  final GeoVertexRef ref;

  const GeoVertexTarget(this.ref);

  @override
  bool operator ==(Object other) =>
      other is GeoVertexTarget && other.ref == ref;

  @override
  int get hashCode => ref.hashCode;
}

/// The middle of a segment of the selected feature, where a new vertex can be
/// inserted. [ref] is the index the inserted vertex takes.
class GeoMidpointTarget extends GeoTarget {
  final GeoVertexRef ref;
  final LatLng position;

  const GeoMidpointTarget(this.ref, this.position);

  @override
  bool operator ==(Object other) =>
      other is GeoMidpointTarget && other.ref == ref;

  @override
  int get hashCode => ref.hashCode;
}

/// A vertex of the shape being drawn. Clicking the first one closes the shape.
class GeoDraftVertexTarget extends GeoTarget {
  final int index;

  const GeoDraftVertexTarget(this.index);

  @override
  bool operator ==(Object other) =>
      other is GeoDraftVertexTarget && other.index == index;

  @override
  int get hashCode => index.hashCode;
}

/// Resolves what is under the pointer, in screen space so that the tolerances
/// stay the same at every zoom level.
class GeoHitTester {
  /// Radius around a vertex handle that still counts as a hit.
  static const vertexRadius = 11.0;

  /// Radius around a midpoint handle that still counts as a hit.
  static const midpointRadius = 9.0;

  /// Size of the clickable area of a point marker, which sits above its
  /// coordinate.
  static const markerSize = 30.0;

  /// Distance from an outline that still counts as a hit.
  static const outlineTolerance = 8.0;

  /// Midpoint handles are only drawn on segments long enough to not clutter
  /// the vertex handles they sit between.
  static const minMidpointDistance = 36.0;

  final MapCamera camera;
  final GeoEditorState state;

  const GeoHitTester({required this.camera, required this.state});

  Offset _screen(LatLng position) => camera.latLngToScreenOffset(position);

  /// The topmost target at [point], `null` if there is nothing there.
  ///
  /// Handles of the selected feature take precedence over feature bodies, and
  /// features drawn later take precedence over earlier ones. Pass `false` for
  /// [handles] to only look for feature bodies, as a read-only editor draws no
  /// handles to hit.
  GeoTarget? hitTest(Offset point, {bool handles = true}) {
    final draft = state.draft;
    if (draft != null) {
      for (final (index, vertex) in draft.vertices.indexed) {
        if ((_screen(vertex.position) - point).distance <= vertexRadius) {
          return GeoDraftVertexTarget(index);
        }
      }

      return null;
    }

    final selected = state.selectedFeature;
    final selection = state.selection;
    if (handles && selected != null && selection != null) {
      final handle = _hitTestHandles(point, selected, selection);
      if (handle != null) {
        return handle;
      }
    }

    return _hitTestFeatures(point);
  }

  GeoTarget? _hitTestHandles(Offset point, int index, GeoFeature feature) {
    for (final (part, vertices) in feature.parts.indexed) {
      for (final (vertex, value) in vertices.indexed) {
        if ((_screen(value.position) - point).distance <= vertexRadius) {
          return GeoVertexTarget(GeoVertexRef(index, part, vertex));
        }
      }
    }

    for (final (ref, middle) in midpointsOf(index, feature)) {
      if ((_screen(middle) - point).distance <= midpointRadius) {
        return GeoMidpointTarget(ref, middle);
      }
    }

    return null;
  }

  GeoFeatureTarget? _hitTestFeatures(Offset point) {
    final features = state.document.features;
    for (final (index, feature) in features.indexed.toList().reversed) {
      final hit = switch (feature) {
        GeoPointFeature(:final vertex) => _hitTestMarker(
          point,
          _screen(vertex.position),
        ),
        GeoLineFeature(:final points) => _hitTestOutline(
          point,
          points.map((e) => _screen(e.position)).toList(),
          closed: false,
        ),
        GeoPolygonFeature() => _hitTestPolygon(point, feature),
      };

      if (hit) {
        return GeoFeatureTarget(index);
      }
    }

    return null;
  }

  /// Point markers are drawn above their coordinate, so their clickable area
  /// is the box the pin occupies rather than a radius around the coordinate.
  bool _hitTestMarker(Offset point, Offset anchor) => Rect.fromLTWH(
    anchor.dx - markerSize / 2,
    anchor.dy - markerSize,
    markerSize,
    markerSize,
  ).contains(point);

  bool _hitTestPolygon(Offset point, GeoPolygonFeature feature) {
    final rings = [
      for (final ring in feature.rings)
        ring.map((e) => _screen(e.position)).toList(),
    ];

    for (final ring in rings) {
      if (_hitTestOutline(point, ring, closed: true)) {
        return true;
      }
    }

    if (!_isInside(rings.first, point)) {
      return false;
    }

    return !rings.skip(1).any((hole) => _isInside(hole, point));
  }

  bool _hitTestOutline(
    Offset point,
    List<Offset> outline, {
    required bool closed,
  }) {
    if (outline.length < 2) {
      return false;
    }

    final segments = closed ? outline.length : outline.length - 1;
    for (var i = 0; i < segments; i++) {
      final distance = _distanceToSegment(
        point,
        outline[i],
        outline[(i + 1) % outline.length],
      );

      if (distance <= outlineTolerance) {
        return true;
      }
    }

    return false;
  }

  /// Even-odd rule against the projected ring.
  static bool _isInside(List<Offset> ring, Offset point) {
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final a = ring[i];
      final b = ring[j];
      if ((a.dy > point.dy) != (b.dy > point.dy) &&
          point.dx < (b.dx - a.dx) * (point.dy - a.dy) / (b.dy - a.dy) + a.dx) {
        inside = !inside;
      }
    }

    return inside;
  }

  static double _distanceToSegment(Offset point, Offset from, Offset to) {
    final segment = to - from;
    final lengthSquared = segment.distanceSquared;
    if (lengthSquared == 0) {
      return (point - from).distance;
    }

    final relative = point - from;
    final t =
        ((relative.dx * segment.dx + relative.dy * segment.dy) / lengthSquared)
            .clamp(0.0, 1.0);

    return (point - (from + segment * t)).distance;
  }

  /// The midpoints of [feature] that get a handle, indexed by the position an
  /// inserted vertex would take.
  Iterable<(GeoVertexRef, LatLng)> midpointsOf(
    int index,
    GeoFeature feature,
  ) sync* {
    for (final (part, vertices) in feature.parts.indexed) {
      if (vertices.length < 2) {
        continue;
      }

      for (var segment = 0; segment < feature.segmentCount(part); segment++) {
        final from = _screen(vertices[segment].position);
        final to = _screen(vertices[(segment + 1) % vertices.length].position);
        if ((from - to).distance < minMidpointDistance) {
          continue;
        }

        yield (
          GeoVertexRef(index, part, segment + 1),
          camera.screenOffsetToLatLng((from + to) / 2),
        );
      }
    }
  }

  /// Where a handle grabbed at [grab] ends up when the pointer is at [point],
  /// clamped to the map so that a handle cannot be dragged out of sight.
  LatLng draggedPosition(Offset point, Offset grab, Size size) {
    final target = Offset(
      (point.dx + grab.dx).clamp(0.0, max(0.0, size.width)),
      (point.dy + grab.dy).clamp(0.0, max(0.0, size.height)),
    );

    return camera.screenOffsetToLatLng(target);
  }
}
