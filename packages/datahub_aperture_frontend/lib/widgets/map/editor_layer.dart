import 'dart:math';

import 'package:datahub/data.dart' as data;
import 'package:datahub_aperture_frontend/widgets/map/utils.dart';
import 'package:datahub_aperture_frontend/widgets/utils/immutable_list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart' hide Path;

import 'editor_controls.dart';
import 'polygon_editor.dart';
import 'polygon_painter.dart';
import 'ring_creator.dart';

class EditorPolygon {
  final List<LatLng> bounds;
  final List<List<LatLng>> holes;

  EditorPolygon({
    required Iterable<LatLng> bounds,
    Iterable<Iterable<LatLng>> holes = const [],
  }) : bounds = List.unmodifiable(bounds),
       holes = List.unmodifiable(holes);

  EditorPolygon copyWith({
    Iterable<LatLng>? bounds,
    Iterable<List<LatLng>>? holes,
  }) =>
      EditorPolygon(bounds: bounds ?? this.bounds, holes: holes ?? this.holes);

  static bool _isPointInside(List<List<LatLng>> rings, LatLng point) {
    final pt = convertToWebMercator(point.longitude, point.latitude);
    final coords = <List<List<double>>>[];
    for (final ring in rings) {
      final transformedRing = <List<double>>[];

      for (final point in ring) {
        final List<double> transformedPoint = convertToWebMercator(
          point.longitude,
          point.latitude,
        );
        transformedRing.add(transformedPoint);
      }

      coords.add(transformedRing);
    }
    var outer = coords.first;
    bool inside = false;
    for (int i = 0, j = outer.length - 1; i < outer.length; j = i++) {
      if (((outer[i][1] > pt[1]) != (outer[j][1] > pt[1])) &&
          (pt[0] <
              (outer[j][0] - outer[i][0]) *
                      (pt[1] - outer[i][1]) /
                      (outer[j][1] - outer[i][1]) +
                  outer[i][0])) {
        inside = !inside;
      }
    }
    return inside;
  }

  bool isPointInside(LatLng point) {
    if (bounds.isNotEmpty && LatLngBounds.fromPoints(bounds).contains(point)) {
      return _isPointInside([bounds], point);
    }

    return false;
  }

  data.Polygon toGeometry() {
    return data.Polygon(
      data.wgs84,
      [
        for (final ring in [bounds, ...holes])
          data.LineString(
            data.wgs84,
            [
              for (final point in ring.followedBy([ring.first]))
                data.Point(data.wgs84, point.longitude, point.latitude),
            ],
            false,
            false,
          ),
      ],
      false,
      false,
    );
  }
}

class EditorLayer extends StatefulWidget {
  final List<EditorPolygon> features;
  final ValueChanged<List<EditorPolygon>>? onChanged;

  const EditorLayer({
    super.key,
    required this.features,
    required this.onChanged,
  });

  @override
  State<EditorLayer> createState() => _EditorLayerState();
}

enum EditorMode { select, edit, create }

class _EditorLayerState extends State<EditorLayer> {
  int selected = -1;
  EditorMode mode = EditorMode.select;

  @override
  void didUpdateWidget(covariant EditorLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.features != oldWidget.features) {
      if (selected >= widget.features.length) {
        selected = -1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = MapController.of(context) as MapControllerImpl;
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => setState(() {
            mode = EditorMode.select;
            selected = -1;
          }),
        ),

        for (final (idx, feature) in widget.features.indexed)
          PolygonPainter(
            polygon: feature,
            onSelect: () {
              setState(() {
                mode = EditorMode.edit;
                selected = idx;
              });
            },
          ),

        if (widget.onChanged != null) ...[
          if (mode == EditorMode.edit &&
              min(widget.features.length - 1, selected) >= 0)
            PolygonEditor(
              value: widget.features[min(widget.features.length - 1, selected)],
              onChanged: (value) {
                if (value == null) {
                  widget.onChanged?.call(
                    widget.features.copyWithRemoved(selected),
                  );
                  setState(() {
                    selected = -1;
                  });
                } else {
                  widget.onChanged?.call(
                    widget.features.copyWithReplaced(selected, value),
                  );
                }
              },
            ),

          if (mode == EditorMode.create)
            RingCreator(
              onDone: (ring) {
                widget.onChanged?.call(
                  widget.features.copyWithAdded(EditorPolygon(bounds: ring)),
                );
                setState(() {
                  mode = EditorMode.edit;
                  selected = widget.features.length;
                });
              },
              onCancel: () {
                setState(() {
                  mode = EditorMode.select;
                  selected = -1;
                });
              },
            ),
        ],
        EditorControls(
          readOnly: widget.onChanged == null,
          mode: mode,
          onFocusPressed: () => controller.focusOnAll(widget.features),
          onAddPressed: () {
            setState(() {
              mode = EditorMode.create;
            });
          },
          onCancelPressed: () {
            setState(() {
              mode = EditorMode.select;
            });
          },
          onCutPressed: () {
            setState(() {});
          },
        ),
      ],
    );
  }
}
