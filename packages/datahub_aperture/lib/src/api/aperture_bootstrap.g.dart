// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aperture_bootstrap.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ApertureBootstrap with DataObject<ApertureBootstrap> {
  const _ApertureBootstrap();
  static const $$codec = JsonDataCodec();
  static final $title = DataField<ApertureBootstrap, String>(
    name: 'title',
    valueOf: (p) => p.title,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $theme = DataField<ApertureBootstrap, ApertureTheme>(
    name: 'theme',
    valueOf: (p) => p.theme,
    dataBean: () => ApertureTheme.bean,
    fromJson: (value, {String? name}) =>
        ApertureTheme.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
  );

  static final DataBean<ApertureBootstrap> bean = DataBean<ApertureBootstrap>(
    name: 'ApertureBootstrap',
    fields: List<DataField<ApertureBootstrap, dynamic>>.unmodifiable([
      $title,
      $theme,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ApertureBootstrap, dynamic>> get $$fields => bean.fields;
  ApertureBootstrap copyWith({
    String? title,
    ApertureTheme? theme,
  }) {
    final $data = this as ApertureBootstrap;
    return ApertureBootstrap(
      title: title ?? $data.title,
      theme: theme ?? $data.theme,
    );
  }

  static ApertureBootstrap fromValues(Map<String, dynamic> data) {
    return ApertureBootstrap(
      title: data['title'],
      theme: data['theme'],
    );
  }

  static ApertureBootstrap fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          ApertureBootstrap, data.runtimeType, name);
    }
    return ApertureBootstrap(
      title: $title.fromJson(data['title'],
          name: DataCodec.childName(name, 'title')),
      theme: $theme.fromJson(data['theme'],
          name: DataCodec.childName(name, 'theme')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ApertureBootstrap;
    return {
      'title': $title.toJson($$data.title),
      'theme': $theme.toJson($$data.theme),
    }..removeWhere((k, v) => v == null);
  }
}
