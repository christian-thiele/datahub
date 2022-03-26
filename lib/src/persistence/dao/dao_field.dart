import 'package:cl_datahub/cl_datahub.dart';

/// Annotation for dao fields.
///
/// Valid types are String, int, double, bool, Uint8List and DateTime.
///
/// If [name] is not set, the name of the class is used.
///
/// The [length] parameter defines the size of the String, int or double field.
/// If used on a string field, the length is interpreted as amount
/// of characters. If used on an int or double field, the length is interpreted
/// as amount of bits used to represent the value.
///
/// Be aware that different [DatabaseAdapter] implementations can accept
/// different types lengths and may throw if an invalid size is used.
///
/// If [length] is not set, the default of the given type is used:
/// String: 255
/// int: 32 (bit)
/// double: 64 (bit)
class DaoField {
  final String? name;
  final int? length;

  const DaoField({this.name, this.length});
}

/// Annotation for primary key dao fields.
///
/// Valid types are int and String. A DAO class can only have one
/// primary key field.
///
/// If [name] is not set, the name of the class is used.
///
/// The [length] parameter defines the size of the String or int field.
/// If used on a string field, the length is interpreted as amount
/// of characters. If used on an int or double field, the length is interpreted
/// as amount of bits used to represent the value.
///
/// Be aware that different [DatabaseAdapter] implementations can accept
/// different types lengths and may throw if an invalid size is used.
///
/// If [length] is not set, the default of the given type is used:
/// String: 255
/// int: 32
/// double: 64
///
/// [autoIncrement] only works for int fields and is enabled by default.
class PrimaryKeyDaoField extends DaoField {
  final bool autoIncrement;

  const PrimaryKeyDaoField(
      {String? name, int? length, this.autoIncrement = true})
      : super(name: name, length: length);
}

/// Annotation for foreign key dao fields.
///
/// The type of the foreign key field must match the primary key field
/// of the [foreignType] class.
///
/// If [name] is not set, the name of the class is used.
class ForeignKeyDaoField extends DaoField {
  final Type foreignType;

  const ForeignKeyDaoField(this.foreignType, {String? name})
      : super(name: name, length: null);
}
