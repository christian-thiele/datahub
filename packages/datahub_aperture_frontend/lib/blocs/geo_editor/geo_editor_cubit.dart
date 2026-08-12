import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:boost/boost.dart';
import 'package:datahub/data.dart' as data;
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_document.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_feature.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_type_restriction.dart';
import 'package:datahub_aperture_frontend/widgets/utils/immutable_list_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

part 'geo_editor_state.dart';

/// Editing state of the geo editor.
///
/// Everything that needs the map camera to be resolved (which feature is under
/// the pointer, where a click lands) is done by the editor widgets, the cubit
/// only deals with the resulting geographic operations.
class GeoEditorCubit extends Cubit<GeoEditorState> {
  /// The geometry types the edited value may take, which decides what can be
  /// drawn on top of what is already there.
  final GeoTypeRestriction restriction;

  GeoEditorCubit({required this.restriction, data.Geometry? value})
    : super(GeoEditorState(document: GeoDocument.fromGeometry(value)));

  /// Replaces the edited value, dropping everything in progress.
  void setValue(data.Geometry? value) => emit(
    GeoEditorState(
      document: GeoDocument.fromGeometry(value),
      tool: state.tool == GeoEditorTool.hole
          ? GeoEditorTool.select
          : state.tool,
    ),
  );

  /// Activates [tool], or returns to [GeoEditorTool.select] if it already is
  /// the active one.
  void selectTool(GeoEditorTool tool) {
    if (tool == state.tool) {
      return cancelDraft();
    }

    if (tool == GeoEditorTool.hole && state.selection is! GeoPolygonFeature) {
      return;
    }

    final kind = tool.kind;
    if (tool != GeoEditorTool.hole &&
        kind != null &&
        !restriction.canAdd(kind, state.document.features)) {
      return;
    }

    emit(
      state.copyWith(
        tool: tool,
        clearDraft: true,
        clearCursor: true,
        clearSelectedVertex: true,
        clearSelectedFeature: tool != GeoEditorTool.hole,
      ),
    );
  }

  void selectFeature(int? index) => emit(
    state.copyWith(
      selectedFeature: index,
      clearSelectedFeature: index == null,
      clearSelectedVertex: true,
      tool: state.tool == GeoEditorTool.hole ? GeoEditorTool.select : null,
    ),
  );

  void selectVertex(GeoVertexRef ref) =>
      emit(state.copyWith(selectedFeature: ref.feature, selectedVertex: ref));

  /// Tracks the pointer to preview the segment a click would add.
  void moveCursor(LatLng? position) {
    if (state.draft == null) {
      return;
    }

    emit(state.copyWith(cursor: position, clearCursor: position == null));
  }

  /// Handles a click on the map at [position] for the active tool.
  void addAt(LatLng position) {
    switch (state.tool) {
      case GeoEditorTool.select:
        return;
      case GeoEditorTool.point:
        _addFeature(GeoPointFeature.at(position));
      case GeoEditorTool.line:
      case GeoEditorTool.polygon:
      case GeoEditorTool.hole:
        _appendDraft(position);
    }
  }

  /// Turns the draft into a feature, if it has enough vertices.
  void completeDraft() {
    final draft = state.draft;
    if (draft == null || !draft.canComplete) {
      return;
    }

    final host = state.document.featureAt(draft.hostFeature);
    if (host case GeoPolygonFeature polygon) {
      final updated = polygon.addPart(draft.vertices);
      emit(
        state.copyWith(
          document: state.document.copyWith(
            features: state.document.features.copyWithReplaced(
              draft.hostFeature!,
              updated ?? polygon,
            ),
          ),
          tool: GeoEditorTool.select,
          selectedFeature: draft.hostFeature,
          clearDraft: true,
          clearCursor: true,
          clearSelectedVertex: true,
        ),
      );
      return;
    }

    final feature = switch (draft.kind) {
      GeoFeatureKind.point => GeoPointFeature(draft.vertices.first),
      GeoFeatureKind.line => GeoLineFeature(draft.vertices),
      GeoFeatureKind.polygon => GeoPolygonFeature([draft.vertices]),
    };

    emit(
      state.copyWith(
        document: state.document.copyWith(
          features: [...state.document.features, feature],
        ),
        tool: GeoEditorTool.select,
        selectedFeature: state.document.features.length,
        clearDraft: true,
        clearCursor: true,
        clearSelectedVertex: true,
      ),
    );
  }

