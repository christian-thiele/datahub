import 'dart:typed_data';

import 'package:datahub/data.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:postgres/postgres.dart' as pg;

class PostgisGeography extends PostgresqlDataType<Geometry> {
  const PostgisGeography() : super('geography', const _PgGeometryType());

  @override
  dynamic encode(Geometry? value) => switch (value) {
        final value? =>
          pg.EncodedValue(value.toEWKB(), format: pg.EncodingFormat.binary),
        _ => null,
      };

  @override
  Geometry? decode(value) {
    return switch (value) {
      pg.UndecodedBytes(:final bytes) => Geometry.parseEWKB(bytes),
      Uint8List() => Geometry.parseEWKB(value),
      Geometry() => value,
      null => null,
      _ =>
        throw Exception('Cannot decode geography from ${value.runtimeType}.'),
    };
  }
}

class _PgGeometryType extends pg.Type<Geometry> {
  const _PgGeometryType() : super(null);
}
