enum FieldType { String, Int, Double, Bool, DateTime }

/// Definition a data object field inside [DataLayout].
///
/// If [length] is not set, the default of the given type is used:
/// String: 255
/// int: 32
/// double: 64
class DataField {
  final FieldType type;
  final String name;
  final bool nullable; // TODO check if nullable is a good idea
  final int length;

  DataField(this.type, this.name, {this.nullable = false, int? length})
    : length = length ?? getDefaultLength(type);

  static int getDefaultLength(FieldType type) {
    switch(type) {
      case FieldType.String:
        return 255;
      case FieldType.Int:
        return 32;
      case FieldType.Double:
        return 64;
      case FieldType.Bool:
      case FieldType.DateTime:
      default:
        return 0;
    }
  }
}


class PrimaryKeyField extends DataField {
  PrimaryKeyField(FieldType type, String name, {int length = 16})
      : super(type, name, nullable: false, length: length);
}

class ForeignKeyField extends DataField {
  PrimaryKeyField foreignPrimaryKey;

  ForeignKeyField(this.foreignPrimaryKey, String name)
      : super(foreignPrimaryKey.type, name,
            nullable: false, length: foreignPrimaryKey.length);
}
