import 'package:cl_datahub_common/src/generator/field_type.dart';

import 'utils.dart';

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
    final fieldAccessor = '$transferObjectAccessor.$name';
    return type.buildEncodingStatement(fieldAccessor);
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
