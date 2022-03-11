import 'field_type.dart';

import '../utils.dart';

class TransferField {
  final String name;
  final String key;
  final FieldType type;
  final bool nullable;
  final bool named;
  final dynamic defaultValue;

  TransferField(this.name, this.key, this.type, this.nullable,
      this.defaultValue, this.named);

  String buildEncodingStatement(String transferObjectAccessor) {
    final allowNull = nullable || defaultValue != null;
    final fieldAccessor = '$transferObjectAccessor.$name';
    final dataAccessor = defaultValue != null
        ? '($fieldAccessor ?? ${toLiteral(defaultValue)})'
        : fieldAccessor;
    return type.buildEncodingStatement(dataAccessor, allowNull);
  }

  String buildDecodingStatement(String dataMapAccessor) {
    final allowNull = nullable || defaultValue != null;
    final keyAccessor = "$dataMapAccessor['$key']";
    final dataAccessor = defaultValue != null
        ? '($keyAccessor ?? ${toLiteral(defaultValue)})'
        : keyAccessor;
    return type.buildDecodingStatement(dataAccessor, allowNull);
  }
}