import 'package:cl_datahub_common/common.dart';

typedef DTOFactory<T> = T Function(Map<String, dynamic> data);

abstract class TransferObject {
  final List<Field> dataFields;
  final Map<String, dynamic> _data;

  TransferObject(this.dataFields, this._data);

  TransferObject.create(Map<Field, dynamic> fieldData)
      : this(fieldData.keys.toList(),
      fieldData.map((key, value) => MapEntry(key.key, value)));

  T? get<T>(Field<T> field) {
    if (!dataFields.contains(field)) {
      throw ApiError('Field $field does not belong to transfer object!');
    }

    return field.decode(_data);
  }

  void set<T>(Field<T> field, T value) {
    if (!dataFields.contains(field)) {
      throw ApiError('Field $field does not belong to transfer object!');
    }

    final mapEntry = field.encode(value);
    _data[mapEntry.key] = mapEntry.value;
  }

  Map<String, dynamic> toJson() => _data;
}

abstract class IdTransferObject extends TransferObject {
  static const idField = const IntField('id');

  IdTransferObject(List<Field> dataFields, Map<String, dynamic> data)
      : super((<Field>[idField]).followedBy(dataFields).toList(), data);

  IdTransferObject.create(Map<Field, dynamic> fieldData)
      : super.create(fieldData);

  int? get id => get(idField);
}