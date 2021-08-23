import 'package:cl_datahub_common/common.dart';

typedef DTOFactory<T> = T Function(Map<String, dynamic> data);

abstract class TransferObject {
  final List<Field> dataFields;
  final Map<String, dynamic> _data;

  TransferObject(this.dataFields, this._data);

  TransferObject.create(Map<Field, dynamic> fieldData)
      : dataFields = fieldData.keys.toList(),
        _data = {} {
    fieldData.forEach((key, value) => set(key, value));
  }

  T? get<T>(Field<T> field) {
    if (!dataFields.contains(field)) {
      throw ApiError(
          'Field "${field.name}" does not belong to transfer object!');
    }

    return field.decode(_data);
  }

  void set<T>(Field<T> field, T value) {
    if (!dataFields.contains(field)) {
      throw ApiError(
          'Field "${field.name}" does not belong to transfer object!');
    }

    final mapEntry = field.encode(value);
    _data[mapEntry.key] = mapEntry.value;
  }

  Map<String, dynamic> toJson() => _data;
}

abstract class IntIdTransferObject extends TransferObject {
  static const idField = IntField('id');

  IntIdTransferObject(List<Field> dataFields, Map<String, dynamic> data)
      : super((<Field>[idField]).followedBy(dataFields).toList(), data);

  IntIdTransferObject.create(Map<Field, dynamic> fieldData)
      : super.create(fieldData);

  int? get id => get(idField);

  set id(value) => set(idField, value);
}

abstract class StringIdTransferObject extends TransferObject {
  static const idField = StrField('id');

  StringIdTransferObject(List<Field> dataFields, Map<String, dynamic> data)
      : super((<Field>[idField]).followedBy(dataFields).toList(), data);

  StringIdTransferObject.create(Map<Field, dynamic> fieldData)
      : super.create(fieldData);

  String? get id => get(idField);

  set id(value) => set(idField, value);
}
