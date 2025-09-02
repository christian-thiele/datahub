enum GeometryType {
  point(1),
  lineString(2),
  polygon(3),
  multiPoint(4),
  multiLineString(5),
  multiPolygon(6),
  geometryCollection(7);

  const GeometryType(this.id);

  final int id;

  static GeometryType read(int id) =>
      GeometryType.values.firstWhere((e) => e.id == id);
}
