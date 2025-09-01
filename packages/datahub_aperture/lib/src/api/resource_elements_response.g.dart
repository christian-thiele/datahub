// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_elements_response.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ResourceElementsResponse
    with DataObject<ResourceElementsResponse> {
  const _ResourceElementsResponse();
  static final $total = DataField<ResourceElementsResponse, int?>(
    name: 'total',
    valueOf: (p) => p.total,
  );

  static final $hasNextPage = DataField<ResourceElementsResponse, bool>(
    name: 'hasNextPage',
    valueOf: (p) => p.hasNextPage,
  );

  static final $data = DataField<ResourceElementsResponse, List<ResourceData>>(
    name: 'data',
    valueOf: (p) => p.data,
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
    final $codec = const JsonDataCodec();
    return ResourceElementsResponse(
      total: $codec.decodeNullable(data['total'], $codec.decodeInt,
          name: DataCodec.childName(name, 'total')),
      hasNextPage: $codec.decodeBool(data['hasNextPage'],
          name: DataCodec.childName(name, 'hasNextPage')),
      data: $codec.decodeList<ResourceData>(
          data['data'], ResourceData.bean.fromJson,
          name: DataCodec.childName(name, 'data')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ResourceElementsResponse;
    return {
      'total': $codec.encodeNullable($data.total, $codec.encodeInt),
      'hasNextPage': $codec.encodeBool($data.hasNextPage),
      'data': $codec.encodeList<ResourceData>($data.data, (v) => v.toJson()),
    }..removeWhere((k, v) => v == null);
  }
}
