import 'package:datahub/data.dart' as data;
import 'package:flutter/foundation.dart';

import 'geo_feature.dart';

/// The set of geometry types the editor is allowed to produce.
///
/// Field metadata does not carry the allowed types yet, so the editor is
/// constructed with [GeoTypeRestriction.any] until it does.
@immutable
class GeoTypeRestriction {
  final Set<data.GeometryType> allowedTypes;

  GeoTypeRestriction(Iterable<data.GeometryType> allowedTypes)
    : allowedTypes = Set.unmodifiable(allowedTypes);

  /// Allows every geometry type.
  const GeoTypeRestriction.any()
    : allowedTypes = const {
        data.GeometryType.point,
        data.GeometryType.lineString,
        data.GeometryType.polygon,
        data.GeometryType.multiPoint,
        data.GeometryType.multiLineString,
        data.GeometryType.multiPolygon,
        data.GeometryType.geometryCollection,
      };

  /// Allows a single geometry type.
  GeoTypeRestriction.only(data.GeometryType type) : this([type]);

  bool allows(data.GeometryType type) => allowedTypes.contains(type);

  bool get allowsCollection => allows(data.GeometryType.geometryCollection);

  /// Whether features of [kind] can be part of the value at all.
  bool allowsKind(GeoFeatureKind kind) =>
      allows(kind.singleType) || allows(kind.multiType) || allowsCollection;

  /// Whether the value can hold more than one feature of [kind].
  bool allowsMultiple(GeoFeatureKind kind) =>
      allows(kind.multiType) || allowsCollection;

  /// Whether the value can hold features of different kinds, which requires a
  /// geometry collection to represent.
  bool get allowsMixedKinds => allowsCollection;

  /// The kinds the editor offers a drawing tool for.
  List<GeoFeatureKind> get kinds =>
      GeoFeatureKind.values.where(allowsKind).toList();

  /// Whether another feature of [kind] may be added to [existing].
  bool canAdd(GeoFeatureKind kind, Iterable<GeoFeature> existing) {
    if (!allowsKind(kind)) {
      return false;
    }

    if (existing.isEmpty) {
      return true;
    }

    if (existing.any((e) => e.kind != kind)) {
      return allowsMixedKinds;
    }

    return allowsMultiple(kind);
  }

  @override
  bool operator ==(Object other) =>
      other is GeoTypeRestriction &&
      other.allowedTypes.length == allowedTypes.length &&
      other.allowedTypes.every(allowedTypes.contains);

  @override
  int get hashCode => Object.hashAllUnordered(allowedTypes);

  @override
  String toString() =>
      'GeoTypeRestriction(${allowedTypes.map((e) => e.name).join(', ')})';
}
