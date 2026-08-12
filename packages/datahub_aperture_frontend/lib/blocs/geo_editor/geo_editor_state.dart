part of 'geo_editor_cubit.dart';

/// What a click on the map does.
enum GeoEditorTool {
  /// Picks features, vertices and midpoints.
  select,

  /// Places a point feature per click.
  point,

  /// Collects the vertices of a new line.
  line,

  /// Collects the vertices of a new polygon.
  polygon,

  /// Collects the vertices of a hole inside the selected polygon.
  hole;

  GeoFeatureKind? get kind => switch (this) {
    GeoEditorTool.select => null,
    GeoEditorTool.point => GeoFeatureKind.point,
    GeoEditorTool.line => GeoFeatureKind.line,
    GeoEditorTool.polygon || GeoEditorTool.hole => GeoFeatureKind.polygon,
  };

  bool get isDrawing => this != GeoEditorTool.select;

  static GeoEditorTool of(GeoFeatureKind kind) => switch (kind) {
    GeoFeatureKind.point => GeoEditorTool.point,
    GeoFeatureKind.line => GeoEditorTool.line,
    GeoFeatureKind.polygon => GeoEditorTool.polygon,
  };
}

/// The shape currently being drawn.
@immutable
class GeoDraft {
  final GeoFeatureKind kind;
  final List<GeoVertex> vertices;

  /// The polygon a hole is drawn into, `null` while drawing a new feature.
  final int? hostFeature;

  GeoDraft({
    required this.kind,
    required Iterable<GeoVertex> vertices,
    this.hostFeature,
  }) : vertices = List.unmodifiable(vertices);

  /// Whether the drawn vertices describe a ring.
  bool get isClosed => kind == GeoFeatureKind.polygon;

  int get minVertices => switch (kind) {
    GeoFeatureKind.point => 1,
    GeoFeatureKind.line => 2,
    GeoFeatureKind.polygon => 3,
  };

  bool get canComplete => vertices.length >= minVertices;

  GeoDraft append(LatLng position) => GeoDraft(
    kind: kind,
    vertices: [...vertices, GeoVertex(position)],
    hostFeature: hostFeature,
  );

  GeoDraft removeLast() => GeoDraft(
    kind: kind,
    vertices: vertices.take(max(0, vertices.length - 1)),
    hostFeature: hostFeature,
  );

  @override
  bool operator ==(Object other) =>
      other is GeoDraft &&
      other.kind == kind &&
      other.hostFeature == hostFeature &&
      other.vertices.sequenceEquals(vertices);

  @override
  int get hashCode => Object.hash(kind, hostFeature, Object.hashAll(vertices));
}

@immutable
class GeoEditorState {
  final GeoDocument document;
  final GeoEditorTool tool;

  /// The feature the handles are shown for.
  final int? selectedFeature;

  /// The vertex within [selectedFeature] that keyboard actions apply to.
  final GeoVertexRef? selectedVertex;

  final GeoDraft? draft;

  /// The last known map position of the pointer, used to preview the segment
  /// that a click would add to [draft].
  final LatLng? cursor;

  /// Whether a handle is being dragged, during which the value changes with
  /// every pointer move and is not worth reporting yet.
  final bool isDragging;

  const GeoEditorState({
    required this.document,
    this.tool = GeoEditorTool.select,
    this.selectedFeature,
    this.selectedVertex,
    this.draft,
    this.cursor,
    this.isDragging = false,
  });

  GeoFeature? get selection => document.featureAt(selectedFeature);

  bool get hasSelection => selection != null;

  GeoEditorState copyWith({
    GeoDocument? document,
    GeoEditorTool? tool,
    int? selectedFeature,
    GeoVertexRef? selectedVertex,
    GeoDraft? draft,
    LatLng? cursor,
    bool? isDragging,
    bool clearSelectedFeature = false,
    bool clearSelectedVertex = false,
    bool clearDraft = false,
    bool clearCursor = false,
  }) => GeoEditorState(
    document: document ?? this.document,
    tool: tool ?? this.tool,
    selectedFeature: clearSelectedFeature
        ? null
        : selectedFeature ?? this.selectedFeature,
    selectedVertex: clearSelectedVertex
        ? null
        : selectedVertex ?? this.selectedVertex,
    draft: clearDraft ? null : draft ?? this.draft,
    cursor: clearCursor ? null : cursor ?? this.cursor,
    isDragging: isDragging ?? this.isDragging,
  );

  @override
  bool operator ==(Object other) =>
      other is GeoEditorState &&
      other.document == document &&
      other.tool == tool &&
      other.selectedFeature == selectedFeature &&
      other.selectedVertex == selectedVertex &&
      other.draft == draft &&
      other.cursor == cursor &&
      other.isDragging == isDragging;

  @override
  int get hashCode => Object.hash(
    document,
    tool,
    selectedFeature,
    selectedVertex,
    draft,
    cursor,
    isDragging,
  );
}
