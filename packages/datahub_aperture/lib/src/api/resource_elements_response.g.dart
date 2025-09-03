// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_elements_response.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceElementsResponse
    with DataObject<ResourceElementsResponse> {
  const _ResourceElementsResponse();
  static const $$codec = JsonDataCodec();
  static final $total = DataField<ResourceElementsResponse, int?>(
    name: 'total',
    valueOf: (p) => p.total,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final $hasNextPage = DataField<ResourceElementsResponse, bool>(
    name: 'hasNextPage',
    valueOf: (p) => p.hasNextPage,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $data = DataField<ResourceElementsResponse, List<ResourceData>>(
    name: 'data',
    valueOf: (p) => p.data,
    dataBean: () => ResourceData.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<ResourceData>(
        value, ResourceData.bean.fromJson,
        name: name),
    toJson: (value) =>
        $$codec.encodeList<ResourceData>(value, (v) => v.toJson()),
  );

  static final DataBean<ResourceElementsResponse> bean =
      DataBean<ResourceElementsResponse>(
    name: 'ResourceElementsResponse',
    fields: List<DataField<ResourceElementsResponse, dynamic>>.unmodifiable([
      $total,
      $hasNextPage,
      $data,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceElementsResponse, dynamic>> get $$fields =>
      bean.fields;
  ResourceElementsResponse copyWith({
    int? total,
    bool nullTotal = false,
    bool? hasNextPage,
    List<ResourceData>? data,
  }) {
    final $data = this as ResourceElementsResponse;
    return ResourceElementsResponse(
      total: nullTotal ? null : (total ?? $data.total),
      hasNextPage: hasNextPage ?? $data.hasNextPage,
      data: data ?? $data.data,
    );
  }

  static ResourceElementsResponse fromValues(Map<String, dynamic> data) {
    return ResourceElementsResponse(
      total: data['total'],
      hasNextPage: data['hasNextPage'],
      data: data['data'],
    );
  }

  static ResourceElementsResponse fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          ResourceElementsResponse, data.runtimeType, name);
    }
    return ResourceElementsResponse(
      total: $total.fromJson(data['total'],
          name: DataCodec.childName(name, 'total')),
      hasNextPage: $hasNextPage.fromJson(data['hasNextPage'],
          name: DataCodec.childName(name, 'hasNextPage')),
      data:
          $data.fromJson(data['data'], name: DataCodec.childName(name, 'data')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceElementsResponse;
    return {
      'total': $total.toJson($$data.total),
      'hasNextPage': $hasNextPage.toJson($$data.hasNextPage),
      'data': $data.toJson($$data.data),
    }..removeWhere((k, v) => v == null);
  }
}
