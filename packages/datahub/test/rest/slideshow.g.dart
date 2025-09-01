// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slideshow.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _Slideshow with DataObject<Slideshow> {
  const _Slideshow();
  static final $author = DataField<Slideshow, String>(
    name: 'author',
    valueOf: (p) => p.author,
  );

  static final $date = DataField<Slideshow, String>(
    name: 'date',
    valueOf: (p) => p.date,
  );

  static final $title = DataField<Slideshow, String>(
    name: 'title',
    valueOf: (p) => p.title,
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
    final $codec = const JsonDataCodec();
    return Slideshow(
      author: $codec.decodeString(data['author'],
          name: DataCodec.childName(name, 'author')),
      date: $codec.decodeString(data['date'],
          name: DataCodec.childName(name, 'date')),
      title: $codec.decodeString(data['title'],
          name: DataCodec.childName(name, 'title')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as Slideshow;
    return {
      'author': $codec.encodeString($data.author),
      'date': $codec.encodeString($data.date),
      'title': $codec.encodeString($data.title),
    }..removeWhere((k, v) => v == null);
  }
}
