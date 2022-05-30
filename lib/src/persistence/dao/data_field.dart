import 'package:cl_datahub/persistence.dart';

//TODO should be lowercase
enum FieldType { String, Int, Float, Bool, DateTime, Bytes, Point, Json }

/// Definition a data object field inside a [BaseDataBean].
///
/// If [length] is not set, the default of the given type is used:
/// String: 255
/// Int: 32 (bit)
/// Float: 64 (bit)
class DataField extends QuerySelect {
  final String layoutName;
  final FieldType type;
  final String name;
  final bool nullable;
  final int length;

  DataField(this.type, this.layoutName, this.name,
      {this.nullable = false, int? length})
      : length = length ?? getDefaultLength(type);

  @override
  bool operator ==(Object other) {
    if (other is DataField) {
      return type == other.type &&
          name == other.name &&
          nullable == other.nullable &&
          length == length;
    }

    return false;
  }

  static int getDefaultLength(FieldType type) {
    switch (type) {
      case FieldType.String:
        return 255;
      case FieldType.Int:
        return 32;
      case FieldType.Float:
        return 64;
      case FieldType.Bool:
      case FieldType.DateTime:
      case FieldType.Bytes:
      case FieldType.Json:
      default:
        return 0;
    }
  }
}

class PrimaryKey extends DataField {
  final bool autoIncrement;

  PrimaryKey(FieldType type, String layoutName, String name,
      {int length = 16, this.autoIncrement = false})
      : super(type, layoutName, name, nullable: false, length: length);

  @override
  bool operator ==(Object other) {
    if (other is PrimaryKey) {
      return super == other;
    }
    return false;
  }
}

class ForeignKey extends DataField {
  PrimaryKey foreignPrimaryKey;

  ForeignKey(this.foreignPrimaryKey, String layoutName, String name,
      {bool nullable = false})
      : super(foreignPrimaryKey.type, layoutName, name,
            nullable: nullable, length: foreignPrimaryKey.length);

  @override
  bool operator ==(Object other) {
    if (other is ForeignKey) {
      return super == other && foreignPrimaryKey == other.foreignPrimaryKey;
    }
    return false;
  }
}
