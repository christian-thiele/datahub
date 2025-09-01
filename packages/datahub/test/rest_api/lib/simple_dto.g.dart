// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_dto.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _SimpleDto with DataObject<SimpleDto> {
  const _SimpleDto();
  static final $text = DataField<SimpleDto, String>(
    name: 'text',
    valueOf: (p) => p.text,
  );

  static final $number = DataField<SimpleDto, int>(
    name: 'number',
    valueOf: (p) => p.number,
  );

  static final DataBean<SimpleDto> bean = DataBean<SimpleDto>(
    name: 'SimpleDto',
    fields: List<DataField<SimpleDto, dynamic>>.unmodifiable([
      $text,
      $number,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<SimpleDto, dynamic>> get $$fields => bean.fields;
  SimpleDto copyWith({
    String? text,
    int? number,
  }) {
    final $data = this as SimpleDto;
    return SimpleDto(
      text: text ?? $data.text,
      number: number ?? $data.number,
    );
  }

  static SimpleDto fromValues(Map<String, dynamic> data) {
    return SimpleDto(
      text: data['text'],
      number: data['number'],
    );
  }

  static SimpleDto fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(SimpleDto, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return SimpleDto(
      text: $codec.decodeString(data['text'],
          name: DataCodec.childName(name, 'text')),
      number: $codec.decodeInt(data['number'],
          name: DataCodec.childName(name, 'number')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as SimpleDto;
    return {
      'text': $codec.encodeString($data.text),
      'number': $codec.encodeInt($data.number),
    }..removeWhere((k, v) => v == null);
  }
}