  void cancelDraft() => emit(
    state.copyWith(
      tool: GeoEditorTool.select,
      clearDraft: true,
      clearCursor: true,
    ),
  );

  void removeLastDraftVertex() {
    final draft = state.draft;
    if (draft == null) {
      return;
    }

    if (draft.vertices.length <= 1) {
      return cancelDraft();
    }

    emit(state.copyWith(draft: draft.removeLast()));
  }

  /// Marks the start and end of a handle drag, so that listeners can wait for
  /// the value to settle instead of following every pointer move.
  void setDragging(bool value) => emit(state.copyWith(isDragging: value));

  void moveVertex(GeoVertexRef ref, LatLng position) {
    final feature = state.document.featureAt(ref.feature);
    if (feature == null) {
      return;
    }

    _replaceFeature(ref.feature, feature.moveVertex(ref, position));
  }

  void insertVertex(GeoVertexRef ref, LatLng position) {
    final feature = state.document.featureAt(ref.feature);
    if (feature == null) {
      return;
    }

    _replaceFeature(ref.feature, feature.insertVertex(ref, position));
    if (state.document.featureAt(ref.feature) != null) {
      selectVertex(ref);
    }
  }

  void removeVertex(GeoVertexRef ref) {
    final feature = state.document.featureAt(ref.feature);
    if (feature == null) {
      return;
    }

    _replaceFeature(ref.feature, feature.removeVertex(ref));
  }

  void removeFeature(int index) => _replaceFeature(index, null);

  /// Removes the selected vertex, or the selected feature if no single vertex
  /// is selected.
  void removeSelection() {
    final vertex = state.selectedVertex;
    if (vertex != null) {
      return removeVertex(vertex);
    }

    final feature = state.selectedFeature;
    if (feature != null) {
      return removeFeature(feature);
    }
  }

  void _addFeature(GeoFeature feature) {
    if (!restriction.canAdd(feature.kind, state.document.features)) {
      return;
    }

    final features = [...state.document.features, feature];
    emit(
      state.copyWith(
        document: state.document.copyWith(features: features),
        selectedFeature: features.length - 1,
        clearSelectedVertex: true,
        tool: restriction.canAdd(feature.kind, features)
            ? null
            : GeoEditorTool.select,
      ),
    );
  }

  void _appendDraft(LatLng position) {
    final draft = state.draft;
    if (draft != null) {
      emit(state.copyWith(draft: draft.append(position)));
      return;
    }

    final kind = state.tool.kind;
    if (kind == null) {
      return;
    }

    final isHole = state.tool == GeoEditorTool.hole;
    if (isHole && state.selection is! GeoPolygonFeature) {
      return;
    }

    if (!isHole && !restriction.canAdd(kind, state.document.features)) {
      return;
    }

    emit(
      state.copyWith(
        draft: GeoDraft(
          kind: kind,
          vertices: [GeoVertex(position)],
          hostFeature: isHole ? state.selectedFeature : null,
        ),
      ),
    );
  }

  /// Writes [feature] back to the document, removing it when the edit left it
  /// degenerate (indicated by a `null` feature).
  void _replaceFeature(int index, GeoFeature? feature) {
    final features = state.document.features;
    if (index < 0 || index >= features.length) {
      return;
    }

    if (feature == null) {
      final selected = state.selectedFeature;
      emit(
        state.copyWith(
          document: state.document.copyWith(
            features: features.copyWithRemoved(index),
          ),
          selectedFeature: selected != null && selected > index
              ? selected - 1
              : selected,
          clearSelectedFeature: selected == index,
          clearSelectedVertex: true,
          clearDraft: state.draft?.hostFeature == index,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        document: state.document.copyWith(
          features: features.copyWithReplaced(index, feature),
        ),
      ),
    );
  }
}
