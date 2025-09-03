// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slideshow.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _Slideshow with DataObject<Slideshow> {
  const _Slideshow();
  static const $$codec = JsonDataCodec();
  static final $author = DataField<Slideshow, String>(
    name: 'author',
    valueOf: (p) => p.author,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $date = DataField<Slideshow, String>(
    name: 'date',
    valueOf: (p) => p.date,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $title = DataField<Slideshow, String>(
    name: 'title',
    valueOf: (p) => p.title,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<Slideshow> bean = DataBean<Slideshow>(
    name: 'Slideshow',
    fields: List<DataField<Slideshow, dynamic>>.unmodifiable([
      $author,
      $date,
      $title,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Slideshow, dynamic>> get $$fields => bean.fields;
  Slideshow copyWith({
    String? author,
    String? date,
    String? title,
  }) {
    final $data = this as Slideshow;
    return Slideshow(
      author: author ?? $data.author,
      date: date ?? $data.date,
      title: title ?? $data.title,
    );
  }

  static Slideshow fromValues(Map<String, dynamic> data) {
    return Slideshow(
      author: data['author'],
      date: data['date'],
      title: data['title'],
    );
  }

  static Slideshow fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Slideshow, data.runtimeType, name);
    }
    return Slideshow(
      author: $author.fromJson(data['author'],
          name: DataCodec.childName(name, 'author')),
      date:
          $date.fromJson(data['date'], name: DataCodec.childName(name, 'date')),
      title: $title.fromJson(data['title'],
          name: DataCodec.childName(name, 'title')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Slideshow;
    return {
      'author': $author.toJson($$data.author),
      'date': $date.toJson($$data.date),
      'title': $title.toJson($$data.title),
    }..removeWhere((k, v) => v == null);
  }
}
