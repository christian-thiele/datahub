import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:datahub/data.dart' as data;
import 'package:datahub_aperture_frontend/widgets/utils/immutable_list_utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';

part 'geo_editor_state.dart';

class GeoEditorCubit extends Cubit<GeoEditorState> {
  GeoEditorCubit({List<GeoPolygon> polygons = const []})
    : super(GeoEditorStateIdle(polygons: polygons));

  void startCreate() {
    if (state is GeoEditorStateIdle) {
      emit(
        GeoEditorStateCreatePolygon(
          polygons: state.polygons,
          creating: GeoPolygon([<LatLng>[]]),
          ringIndex: 0,
        ),
      );
    }
  }

  void cancelCreate() {
    if (state is GeoEditorStateCreatePolygon) {
      emit(GeoEditorStateIdle(polygons: state.polygons));
    }
  }

  void addVertex(LatLng vertex) {
    if (state case GeoEditorStateCreatePolygon(
      :final creating,
      :final polygons,
      :final ringIndex,
    )) {
      emit(
        GeoEditorStateCreatePolygon(
          polygons: polygons,
          creating: creating.replaceRing(
            ringIndex,
            creating.rings[ringIndex].copyWithAdded(vertex),
          ),
          ringIndex: ringIndex,
        ),
      );
    }
  }

  void selectVertex(int ringIndex, int vertexIndex) {
    if (state case GeoEditorStateEditPolygon(
      :final polygons,
      :final polygonIndex,
    )) {
      emit(
        GeoEditorStateEditPolygon(
          polygons: polygons,
          polygonIndex: polygonIndex,
          ringIndex: ringIndex,
          vertexIndex: vertexIndex,
        ),
      );
    }
  }

  void deleteVertex() {
    if (state case GeoEditorStateEditPolygon(
      :final polygons,
      :final polygonIndex,
      :final ringIndex,
      :final vertexIndex,
    )) {
      if (polygons[polygonIndex].rings[ringIndex].length > 3) {
        final updated = polygons[polygonIndex].replaceRing(
          ringIndex,
          polygons[polygonIndex].rings[ringIndex].copyWithRemoved(vertexIndex),
        );
        emit(
          GeoEditorStateEditPolygon(
            polygons: polygons.copyWithReplaced(polygonIndex, updated),
            polygonIndex: polygonIndex,
            ringIndex: ringIndex,
            vertexIndex: min(vertexIndex - 1, max(0, ringIndex)),
          ),
        );
      } else if (polygons[polygonIndex].rings.length > 1) {
        final updated = polygons[polygonIndex].removeRing(ringIndex);
        emit(
          GeoEditorStateEditPolygon(
            polygons: polygons.copyWithReplaced(polygonIndex, updated),
            polygonIndex: polygonIndex,
            ringIndex: min(polygons[polygonIndex].rings.length - 1, ringIndex),
            vertexIndex: ringIndex - 1,
          ),
        );
      } else {
        emit(
          GeoEditorStateIdle(polygons: polygons.copyWithRemoved(polygonIndex)),
        );
      }
    }
  }

  void unselect() {
    emit(GeoEditorStateIdle(polygons: state.polygons));
  }

  void selectPolygon(int idx) {
    if (state is GeoEditorStateIdle) {
      emit(
        GeoEditorStateEditPolygon(
          polygons: state.polygons,
          polygonIndex: idx,
          ringIndex: 0,
          vertexIndex: 0,
        ),
      );
    }
  }

  void addRing() {
    if (state case GeoEditorStateCreatePolygon(
      :final polygons,
      :final creating,
    )) {
      final updated = creating.addRing([]);
      emit(
        GeoEditorStateCreatePolygon(
          polygons: polygons,
          creating: updated,
          ringIndex: updated.rings.length - 1,
        ),
      );
    }
  }

  void completeCreate() {
    if (state case GeoEditorStateCreatePolygon(
      :final polygons,
      :final creating,
    )) {
      emit(GeoEditorStateIdle(polygons: [...polygons, creating]));
    }
  }
}
