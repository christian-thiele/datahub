import 'package:datahub_aperture_frontend/blocs/geo_editor/geo_editor_cubit.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/geo_editor_style.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Draws the features of the edited value and the shape being drawn.
///
/// Point features are drawn as pins above their coordinate, everything else as
/// filled polygons and strokes underneath them.
class GeoFeatureLayer extends StatelessWidget {
  final GeoEditorState state;

  /// The feature the pointer is over, drawn as if it was selected.
  final int? highlighted;

  const GeoFeatureLayer({super.key, required this.state, this.highlighted});

  bool _isActive(int index) =>
      index == state.selectedFeature || index == highlighted;

  @override
  Widget build(BuildContext context) {
    final style = GeoEditorStyle.of(context);
    final features = state.document.features;

    return Stack(
      children: [
        PolygonLayer(
          polygons: [
            for (final (index, feature) in features.indexed)
              if (feature is GeoPolygonFeature)
                _polygonOf(feature, style, selected: _isActive(index)),
          ],
        ),
        PolylineLayer(
          polylines: [
            for (final (index, feature) in features.indexed)
              if (feature is GeoLineFeature)
                _lineOf(feature, style, selected: _isActive(index)),
          ],
        ),
        ..._draftLayers(style),
        MarkerLayer(
          markers: [
            for (final (index, feature) in features.indexed)
              if (feature is GeoPointFeature)
                Marker(
                  point: feature.vertex.position,
                  width: GeoEditorStyle.markerSize,
                  height: GeoEditorStyle.markerSize,
                  alignment: Alignment.topCenter,
                  child: _PointMarker(
                    color: style.strokeOf(selected: _isActive(index)),
                    selected: _isActive(index),
                  ),
                ),
          ],
        ),
      ],
    );
  }

  Polygon _polygonOf(
    GeoPolygonFeature feature,
    GeoEditorStyle style, {
    required bool selected,
  }) => Polygon(
    points: feature.outerRing.map((e) => e.position).toList(),
    holePointsList: [
      for (final hole in feature.holes) hole.map((e) => e.position).toList(),
    ],
    color: style.fillOf(selected: selected),
    borderColor: style.strokeOf(selected: selected),
    borderStrokeWidth: style.strokeWidthOf(selected: selected),
  );

  Polyline _lineOf(
    GeoLineFeature feature,
    GeoEditorStyle style, {
    required bool selected,
  }) => Polyline(
    points: feature.points.map((e) => e.position).toList(),
    color: style.strokeOf(selected: selected),
    strokeWidth: style.strokeWidthOf(selected: selected) + 1,
    borderColor: style.handle.withAlpha(120),
    borderStrokeWidth: 1,
  );

  /// The shape being drawn, including the segment from the last placed vertex
  /// to the pointer.
  List<Widget> _draftLayers(GeoEditorStyle style) {
    final draft = state.draft;
    if (draft == null) {
      return const [];
    }

    final points = [
      ...draft.vertices.map((e) => e.position),
      if (state.cursor case final cursor?) cursor,
    ];

    if (points.length < 2) {
      return const [];
    }

    return [
      if (draft.isClosed)
        PolygonLayer(
          polygons: [
            Polygon(
              points: points,
              color: style.draftFill,
              borderColor: style.draft,
              borderStrokeWidth: GeoEditorStyle.selectedStrokeWidth,
              pattern: GeoEditorStyle.draftPattern,
            ),
          ],
        )
      else
        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              color: style.draft,
              strokeWidth: GeoEditorStyle.selectedStrokeWidth,
              pattern: GeoEditorStyle.draftPattern,
            ),
          ],
        ),
    ];
  }
}

class _PointMarker extends StatelessWidget {
  final Color color;
  final bool selected;

  const _PointMarker({required this.color, required this.selected});

  @override
  Widget build(BuildContext context) => Icon(
    selected ? Icons.place : Icons.place_outlined,
    size: GeoEditorStyle.markerSize,
    color: color,
    shadows: [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow.withAlpha(60),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );
}
