// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constrained_item.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ConstrainedItem with DataObject<ConstrainedItem> {
  const $ConstrainedItem();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<ConstrainedItem, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true), const PrimaryKeyConstraint(auto: false)],
  );

  static final $code = DataField<ConstrainedItem, String>(
    name: 'code',
    valueOf: (p) => p.code,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const UniqueConstraint()],
  );

  static final $createdAt = DataField<ConstrainedItem, DateTime?>(
    name: 'createdAt',
    valueOf: (p) => p.createdAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
    meta: [const DefaultConstraint(const RawSql('now()'))],
  );

  static final $counter = DataField<ConstrainedItem, int?>(
    name: 'counter',
    valueOf: (p) => p.counter,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [
      const NotNullConstraint(),
      const DefaultConstraint(const RawSql('0')),
    ],
  );

  static final $note = DataField<ConstrainedItem, String?>(
    name: 'note',
    valueOf: (p) => p.note,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<ConstrainedItem> bean = DataBean<ConstrainedItem>(
    name: 'ConstrainedItem',
    fields: List<DataField<ConstrainedItem, dynamic>>.unmodifiable([
      $id,
      $code,
      $createdAt,
      $counter,
      $note,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ConstrainedItem, dynamic>> get $$fields => bean.fields;
  ConstrainedItem copyWith({
    int? id,
    String? code,
    DateTime? createdAt,
    bool nullCreatedAt = false,
    int? counter,
    bool nullCounter = false,
    String? note,
    bool nullNote = false,
  }) {
    final $data = this as ConstrainedItem;
    return ConstrainedItem(
      id: id ?? $data.id,
      code: code ?? $data.code,
      createdAt: nullCreatedAt ? null : (createdAt ?? $data.createdAt),
      counter: nullCounter ? null : (counter ?? $data.counter),
      note: nullNote ? null : (note ?? $data.note),
    );
  }

  static ConstrainedItem fromValues(Map<String, dynamic> data) {
    return ConstrainedItem(
      id: data['id'],
      code: data['code'],
      createdAt: data['createdAt'],
      counter: data['counter'],
      note: data['note'],
    );
  }

  static ConstrainedItem fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ConstrainedItem,
        data.runtimeType,
        name,
      );
    }
    return ConstrainedItem(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      code: $code.fromJson(
        data['code'],
        name: DataCodec.childName(name, 'code'),
      ),
      createdAt: $createdAt.fromJson(
        data['createdAt'],
        name: DataCodec.childName(name, 'createdAt'),
      ),
      counter: $counter.fromJson(
        data['counter'],
        name: DataCodec.childName(name, 'counter'),
      ),
      note: $note.fromJson(
        data['note'],
        name: DataCodec.childName(name, 'note'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ConstrainedItem;
    return {
      'id': $id.toJson($$data.id),
      'code': $code.toJson($$data.code),
      'createdAt': $createdAt.toJson($$data.createdAt),
      'counter': $counter.toJson($$data.counter),
      'note': $note.toJson($$data.note),
    }..removeWhere((k, v) => v == null);
  }
}
