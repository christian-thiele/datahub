// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ExampleObject with DataObject<ExampleObject> {
  const _ExampleObject();
  static const $$codec = JsonDataCodec();
  static final $slideshow = DataField<ExampleObject, Slideshow>(
    name: 'slideshow',
    valueOf: (p) => p.slideshow,
    dataBean: Slideshow.bean,
    fromJson: (value, {String? name}) =>
        Slideshow.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
  );

  static final DataBean<ExampleObject> bean = DataBean<ExampleObject>(
    name: 'ExampleObject',
    fields: List<DataField<ExampleObject, dynamic>>.unmodifiable([
      $slideshow,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ExampleObject, dynamic>> get $$fields => bean.fields;
  ExampleObject copyWith({
    Slideshow? slideshow,
  }) {
    final $data = this as ExampleObject;
    return ExampleObject(
      slideshow: slideshow ?? $data.slideshow,
    );
  }

  static ExampleObject fromValues(Map<String, dynamic> data) {
    return ExampleObject(
      slideshow: data['slideshow'],
    );
  }

  static ExampleObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ExampleObject, data.runtimeType, name);
    }
    return ExampleObject(
      slideshow: $slideshow.fromJson(data['slideshow'],
          name: DataCodec.childName(name, 'slideshow')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ExampleObject;
    return {
      'slideshow': $slideshow.toJson($$data.slideshow),
    }..removeWhere((k, v) => v == null);
  }
}
