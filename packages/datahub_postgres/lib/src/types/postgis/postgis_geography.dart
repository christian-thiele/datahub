import 'dart:typed_data';

import 'package:datahub/data.dart';
import 'package:postgres/postgres.dart' as pg;

import '../postgresql_data_type.dart';

class const PostgisGeography() extends PostgresqlDataType<Geometry> {
  this : super('geography', const _PgGeometryType());

  @override
  dynamic encode(Geometry? value) => switch (value) {
    final value? => pg.EncodedValue(
      value.toEWKB(),
      format: pg.EncodingFormat.binary,
    ),
    _ => null,
  };

  @override
  Geometry? decode(value) {
    return switch (value) {
      pg.UndecodedBytes(:final bytes) => Geometry.parseEWKB(bytes),
      Uint8List() => Geometry.parseEWKB(value),
      Geometry() => value,
      null => null,
      _ => throw Exception(
        'Cannot decode geography from ${value.runtimeType}.',
      ),
    };
  }
}

class const PostgisGeometry() extends PostgresqlDataType<Geometry> {
  this : super('geometry', const _PgGeometryType());

  @override
  dynamic encode(Geometry? value) => switch (value) {
    final value? => pg.EncodedValue(
      value.toEWKB(),
      format: pg.EncodingFormat.binary,
    ),
    _ => null,
  };

  @override
  Geometry? decode(value) {
    return switch (value) {
      pg.UndecodedBytes(:final bytes) => Geometry.parseEWKB(bytes),
      Uint8List() => Geometry.parseEWKB(value),
      Geometry() => value,
      null => null,
      _ => throw Exception('Cannot decode geometry from ${value.runtimeType}.'),
    };
  }
}

class const _PgGeometryType() extends pg.Type<Geometry> {
  this : super(null);
}
