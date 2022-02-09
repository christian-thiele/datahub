import 'package:boost/boost.dart';
import 'package:cl_datahub_common/common.dart';

typedef DTOFactory<T> = T Function(Map<String, dynamic> data);

abstract class TransferObject {
  final List<Field> dataFields;
  final Map<String, dynamic> _data;

  TransferObject(this.dataFields, Map<String, dynamic> data) : _data = {} {
    for (final e in data.entries
        .map((e) => Tuple(
            dataFields.firstOrNullWhere((p0) => p0.key == e.key), e.value))
        .where((element) => element.a != null)) {
      _setDecode(e.a!, decodeTyped(e.b));
    }
  }

  TransferObject.create(this.dataFields, Map<Field, dynamic> fieldData)
      : _data = {} {
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

  void _setDecode<T>(Field<T> field, dynamic value) {
    set<T>(field, decodeTyped<T>(value) as T);
  }

  Map<String, dynamic> toJson() => _data;
}

abstract class IntIdTransferObject extends TransferObject {
  static const idField = IntField('id');

  IntIdTransferObject(List<Field> dataFields, Map<String, dynamic> data)
      : super((<Field>[idField]).followedBy(dataFields).toList(), data);

  IntIdTransferObject.create(
      List<Field> dataFields, Map<Field, dynamic> fieldData)
      : super.create(
            (<Field>[idField]).followedBy(dataFields).toList(), fieldData);

  int? get id => get(idField);

  set id(value) => set(idField, value);
}

abstract class StringIdTransferObject extends TransferObject {
  static const idField = StrField('id');

  StringIdTransferObject(List<Field> dataFields, Map<String, dynamic> data)
      : super((<Field>[idField]).followedBy(dataFields).toList(), data);

  StringIdTransferObject.create(
      List<Field> dataFields, Map<Field, dynamic> fieldData)
      : super.create(
            (<Field>[idField]).followedBy(dataFields).toList(), fieldData);

  String? get id => get(idField);

  set id(value) => set(idField, value);
}
