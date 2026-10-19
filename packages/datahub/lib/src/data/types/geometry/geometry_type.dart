enum GeometryType(final int id) {
  point(1),
  lineString(2),
  polygon(3),
  multiPoint(4),
  multiLineString(5),
  multiPolygon(6),
  geometryCollection(7);

  static GeometryType read(int id) => GeometryType.values.firstWhere(
    (e) => e.id == id,
    orElse: () => throw FormatException('Unknown WKB geometry type: $id'),
  );
}
