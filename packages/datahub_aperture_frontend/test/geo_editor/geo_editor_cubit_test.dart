import 'package:datahub/data.dart' as data;
import 'package:datahub_aperture_frontend/blocs/geo_editor/geo_editor_cubit.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_feature.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_type_restriction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

GeoEditorCubit _cubit({
  GeoTypeRestriction restriction = const GeoTypeRestriction.any(),
  data.Geometry? value,
}) => GeoEditorCubit(restriction: restriction, value: value);

/// Draws a shape of [kind] with [positions] and finishes it.
void _draw(GeoEditorCubit cubit, GeoEditorTool tool, List<LatLng> positions) {
  cubit.selectTool(tool);
  positions.forEach(cubit.addAt);
  cubit.completeDraft();
}

final _square = [LatLng(0, 0), LatLng(0, 1), LatLng(1, 1), LatLng(1, 0)];

void main() {
  group('drawing', () {
    test('collects vertices into a polygon', () {
      final cubit = _cubit();
      cubit.selectTool(GeoEditorTool.polygon);

      cubit.addAt(_square[0]);
      expect(cubit.state.draft?.vertices, hasLength(1));
      expect(cubit.state.draft?.canComplete, isFalse);

      cubit.addAt(_square[1]);
      cubit.addAt(_square[2]);
      expect(cubit.state.draft?.canComplete, isTrue);

      cubit.completeDraft();
      expect(cubit.state.draft, isNull);
      expect(cubit.state.tool, GeoEditorTool.select);
      expect(cubit.state.document.features.single, isA<GeoPolygonFeature>());
      expect(cubit.state.selectedFeature, 0);
    });

    test('refuses to finish a shape with too few vertices', () {
      final cubit = _cubit();
      cubit.selectTool(GeoEditorTool.line);
      cubit.addAt(_square[0]);
      cubit.completeDraft();

      expect(cubit.state.draft, isNotNull);
      expect(cubit.state.document.features, isEmpty);
    });

    test('undoing the last vertex cancels an empty draft', () {
      final cubit = _cubit();
      cubit.selectTool(GeoEditorTool.polygon);
      cubit.addAt(_square[0]);
      cubit.addAt(_square[1]);

      cubit.removeLastDraftVertex();
      expect(cubit.state.draft?.vertices, hasLength(1));

      cubit.removeLastDraftVertex();
      expect(cubit.state.draft, isNull);
      expect(cubit.state.tool, GeoEditorTool.select);
    });

    test('places a point per click and stays in the tool', () {
      final cubit = _cubit();
      cubit.selectTool(GeoEditorTool.point);
      cubit.addAt(_square[0]);
      cubit.addAt(_square[1]);

      expect(cubit.state.tool, GeoEditorTool.point);
      expect(cubit.state.document.features, hasLength(2));
    });

    test('leaves the point tool when no further point fits', () {
      final cubit = _cubit(
        restriction: GeoTypeRestriction.only(data.GeometryType.point),
      );

      cubit.selectTool(GeoEditorTool.point);
      cubit.addAt(_square[0]);
      expect(cubit.state.tool, GeoEditorTool.select);

      cubit.addAt(_square[1]);
      expect(cubit.state.document.features, hasLength(1));
    });

    test('pressing the active tool again cancels drawing', () {
      final cubit = _cubit();
      cubit.selectTool(GeoEditorTool.polygon);
      cubit.addAt(_square[0]);
      cubit.selectTool(GeoEditorTool.polygon);

      expect(cubit.state.tool, GeoEditorTool.select);
      expect(cubit.state.draft, isNull);
    });

    test('ignores tools the restriction does not allow', () {
      final cubit = _cubit(
        restriction: GeoTypeRestriction.only(data.GeometryType.polygon),
      );

      cubit.selectTool(GeoEditorTool.point);
      expect(cubit.state.tool, GeoEditorTool.select);
    });

    test('only previews the cursor while drawing', () {
      final cubit = _cubit();
      cubit.moveCursor(LatLng(5, 5));
      expect(cubit.state.cursor, isNull);

      cubit.selectTool(GeoEditorTool.line);
      cubit.addAt(_square[0]);
      cubit.moveCursor(LatLng(5, 5));
      expect(cubit.state.cursor, LatLng(5, 5));
    });
  });

  group('holes', () {
    GeoEditorCubit withPolygon() {
      final cubit = _cubit();
      _draw(cubit, GeoEditorTool.polygon, _square);
      return cubit;
    }

    test('are drawn into the selected polygon', () {
      final cubit = withPolygon();
      cubit.selectFeature(0);
      cubit.selectTool(GeoEditorTool.hole);

      cubit.addAt(LatLng(0.2, 0.2));
      cubit.addAt(LatLng(0.2, 0.4));
      cubit.addAt(LatLng(0.4, 0.4));
      cubit.completeDraft();

      final polygon = cubit.state.document.features.single;
      expect(polygon.parts, hasLength(2));
      expect(cubit.state.document.features, hasLength(1));
    });

    test('need a selected polygon', () {
      final cubit = withPolygon();
      cubit.selectFeature(null);
      cubit.selectTool(GeoEditorTool.hole);

      expect(cubit.state.tool, GeoEditorTool.select);
    });
  });

  group('editing', () {
    GeoEditorCubit withSquare() {
      final cubit = _cubit();
      _draw(cubit, GeoEditorTool.polygon, _square);
      return cubit;
    }

    test('moves a vertex', () {
      final cubit = withSquare();
      cubit.moveVertex(const GeoVertexRef(0, 0, 1), LatLng(9, 9));

      expect(
        cubit.state.document.features.single.parts.single[1].position,
        LatLng(9, 9),
      );
    });

    test('inserts a vertex and selects it', () {
      final cubit = withSquare();
      cubit.insertVertex(const GeoVertexRef(0, 0, 2), LatLng(0.5, 1));

      expect(cubit.state.document.features.single.vertexCount, 5);
      expect(cubit.state.selectedVertex, const GeoVertexRef(0, 0, 2));
    });

    test('removes the feature when a vertex removal degenerates it', () {
      final cubit = _cubit();
      _draw(cubit, GeoEditorTool.polygon, _square.take(3).toList());

      cubit.removeVertex(const GeoVertexRef(0, 0, 0));

      expect(cubit.state.document.features, isEmpty);
      expect(cubit.state.selectedFeature, isNull);
    });

    test('deletes the selected vertex before the selected feature', () {
      final cubit = withSquare();
      cubit.selectVertex(const GeoVertexRef(0, 0, 0));
      cubit.removeSelection();

      expect(cubit.state.document.features.single.vertexCount, 3);

      cubit.removeSelection();
      expect(cubit.state.document.features, isEmpty);
    });

    test(
      'keeps the selection on the same feature when an earlier one goes',
      () {
        final cubit = _cubit();
        cubit.selectTool(GeoEditorTool.point);
        cubit.addAt(_square[0]);
        cubit.addAt(_square[1]);
        cubit.selectFeature(1);

        cubit.removeFeature(0);

        expect(cubit.state.selectedFeature, 0);
        expect(
          (cubit.state.selection as GeoPointFeature).vertex.position,
          _square[1],
        );
      },
    );
  });

  test('replacing the value discards what is in progress', () {
    final cubit = _cubit();
    cubit.selectTool(GeoEditorTool.polygon);
    cubit.addAt(_square[0]);

    cubit.setValue(data.Point(data.wgs84, 1, 2));

    expect(cubit.state.draft, isNull);
    expect(cubit.state.document.features.single, isA<GeoPointFeature>());
    expect(cubit.state.selectedFeature, isNull);
  });
}
