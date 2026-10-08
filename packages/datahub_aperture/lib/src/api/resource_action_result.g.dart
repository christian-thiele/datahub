// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_action_result.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceActionResult
    with DataObject<ResourceActionResult> {
  const $ResourceActionResult();
  static const $$codec = JsonDataCodec();
  static final $success = DataField<ResourceActionResult, bool>(
    name: 'success',
    valueOf: (p) => p.success,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? true), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $message = DataField<ResourceActionResult, String?>(
    name: 'message',
    valueOf: (p) => p.message,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $data = DataField<ResourceActionResult, Map<String, dynamic>?>(
    name: 'data',
    valueOf: (p) => p.data,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      (v, {String? name}) =>
          $$codec.decodeMap<dynamic>(v, $$codec.decodeDynamic, name: name),
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(
      value,
      (v) => $$codec.encodeMap<dynamic>(v, $$codec.encodeDynamic),
    ),
  );

  static final $redirect =
      DataField<ResourceActionResult, ResourceActionRedirect?>(
        name: 'redirect',
        valueOf: (p) => p.redirect,
        dataBean: () => $ResourceActionRedirect.bean,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          $ResourceActionRedirect.bean.fromJson,
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
      );

  static final DataBean<ResourceActionResult> bean =
      DataBean<ResourceActionResult>(
        name: 'ResourceActionResult',
        fields: List<DataField<ResourceActionResult, dynamic>>.unmodifiable([
          $success,
          $message,
          $data,
          $redirect,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceActionResult, dynamic>> get $$fields => bean.fields;
  ResourceActionResult copyWith({
    bool? success,
    String? message,
    bool nullMessage = false,
    Map<String, dynamic>? data,
    bool nullData = false,
    ResourceActionRedirect? redirect,
    bool nullRedirect = false,
  }) {
    final $data = this as ResourceActionResult;
    return ResourceActionResult(
      success: success ?? $data.success,
      message: nullMessage ? null : (message ?? $data.message),
      data: nullData ? null : (data ?? $data.data),
      redirect: nullRedirect ? null : (redirect ?? $data.redirect),
    );
  }

  static ResourceActionResult fromValues(Map<String, dynamic> data) {
    return ResourceActionResult(
      success: data['success'] ?? true,
      message: data['message'],
      data: data['data'],
      redirect: data['redirect'],
    );
  }

  static ResourceActionResult fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceActionResult,
        data.runtimeType,
        name,
      );
    }
    return ResourceActionResult(
      success: $success.fromJson(
        data['success'],
        name: DataCodec.childName(name, 'success'),
      ),
      message: $message.fromJson(
        data['message'],
        name: DataCodec.childName(name, 'message'),
      ),
      data: $data.fromJson(
        data['data'],
        name: DataCodec.childName(name, 'data'),
      ),
      redirect: $redirect.fromJson(
        data['redirect'],
        name: DataCodec.childName(name, 'redirect'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceActionResult;
    return {
      'success': $success.toJson($$data.success),
      'message': $message.toJson($$data.message),
      'data': $data.toJson($$data.data),
      'redirect': $redirect.toJson($$data.redirect),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $ResourceActionRedirect
    with DataObject<ResourceActionRedirect> {
  const $ResourceActionRedirect();
  static const $$codec = JsonDataCodec();
  static final $resourceId = DataField<ResourceActionRedirect, String>(
    name: 'resourceId',
    valueOf: (p) => p.resourceId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $elementId = DataField<ResourceActionRedirect, String>(
    name: 'elementId',
    valueOf: (p) => p.elementId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<ResourceActionRedirect> bean =
      DataBean<ResourceActionRedirect>(
        name: 'ResourceActionRedirect',
        fields: List<DataField<ResourceActionRedirect, dynamic>>.unmodifiable([
          $resourceId,
          $elementId,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceActionRedirect, dynamic>> get $$fields => bean.fields;
  ResourceActionRedirect copyWith({String? resourceId, String? elementId}) {
    final $data = this as ResourceActionRedirect;
    return ResourceActionRedirect(
      resourceId: resourceId ?? $data.resourceId,
      elementId: elementId ?? $data.elementId,
    );
  }

  static ResourceActionRedirect fromValues(Map<String, dynamic> data) {
    return ResourceActionRedirect(
      resourceId: data['resourceId'],
      elementId: data['elementId'],
    );
  }

  static ResourceActionRedirect fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceActionRedirect,
        data.runtimeType,
        name,
      );
    }
    return ResourceActionRedirect(
      resourceId: $resourceId.fromJson(
        data['resourceId'],
        name: DataCodec.childName(name, 'resourceId'),
      ),
      elementId: $elementId.fromJson(
        data['elementId'],
        name: DataCodec.childName(name, 'elementId'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceActionRedirect;
    return {
      'resourceId': $resourceId.toJson($$data.resourceId),
      'elementId': $elementId.toJson($$data.elementId),
    }..removeWhere((k, v) => v == null);
  }
}
