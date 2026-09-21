// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aperture_map_tiles.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ApertureMapTiles with DataObject<ApertureMapTiles> {
  const $ApertureMapTiles();
  static const $$codec = JsonDataCodec();
  static final $urlTemplate = DataField<ApertureMapTiles, String>(
    name: 'urlTemplate',
    valueOf: (p) => p.urlTemplate,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $maxZoom = DataField<ApertureMapTiles, int?>(
    name: 'maxZoom',
    valueOf: (p) => p.maxZoom,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $attribution = DataField<ApertureMapTiles, String?>(
    name: 'attribution',
    valueOf: (p) => p.attribution,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<ApertureMapTiles> bean = DataBean<ApertureMapTiles>(
    name: 'ApertureMapTiles',
    fields: List<DataField<ApertureMapTiles, dynamic>>.unmodifiable([
      $urlTemplate,
      $maxZoom,
      $attribution,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ApertureMapTiles, dynamic>> get $$fields => bean.fields;
  ApertureMapTiles copyWith({
    String? urlTemplate,
    int? maxZoom,
    bool nullMaxZoom = false,
    String? attribution,
    bool nullAttribution = false,
  }) {
    final $data = this as ApertureMapTiles;
    return ApertureMapTiles(
      urlTemplate: urlTemplate ?? $data.urlTemplate,
      maxZoom: nullMaxZoom ? null : (maxZoom ?? $data.maxZoom),
      attribution: nullAttribution ? null : (attribution ?? $data.attribution),
    );
  }

  static ApertureMapTiles fromValues(Map<String, dynamic> data) {
    return ApertureMapTiles(
      urlTemplate: data['urlTemplate'],
      maxZoom: data['maxZoom'],
      attribution: data['attribution'],
    );
  }

  static ApertureMapTiles fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ApertureMapTiles,
        data.runtimeType,
        name,
      );
    }
    return ApertureMapTiles(
      urlTemplate: $urlTemplate.fromJson(
        data['urlTemplate'],
        name: DataCodec.childName(name, 'urlTemplate'),
      ),
      maxZoom: $maxZoom.fromJson(
        data['maxZoom'],
        name: DataCodec.childName(name, 'maxZoom'),
      ),
      attribution: $attribution.fromJson(
        data['attribution'],
        name: DataCodec.childName(name, 'attribution'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ApertureMapTiles;
    return {
      'urlTemplate': $urlTemplate.toJson($$data.urlTemplate),
      'maxZoom': $maxZoom.toJson($$data.maxZoom),
      'attribution': $attribution.toJson($$data.attribution),
    }..removeWhere((k, v) => v == null);
  }
}
