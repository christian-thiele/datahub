//
//  Generated code. Do not modify.
//  source: opentelemetry/proto/collector/profiles/v1experimental/profiles_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../../profiles/v1experimental/profiles.pb.dart' as $7;

class ExportProfilesServiceRequest extends $pb.GeneratedMessage {
  factory ExportProfilesServiceRequest({
    $core.Iterable<$7.ResourceProfiles>? resourceProfiles,
  }) {
    final $result = create();
    if (resourceProfiles != null) {
      $result.resourceProfiles.addAll(resourceProfiles);
    }
    return $result;
  }
  ExportProfilesServiceRequest._() : super();
  factory ExportProfilesServiceRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ExportProfilesServiceRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportProfilesServiceRequest',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.collector.profiles.v1experimental'),
      createEmptyInstance: create)
    ..pc<$7.ResourceProfiles>(
        1, _omitFieldNames ? '' : 'resourceProfiles', $pb.PbFieldType.PM,
        subBuilder: $7.ResourceProfiles.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ExportProfilesServiceRequest clone() =>
      ExportProfilesServiceRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ExportProfilesServiceRequest copyWith(
          void Function(ExportProfilesServiceRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ExportProfilesServiceRequest))
          as ExportProfilesServiceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportProfilesServiceRequest create() =>
      ExportProfilesServiceRequest._();
  ExportProfilesServiceRequest createEmptyInstance() => create();
  static $pb.PbList<ExportProfilesServiceRequest> createRepeated() =>
      $pb.PbList<ExportProfilesServiceRequest>();
  @$core.pragma('dart2js:noInline')
  static ExportProfilesServiceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportProfilesServiceRequest>(create);
  static ExportProfilesServiceRequest? _defaultInstance;

  /// An array of ResourceProfiles.
  /// For data coming from a single resource this array will typically contain one
  /// element. Intermediary nodes (such as OpenTelemetry Collector) that receive
  /// data from multiple origins typically batch the data before forwarding further and
  /// in that case this array will contain multiple elements.
  @$pb.TagNumber(1)
  $core.List<$7.ResourceProfiles> get resourceProfiles => $_getList(0);
}

class ExportProfilesServiceResponse extends $pb.GeneratedMessage {
  factory ExportProfilesServiceResponse({
    ExportProfilesPartialSuccess? partialSuccess,
  }) {
    final $result = create();
    if (partialSuccess != null) {
      $result.partialSuccess = partialSuccess;
    }
    return $result;
  }
  ExportProfilesServiceResponse._() : super();
  factory ExportProfilesServiceResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ExportProfilesServiceResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportProfilesServiceResponse',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.collector.profiles.v1experimental'),
      createEmptyInstance: create)
    ..aOM<ExportProfilesPartialSuccess>(
        1, _omitFieldNames ? '' : 'partialSuccess',
        subBuilder: ExportProfilesPartialSuccess.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ExportProfilesServiceResponse clone() =>
      ExportProfilesServiceResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ExportProfilesServiceResponse copyWith(
          void Function(ExportProfilesServiceResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ExportProfilesServiceResponse))
          as ExportProfilesServiceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportProfilesServiceResponse create() =>
      ExportProfilesServiceResponse._();
  ExportProfilesServiceResponse createEmptyInstance() => create();
  static $pb.PbList<ExportProfilesServiceResponse> createRepeated() =>
      $pb.PbList<ExportProfilesServiceResponse>();
  @$core.pragma('dart2js:noInline')
  static ExportProfilesServiceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportProfilesServiceResponse>(create);
  static ExportProfilesServiceResponse? _defaultInstance;

  ///  The details of a partially successful export request.
  ///
  ///  If the request is only partially accepted
  ///  (i.e. when the server accepts only parts of the data and rejects the rest)
  ///  the server MUST initialize the `partial_success` field and MUST
  ///  set the `rejected_<signal>` with the number of items it rejected.
  ///
  ///  Servers MAY also make use of the `partial_success` field to convey
  ///  warnings/suggestions to senders even when the request was fully accepted.
  ///  In such cases, the `rejected_<signal>` MUST have a value of `0` and
  ///  the `error_message` MUST be non-empty.
  ///
  ///  A `partial_success` message with an empty value (rejected_<signal> = 0 and
  ///  `error_message` = "") is equivalent to it not being set/present. Senders
  ///  SHOULD interpret it the same way as in the full success case.
  @$pb.TagNumber(1)
  ExportProfilesPartialSuccess get partialSuccess => $_getN(0);
  @$pb.TagNumber(1)
  set partialSuccess(ExportProfilesPartialSuccess v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPartialSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearPartialSuccess() => clearField(1);
  @$pb.TagNumber(1)
  ExportProfilesPartialSuccess ensurePartialSuccess() => $_ensure(0);
}

class ExportProfilesPartialSuccess extends $pb.GeneratedMessage {
  factory ExportProfilesPartialSuccess({
    $fixnum.Int64? rejectedProfiles,
    $core.String? errorMessage,
  }) {
    final $result = create();
    if (rejectedProfiles != null) {
      $result.rejectedProfiles = rejectedProfiles;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    return $result;
  }
  ExportProfilesPartialSuccess._() : super();
  factory ExportProfilesPartialSuccess.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ExportProfilesPartialSuccess.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportProfilesPartialSuccess',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.collector.profiles.v1experimental'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'rejectedProfiles')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ExportProfilesPartialSuccess clone() =>
      ExportProfilesPartialSuccess()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ExportProfilesPartialSuccess copyWith(
          void Function(ExportProfilesPartialSuccess) updates) =>
      super.copyWith(
              (message) => updates(message as ExportProfilesPartialSuccess))
          as ExportProfilesPartialSuccess;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportProfilesPartialSuccess create() =>
      ExportProfilesPartialSuccess._();
  ExportProfilesPartialSuccess createEmptyInstance() => create();
  static $pb.PbList<ExportProfilesPartialSuccess> createRepeated() =>
      $pb.PbList<ExportProfilesPartialSuccess>();
  @$core.pragma('dart2js:noInline')
  static ExportProfilesPartialSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportProfilesPartialSuccess>(create);
  static ExportProfilesPartialSuccess? _defaultInstance;

  ///  The number of rejected profiles.
  ///
  ///  A `rejected_<signal>` field holding a `0` value indicates that the
  ///  request was fully accepted.
  @$pb.TagNumber(1)
  $fixnum.Int64 get rejectedProfiles => $_getI64(0);
  @$pb.TagNumber(1)
  set rejectedProfiles($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRejectedProfiles() => $_has(0);
  @$pb.TagNumber(1)
  void clearRejectedProfiles() => clearField(1);

  ///  A developer-facing human-readable message in English. It should be used
  ///  either to explain why the server rejected parts of the data during a partial
  ///  success or to convey warnings/suggestions during a full success. The message
  ///  should offer guidance on how users can address such issues.
  ///
  ///  error_message is an optional field. An error_message with an empty value
  ///  is equivalent to it not being set.
  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => clearField(2);
}

class ProfilesServiceApi {
  $pb.RpcClient _client;
  ProfilesServiceApi(this._client);

  $async.Future<ExportProfilesServiceResponse> export(
          $pb.ClientContext? ctx, ExportProfilesServiceRequest request) =>
      _client.invoke<ExportProfilesServiceResponse>(ctx, 'ProfilesService',
          'Export', request, ExportProfilesServiceResponse());
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
