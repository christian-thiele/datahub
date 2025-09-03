// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aperture_theme.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ApertureTheme with DataObject<ApertureTheme> {
  const _ApertureTheme();
  static const $$codec = JsonDataCodec();
  static final $color = DataField<ApertureTheme, int>(
    name: 'color',
    valueOf: (p) => p.color,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 4280900592), name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $logo = DataField<ApertureTheme, Uint8List?>(
    name: 'logo',
    valueOf: (p) => p.logo,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeUint8List, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeUint8List),
  );

  static final DataBean<ApertureTheme> bean = DataBean<ApertureTheme>(
    name: 'ApertureTheme',
    fields: List<DataField<ApertureTheme, dynamic>>.unmodifiable([
      $color,
      $logo,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ApertureTheme, dynamic>> get $$fields => bean.fields;
  ApertureTheme copyWith({
    int? color,
    Uint8List? logo,
    bool nullLogo = false,
  }) {
    final $data = this as ApertureTheme;
    return ApertureTheme(
      color: color ?? $data.color,
      logo: nullLogo ? null : (logo ?? $data.logo),
    );
  }

  static ApertureTheme fromValues(Map<String, dynamic> data) {
    return ApertureTheme(
      color: data['color'] ?? 4280900592,
      logo: data['logo'],
    );
  }

  static ApertureTheme fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ApertureTheme, data.runtimeType, name);
    }
    return ApertureTheme(
      color: $color.fromJson(data['color'],
          name: DataCodec.childName(name, 'color')),
      logo:
          $logo.fromJson(data['logo'], name: DataCodec.childName(name, 'logo')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ApertureTheme;
    return {
      'color': $color.toJson($$data.color),
      'logo': $logo.toJson($$data.logo),
    }..removeWhere((k, v) => v == null);
  }
}
