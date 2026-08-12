import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' show StrokePattern;

/// Sizes and colours shared by the geo editor layers.
@immutable
class GeoEditorStyle {
  /// Diameter of a vertex handle.
  static const vertexSize = 11.0;

  /// Diameter of the handle that inserts a vertex into a segment.
  static const midpointSize = 8.0;

  /// Size of the pin a point feature is drawn as.
  static const markerSize = 30.0;

  static const strokeWidth = 2.0;
  static const selectedStrokeWidth = 3.0;

  /// Not `const` because the pattern asserts on its segments.
  static final draftPattern = StrokePattern.dashed(segments: const [7, 5]);

  final Color stroke;
  final Color selectedStroke;
  final Color fill;
  final Color selectedFill;
  final Color draft;
  final Color draftFill;
  final Color handle;
  final Color handleBorder;

  const GeoEditorStyle({
    required this.stroke,
    required this.selectedStroke,
    required this.fill,
    required this.selectedFill,
    required this.draft,
    required this.draftFill,
    required this.handle,
    required this.handleBorder,
  });

  factory GeoEditorStyle.of(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GeoEditorStyle(
      stroke: colors.primary.withAlpha(190),
      selectedStroke: colors.primary,
      fill: colors.primaryContainer.withAlpha(90),
      selectedFill: colors.primaryContainer.withAlpha(140),
      draft: colors.secondary,
      draftFill: colors.secondaryContainer.withAlpha(90),
      handle: colors.onPrimary,
      handleBorder: colors.primary,
    );
  }

  Color strokeOf({required bool selected}) =>
      selected ? selectedStroke : stroke;

  Color fillOf({required bool selected}) => selected ? selectedFill : fill;

  double strokeWidthOf({required bool selected}) =>
      selected ? selectedStrokeWidth : strokeWidth;
}
