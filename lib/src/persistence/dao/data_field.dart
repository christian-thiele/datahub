import 'package:datahub/persistence.dart';

/// Definition a data object field inside a [BaseDataBean].
///
/// If [length] is not set, the default of the given type is used:
/// String: 255
/// Int: 32 (bit)
/// Float: 64 (bit)
class DataField<T extends DataType> extends Expression implements QuerySelect {
  final String layoutName;
  final String name;
  final bool nullable;
  final int length;

  Type get type => T;

  const DataField({
    required this.layoutName,
    required this.name,
    this.nullable = false,
    this.length = 0,
  });

  @override
  bool operator ==(Object other) {
    if (other is DataField<T>) {
      return name == other.name &&
          layoutName == other.layoutName &&
          nullable == other.nullable &&
          length == other.length;
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([name, layoutName, nullable, length]);
}

//TODO constraints instead of extending DataField ?
class PrimaryKey<T extends DataType> extends DataField<T> {
  final bool autoIncrement;

  const PrimaryKey({
    required super.layoutName,
    required super.name,
    super.nullable = false,
    this.autoIncrement = true,
    super.length = 0,
  });

  @override
  bool operator ==(Object other) {
    if (other is PrimaryKey<T>) {
      return name == other.name &&
          layoutName == other.layoutName &&
          nullable == other.nullable &&
          length == other.length &&
          autoIncrement == other.autoIncrement;
    }

    return false;
  }

  @override
  int get hashCode =>
      Object.hashAll([name, layoutName, nullable, length, autoIncrement]);
}

//TODO constraints instead of extending DataField ?
class ForeignKey<T extends DataType> extends DataField<T> {
  final PrimaryKey foreignPrimaryKey;

  ForeignKey({
    required PrimaryKey foreignPrimaryKey,
    required String layoutName,
    required String name,
    bool nullable = false,
  })  : foreignPrimaryKey = foreignPrimaryKey,
        super(
          layoutName: layoutName,
          name: name,
          nullable: nullable,
          length: foreignPrimaryKey.length,
        );

  @override
  bool operator ==(Object other) {
    if (other is ForeignKey<T>) {
      return name == other.name &&
          layoutName == other.layoutName &&
          nullable == other.nullable &&
          length == other.length &&
          foreignPrimaryKey == other.foreignPrimaryKey;
    }

    return false;
  }

  @override
  int get hashCode =>
      Object.hashAll([name, layoutName, nullable, length, foreignPrimaryKey]);
}
