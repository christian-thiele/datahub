import 'package:datahub/data.dart' as data;
import 'package:datahub_aperture_frontend/widgets/geo_editor/geo_editor.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_type_restriction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

/// The map has to be laid out at a known origin, so that the offsets the test
/// taps at are the offsets the editor sees.
Widget _app(Widget child) => MaterialApp(
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 600, height: 400, child: child),
    ),
  ),
);

/// Long enough for the map's own double tap timers to run out, so that a test
/// does not end with one of them pending.
const _tapDelay = Duration(milliseconds: 300);

const _triangle = [Offset(100, 100), Offset(300, 120), Offset(200, 300)];

extension on WidgetTester {
  Future<void> tapMap(Offset position) async {
    await tapAt(position);
    await pump(_tapDelay);
  }

  Future<void> tapButton(String tooltip) async {
    await tap(find.byTooltip(tooltip));
    await pump();
  }

  Future<void> drawTriangle() async {
    await tapButton('Draw a polygon');
    for (final offset in _triangle) {
      await tapMap(offset);
    }
    await tapButton('Finish shape (Enter)');
  }

  MapControllerImpl get mapController =>
      widget<FlutterMap>(find.byType(FlutterMap)).mapController!
          as MapControllerImpl;

  IconButton button(String tooltip) => widget<IconButton>(
    find.ancestor(
      of: find.byTooltip(tooltip),
      matching: find.byType(IconButton),
    ),
  );
}

void main() {
  testWidgets('places a point on the frame after the tap', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.tapButton('Draw a point');
    await tester.tapAt(const Offset(200, 200));
    await tester.pump(const Duration(milliseconds: 16));

    expect(value, isA<data.Point>(), reason: 'no double tap window is waited');

    await tester.pump(_tapDelay);
  });

  testWidgets('draws a polygon from map taps', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.drawTriangle();

    expect(value, isA<data.Polygon>());
    final ring = (value! as data.Polygon).rings.single;
    expect(ring.points, hasLength(4), reason: 'ring is closed');
    expect(ring.points.first, ring.points.last);
  });

  testWidgets('closes a polygon by clicking its first vertex', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.tapButton('Draw a polygon');
    for (final offset in _triangle) {
      await tester.tapMap(offset);
    }
    await tester.tapMap(_triangle.first);

    expect(value, isA<data.Polygon>());
    expect((value! as data.Polygon).rings.single.points, hasLength(4));
  });

  testWidgets('finishes a line with the enter key', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.tapButton('Draw a line');
    await tester.tapMap(const Offset(120, 120));
    await tester.tapMap(const Offset(280, 260));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(value, isA<data.LineString>());
    expect((value! as data.LineString).points, hasLength(2));
  });

  testWidgets('moves a vertex by dragging its handle', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.drawTriangle();
    final before = (value! as data.Polygon).rings.single.points;

    await tester.dragFrom(_triangle.first, const Offset(60, 40));
    await tester.pump();

    final after = (value! as data.Polygon).rings.single.points;
    expect(after.first.x, greaterThan(before.first.x));
    expect(after.first.y, lessThan(before.first.y));
    expect(after[1], before[1], reason: 'other vertices stay put');
  });

  testWidgets('moves a vertex grabbed a moment before dragging', (
    tester,
  ) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.drawTriangle();
    final before = (value! as data.Polygon).rings.single.points;

    final gesture = await tester.startGesture(_triangle.first);
    await tester.pump(const Duration(seconds: 1));
    await gesture.moveBy(const Offset(60, 40));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    final after = (value! as data.Polygon).rings.single.points;
    expect(after.first.x, greaterThan(before.first.x));
    expect(after[1], before[1], reason: 'other vertices stay put');
  });

  testWidgets('adds a vertex by dragging a midpoint handle', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.drawTriangle();

    final middle = (_triangle[0] + _triangle[1]) / 2;
    await tester.dragFrom(middle, const Offset(0, -50));
    await tester.pump();

    final ring = (value! as data.Polygon).rings.single;
    expect(ring.points, hasLength(5));
    expect(ring.points[1].y, greaterThan(ring.points[0].y));
  });

  testWidgets('selects a vertex by clicking its handle', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.drawTriangle();
    expect(find.byTooltip('Delete selected shape (Del)'), findsOneWidget);

    await tester.tapMap(_triangle.first);

    expect(find.byTooltip('Delete selected point (Del)'), findsOneWidget);
    expect(value, isA<data.Polygon>(), reason: 'clicking does not edit');
  });

  testWidgets('adds a vertex by clicking a midpoint handle', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.drawTriangle();
    await tester.tapMap((_triangle[0] + _triangle[1]) / 2);

    expect((value! as data.Polygon).rings.single.points, hasLength(5));
  });

  testWidgets('drags on the map pan instead of editing', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.drawTriangle();
    final drawn = value;
    final center = tester.mapController.camera.center;

    // Inside the polygon, but not on any of its handles.
    await tester.dragFrom(const Offset(200, 180), const Offset(-60, 0));
    await tester.pump();

    expect(tester.mapController.camera.center, isNot(center));
    expect(value, drawn);
  });

  testWidgets('deletes the selected shape', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(_app(GeoEditor(onChanged: (v) => value = v)));
    await tester.pump();

    await tester.drawTriangle();
    expect(value, isNotNull);

    await tester.tapButton('Delete selected shape (Del)');

    expect(value, isNull);
  });

  testWidgets('only offers the tools the restriction allows', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(
      _app(
        GeoEditor(
          restriction: GeoTypeRestriction.only(data.GeometryType.point),
          onChanged: (v) => value = v,
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Draw a point'), findsOneWidget);
    expect(find.byTooltip('Draw a line'), findsNothing);
    expect(find.byTooltip('Draw a polygon'), findsNothing);

    await tester.tapButton('Draw a point');
    await tester.tapMap(const Offset(200, 200));

    expect(value, isA<data.Point>());
    expect(
      tester.button('Draw a point').onPressed,
      isNull,
      reason: 'a Point field holds a single point',
    );
  });

  testWidgets('keeps a restricted value in its multi type', (tester) async {
    data.Geometry? value;
    await tester.pumpWidget(
      _app(
        GeoEditor(
          restriction: GeoTypeRestriction.only(data.GeometryType.multiPoint),
          onChanged: (v) => value = v,
        ),
      ),
    );
    await tester.pump();

    await tester.tapButton('Draw a point');
    await tester.tapMap(const Offset(150, 150));
    expect(value, isA<data.MultiPoint>());

    await tester.tapMap(const Offset(350, 250));
    expect((value! as data.MultiPoint).points, hasLength(2));
  });

  testWidgets('offers nothing to edit without a change callback', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(GeoEditor(value: data.Point(data.wgs84, 11, 51))),
    );
    await tester.pump();

    expect(find.byTooltip('Draw a point'), findsNothing);
    expect(find.byTooltip('Zoom to geometry'), findsOneWidget);
  });
}
