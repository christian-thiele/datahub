import 'package:datahub/persistence.dart';

/// Definition a data object field inside a [BaseDataBean].
///
/// If [length] is not set, the default of the given type is used:
/// String: 255
/// Int: 32 (bit)
/// Float: 64 (bit)
class DataField<T> extends Expression implements QuerySelect {
  final String layoutName;
  final String name;
  final bool nullable;
  final DataType<T> type;

  DataField({
    required this.layoutName,
    required this.name,
    required this.type,
    this.nullable = false,
  });

  @override
  bool operator ==(Object other) {
    if (other is DataField<T>) {
      return name == other.name;
    }

    return false;
  }
}

//TODO constraints instead of extending DataField ?
class PrimaryKey<T> extends DataField<T> {
  PrimaryKey({
    required super.type,
    required super.layoutName,
    required super.name,
    super.nullable = false,
  });

  @override
  bool operator ==(Object other) {
    if (other is PrimaryKey) {
      return super == other;
    }
    return false;
  }
}

//TODO constraints instead of extending DataField ?
class ForeignKey<T> extends DataField<T> {
  PrimaryKey<T> foreignPrimaryKey;

  ForeignKey({
    required this.foreignPrimaryKey,
    required String layoutName,
    required String name,
    bool nullable = false,
  }) : super(
          type: foreignPrimaryKey.type,
          layoutName: layoutName,
          name: name,
          nullable: nullable,
        );

  @override
  bool operator ==(Object other) {
    if (other is ForeignKey) {
      return super == other && foreignPrimaryKey == other.foreignPrimaryKey;
    }
    return false;
  }
}
