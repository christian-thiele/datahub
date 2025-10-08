// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Article with DataObject<Article> {
  const $Article();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Article, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id(auto: true)],
  );

  static final $personId = DataField<Article, int>(
    name: 'personId',
    valueOf: (p) => p.personId,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $title = DataField<Article, String>(
    name: 'title',
    valueOf: (p) => p.title,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $content = DataField<Article, String>(
    name: 'content',
    valueOf: (p) => p.content,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<Article> bean = DataBean<Article>(
    name: 'Article',
    fields: List<DataField<Article, dynamic>>.unmodifiable([
      $id,
      $personId,
      $title,
      $content,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Article, dynamic>> get $$fields => bean.fields;
  Article copyWith({
    String? id,
    int? personId,
    String? title,
    String? content,
  }) {
    final $data = this as Article;
    return Article(
      id: id ?? $data.id,
      personId: personId ?? $data.personId,
      title: title ?? $data.title,
      content: content ?? $data.content,
    );
  }

  static Article fromValues(Map<String, dynamic> data) {
    return Article(
      id: data['id'],
      personId: data['personId'],
      title: data['title'],
      content: data['content'],
    );
  }

  static Article fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Article, data.runtimeType, name);
    }
    return Article(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      personId: $personId.fromJson(
        data['personId'],
        name: DataCodec.childName(name, 'personId'),
      ),
      title: $title.fromJson(
        data['title'],
        name: DataCodec.childName(name, 'title'),
      ),
      content: $content.fromJson(
        data['content'],
        name: DataCodec.childName(name, 'content'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Article;
    return {
      'id': $id.toJson($$data.id),
      'personId': $personId.toJson($$data.personId),
      'title': $title.toJson($$data.title),
      'content': $content.toJson($$data.content),
    }..removeWhere((k, v) => v == null);
  }
}
