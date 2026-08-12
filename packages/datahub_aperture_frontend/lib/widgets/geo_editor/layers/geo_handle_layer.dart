import 'package:datahub_aperture_frontend/blocs/geo_editor/geo_editor_cubit.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/geo_editor_style.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/geo_hit_test.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Draws the handles of the selected feature and of the shape being drawn.
///
/// The handles are decoration only, all pointer handling happens in the
/// editor's gesture layer.
class GeoHandleLayer extends StatelessWidget {
  final GeoEditorState state;

  /// The handle the pointer is over, drawn enlarged.
  final GeoTarget? highlighted;

  const GeoHandleLayer({super.key, required this.state, this.highlighted});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final style = GeoEditorStyle.of(context);
    final tester = GeoHitTester(camera: camera, state: state);
    final viewport = Offset.zero & camera.nonRotatedSize;

    return IgnorePointer(
      child: Stack(
        children: [
          ..._draftHandles(camera, style, viewport),
          ..._selectionHandles(camera, style, tester, viewport),
        ],
      ),
    );
  }

  Iterable<Widget> _draftHandles(
    MapCamera camera,
    GeoEditorStyle style,
    Rect viewport,
  ) sync* {
    final draft = state.draft;
    if (draft == null) {
      return;
    }

    for (final (index, vertex) in draft.vertices.indexed) {
      final offset = camera.latLngToScreenOffset(vertex.position);
      if (!viewport.inflate(GeoEditorStyle.markerSize).contains(offset)) {
        continue;
      }

      // The first vertex closes the shape, so it stays grabbable in size.
      final closes = index == 0 && draft.canComplete;
      yield _positioned(
        offset,
        GeoEditorStyle.vertexSize + (closes ? 3 : 0),
        _Handle(
          color: closes ? style.draft : style.handle,
          borderColor: style.draft,
          active: highlighted == GeoDraftVertexTarget(index),
        ),
      );
    }
  }

  Iterable<Widget> _selectionHandles(
    MapCamera camera,
    GeoEditorStyle style,
    GeoHitTester tester,
    Rect viewport,
  ) sync* {
    final index = state.selectedFeature;
    final feature = state.selection;
    if (index == null || feature == null || state.draft != null) {
      return;
    }

    for (final (ref, position) in tester.midpointsOf(index, feature)) {
      final offset = camera.latLngToScreenOffset(position);
      if (!viewport.contains(offset)) {
        continue;
      }

      yield _positioned(
        offset,
        GeoEditorStyle.midpointSize,
        _Handle(
          color: style.handle.withAlpha(170),
          borderColor: style.handleBorder.withAlpha(170),
          active: highlighted == GeoMidpointTarget(ref, position),
        ),
      );
    }

    for (final (part, vertices) in feature.parts.indexed) {
      for (final (vertex, value) in vertices.indexed) {
        final offset = camera.latLngToScreenOffset(value.position);
        if (!viewport.inflate(GeoEditorStyle.vertexSize).contains(offset)) {
          continue;
        }

        final ref = GeoVertexRef(index, part, vertex);
        yield _positioned(
          offset,
          GeoEditorStyle.vertexSize,
          _Handle(
            color: style.handle,
            borderColor: style.handleBorder,
            active:
                highlighted == GeoVertexTarget(ref) ||
                state.selectedVertex == ref,
          ),
        );
      }
    }
  }

  Widget _positioned(Offset offset, double size, Widget child) => Positioned(
    left: offset.dx - size / 2,
    top: offset.dy - size / 2,
    width: size,
    height: size,
    child: child,
  );
}

class _Handle extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final bool active;

  const _Handle({
    required this.color,
    required this.borderColor,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 80),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: Border.all(
        strokeAlign: BorderSide.strokeAlignOutside,
        color: borderColor,
        width: active ? 3 : 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withAlpha(40),
          blurRadius: 2,
        ),
      ],
    ),
  );
}
