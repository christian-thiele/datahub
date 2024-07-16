//
//  Generated code. Do not modify.
//  source: opentelemetry/proto/profiles/v1experimental/profiles.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../common/v1/common.pb.dart' as $0;
import '../../resource/v1/resource.pb.dart' as $1;
import 'pprofextended.pb.dart' as $6;

///  ProfilesData represents the profiles data that can be stored in persistent storage,
///  OR can be embedded by other protocols that transfer OTLP profiles data but do not
///  implement the OTLP protocol.
///
///  The main difference between this message and collector protocol is that
///  in this message there will not be any "control" or "metadata" specific to
///  OTLP protocol.
///
///  When new fields are added into this message, the OTLP request MUST be updated
///  as well.
class ProfilesData extends $pb.GeneratedMessage {
  factory ProfilesData({
    $core.Iterable<ResourceProfiles>? resourceProfiles,
  }) {
    final $result = create();
    if (resourceProfiles != null) {
      $result.resourceProfiles.addAll(resourceProfiles);
    }
    return $result;
  }
  ProfilesData._() : super();
  factory ProfilesData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProfilesData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProfilesData', package: const $pb.PackageName(_omitMessageNames ? '' : 'opentelemetry.proto.profiles.v1experimental'), createEmptyInstance: create)
    ..pc<ResourceProfiles>(1, _omitFieldNames ? '' : 'resourceProfiles', $pb.PbFieldType.PM, subBuilder: ResourceProfiles.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProfilesData clone() => ProfilesData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProfilesData copyWith(void Function(ProfilesData) updates) => super.copyWith((message) => updates(message as ProfilesData)) as ProfilesData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProfilesData create() => ProfilesData._();
  ProfilesData createEmptyInstance() => create();
  static $pb.PbList<ProfilesData> createRepeated() => $pb.PbList<ProfilesData>();
  @$core.pragma('dart2js:noInline')
  static ProfilesData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProfilesData>(create);
  static ProfilesData? _defaultInstance;

  /// An array of ResourceProfiles.
  /// For data coming from a single resource this array will typically contain
  /// one element. Intermediary nodes that receive data from multiple origins
  /// typically batch the data before forwarding further and in that case this
  /// array will contain multiple elements.
  @$pb.TagNumber(1)
  $core.List<ResourceProfiles> get resourceProfiles => $_getList(0);
}

/// A collection of ScopeProfiles from a Resource.
class ResourceProfiles extends $pb.GeneratedMessage {
  factory ResourceProfiles({
    $1.Resource? resource,
    $core.Iterable<ScopeProfiles>? scopeProfiles,
    $core.String? schemaUrl,
  }) {
    final $result = create();
    if (resource != null) {
      $result.resource = resource;
    }
    if (scopeProfiles != null) {
      $result.scopeProfiles.addAll(scopeProfiles);
    }
    if (schemaUrl != null) {
      $result.schemaUrl = schemaUrl;
    }
    return $result;
  }
  ResourceProfiles._() : super();
  factory ResourceProfiles.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResourceProfiles.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResourceProfiles', package: const $pb.PackageName(_omitMessageNames ? '' : 'opentelemetry.proto.profiles.v1experimental'), createEmptyInstance: create)
    ..aOM<$1.Resource>(1, _omitFieldNames ? '' : 'resource', subBuilder: $1.Resource.create)
    ..pc<ScopeProfiles>(2, _omitFieldNames ? '' : 'scopeProfiles', $pb.PbFieldType.PM, subBuilder: ScopeProfiles.create)
    ..aOS(3, _omitFieldNames ? '' : 'schemaUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ResourceProfiles clone() => ResourceProfiles()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ResourceProfiles copyWith(void Function(ResourceProfiles) updates) => super.copyWith((message) => updates(message as ResourceProfiles)) as ResourceProfiles;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResourceProfiles create() => ResourceProfiles._();
  ResourceProfiles createEmptyInstance() => create();
  static $pb.PbList<ResourceProfiles> createRepeated() => $pb.PbList<ResourceProfiles>();
  @$core.pragma('dart2js:noInline')
  static ResourceProfiles getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResourceProfiles>(create);
  static ResourceProfiles? _defaultInstance;

  /// The resource for the profiles in this message.
  /// If this field is not set then no resource info is known.
  @$pb.TagNumber(1)
  $1.Resource get resource => $_getN(0);
  @$pb.TagNumber(1)
  set resource($1.Resource v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasResource() => $_has(0);
  @$pb.TagNumber(1)
  void clearResource() => clearField(1);
  @$pb.TagNumber(1)
  $1.Resource ensureResource() => $_ensure(0);

  /// A list of ScopeProfiles that originate from a resource.
  @$pb.TagNumber(2)
  $core.List<ScopeProfiles> get scopeProfiles => $_getList(1);

  /// The Schema URL, if known. This is the identifier of the Schema that the resource data
  /// is recorded in. To learn more about Schema URL see
  /// https://opentelemetry.io/docs/specs/otel/schemas/#schema-url
  /// This schema_url applies to the data in the "resource" field. It does not apply
  /// to the data in the "scope_profiles" field which have their own schema_url field.
  @$pb.TagNumber(3)
  $core.String get schemaUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set schemaUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSchemaUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearSchemaUrl() => clearField(3);
}

/// A collection of ProfileContainers produced by an InstrumentationScope.
class ScopeProfiles extends $pb.GeneratedMessage {
  factory ScopeProfiles({
    $0.InstrumentationScope? scope,
    $core.Iterable<ProfileContainer>? profiles,
    $core.String? schemaUrl,
  }) {
    final $result = create();
    if (scope != null) {
      $result.scope = scope;
    }
    if (profiles != null) {
      $result.profiles.addAll(profiles);
    }
    if (schemaUrl != null) {
      $result.schemaUrl = schemaUrl;
    }
    return $result;
  }
  ScopeProfiles._() : super();
  factory ScopeProfiles.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScopeProfiles.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScopeProfiles', package: const $pb.PackageName(_omitMessageNames ? '' : 'opentelemetry.proto.profiles.v1experimental'), createEmptyInstance: create)
    ..aOM<$0.InstrumentationScope>(1, _omitFieldNames ? '' : 'scope', subBuilder: $0.InstrumentationScope.create)
    ..pc<ProfileContainer>(2, _omitFieldNames ? '' : 'profiles', $pb.PbFieldType.PM, subBuilder: ProfileContainer.create)
    ..aOS(3, _omitFieldNames ? '' : 'schemaUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScopeProfiles clone() => ScopeProfiles()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScopeProfiles copyWith(void Function(ScopeProfiles) updates) => super.copyWith((message) => updates(message as ScopeProfiles)) as ScopeProfiles;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScopeProfiles create() => ScopeProfiles._();
  ScopeProfiles createEmptyInstance() => create();
  static $pb.PbList<ScopeProfiles> createRepeated() => $pb.PbList<ScopeProfiles>();
  @$core.pragma('dart2js:noInline')
  static ScopeProfiles getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScopeProfiles>(create);
  static ScopeProfiles? _defaultInstance;

  /// The instrumentation scope information for the profiles in this message.
  /// Semantically when InstrumentationScope isn't set, it is equivalent with
  /// an empty instrumentation scope name (unknown).
  @$pb.TagNumber(1)
  $0.InstrumentationScope get scope => $_getN(0);
  @$pb.TagNumber(1)
  set scope($0.InstrumentationScope v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasScope() => $_has(0);
  @$pb.TagNumber(1)
  void clearScope() => clearField(1);
  @$pb.TagNumber(1)
  $0.InstrumentationScope ensureScope() => $_ensure(0);

  /// A list of ProfileContainers that originate from an instrumentation scope.
  @$pb.TagNumber(2)
  $core.List<ProfileContainer> get profiles => $_getList(1);

  /// The Schema URL, if known. This is the identifier of the Schema that the metric data
  /// is recorded in. To learn more about Schema URL see
  /// https://opentelemetry.io/docs/specs/otel/schemas/#schema-url
  /// This schema_url applies to all profiles in the "profiles" field.
  @$pb.TagNumber(3)
  $core.String get schemaUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set schemaUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSchemaUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearSchemaUrl() => clearField(3);
}

/// A ProfileContainer represents a single profile. It wraps pprof profile with OpenTelemetry specific metadata.
class ProfileContainer extends $pb.GeneratedMessage {
  factory ProfileContainer({
    $core.List<$core.int>? profileId,
    $fixnum.Int64? startTimeUnixNano,
    $fixnum.Int64? endTimeUnixNano,
    $core.Iterable<$0.KeyValue>? attributes,
    $core.int? droppedAttributesCount,
    $core.String? originalPayloadFormat,
    $core.List<$core.int>? originalPayload,
    $6.Profile? profile,
  }) {
    final $result = create();
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (startTimeUnixNano != null) {
      $result.startTimeUnixNano = startTimeUnixNano;
    }
    if (endTimeUnixNano != null) {
      $result.endTimeUnixNano = endTimeUnixNano;
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    if (droppedAttributesCount != null) {
      $result.droppedAttributesCount = droppedAttributesCount;
    }
    if (originalPayloadFormat != null) {
      $result.originalPayloadFormat = originalPayloadFormat;
    }
    if (originalPayload != null) {
      $result.originalPayload = originalPayload;
    }
    if (profile != null) {
      $result.profile = profile;
    }
    return $result;
  }
  ProfileContainer._() : super();
  factory ProfileContainer.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProfileContainer.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProfileContainer', package: const $pb.PackageName(_omitMessageNames ? '' : 'opentelemetry.proto.profiles.v1experimental'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'profileId', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'startTimeUnixNano', $pb.PbFieldType.OF6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'endTimeUnixNano', $pb.PbFieldType.OF6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..pc<$0.KeyValue>(4, _omitFieldNames ? '' : 'attributes', $pb.PbFieldType.PM, subBuilder: $0.KeyValue.create)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'droppedAttributesCount', $pb.PbFieldType.OU3)
    ..aOS(6, _omitFieldNames ? '' : 'originalPayloadFormat')
    ..a<$core.List<$core.int>>(7, _omitFieldNames ? '' : 'originalPayload', $pb.PbFieldType.OY)
    ..aOM<$6.Profile>(8, _omitFieldNames ? '' : 'profile', subBuilder: $6.Profile.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProfileContainer clone() => ProfileContainer()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProfileContainer copyWith(void Function(ProfileContainer) updates) => super.copyWith((message) => updates(message as ProfileContainer)) as ProfileContainer;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProfileContainer create() => ProfileContainer._();
  ProfileContainer createEmptyInstance() => create();
  static $pb.PbList<ProfileContainer> createRepeated() => $pb.PbList<ProfileContainer>();
  @$core.pragma('dart2js:noInline')
  static ProfileContainer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProfileContainer>(create);
  static ProfileContainer? _defaultInstance;

  ///  A globally unique identifier for a profile. The ID is a 16-byte array. An ID with
  ///  all zeroes is considered invalid.
  ///
  ///  This field is required.
  @$pb.TagNumber(1)
  $core.List<$core.int> get profileId => $_getN(0);
  @$pb.TagNumber(1)
  set profileId($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasProfileId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfileId() => clearField(1);

  ///  start_time_unix_nano is the start time of the profile.
  ///  Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970.
  ///
  ///  This field is semantically required and it is expected that end_time >= start_time.
  @$pb.TagNumber(2)
  $fixnum.Int64 get startTimeUnixNano => $_getI64(1);
  @$pb.TagNumber(2)
  set startTimeUnixNano($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartTimeUnixNano() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTimeUnixNano() => clearField(2);

  ///  end_time_unix_nano is the end time of the profile.
  ///  Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970.
  ///
  ///  This field is semantically required and it is expected that end_time >= start_time.
  @$pb.TagNumber(3)
  $fixnum.Int64 get endTimeUnixNano => $_getI64(2);
  @$pb.TagNumber(3)
  set endTimeUnixNano($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEndTimeUnixNano() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTimeUnixNano() => clearField(3);

  ///  attributes is a collection of key/value pairs. Note, global attributes
  ///  like server name can be set using the resource API. Examples of attributes:
  ///
  ///      "/http/user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"
  ///      "/http/server_latency": 300
  ///      "abc.com/myattribute": true
  ///      "abc.com/score": 10.239
  ///
  ///  The OpenTelemetry API specification further restricts the allowed value types:
  ///  https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/common/README.md#attribute
  ///  Attribute keys MUST be unique (it is not allowed to have more than one
  ///  attribute with the same key).
  @$pb.TagNumber(4)
  $core.List<$0.KeyValue> get attributes => $_getList(3);

  /// dropped_attributes_count is the number of attributes that were discarded. Attributes
  /// can be discarded because their keys are too long or because there are too many
  /// attributes. If this value is 0, then no attributes were dropped.
  @$pb.TagNumber(5)
  $core.int get droppedAttributesCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set droppedAttributesCount($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDroppedAttributesCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearDroppedAttributesCount() => clearField(5);

  /// Specifies format of the original payload. Common values are defined in semantic conventions. [required if original_payload is present]
  @$pb.TagNumber(6)
  $core.String get originalPayloadFormat => $_getSZ(5);
  @$pb.TagNumber(6)
  set originalPayloadFormat($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasOriginalPayloadFormat() => $_has(5);
  @$pb.TagNumber(6)
  void clearOriginalPayloadFormat() => clearField(6);

  /// Original payload can be stored in this field. This can be useful for users who want to get the original payload.
  /// Formats such as JFR are highly extensible and can contain more information than what is defined in this spec.
  /// Inclusion of original payload should be configurable by the user. Default behavior should be to not include the original payload.
  /// If the original payload is in pprof format, it SHOULD not be included in this field.
  /// The field is optional, however if it is present `profile` MUST be present and contain the same profiling information.
  @$pb.TagNumber(7)
  $core.List<$core.int> get originalPayload => $_getN(6);
  @$pb.TagNumber(7)
  set originalPayload($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasOriginalPayload() => $_has(6);
  @$pb.TagNumber(7)
  void clearOriginalPayload() => clearField(7);

  /// This is a reference to a pprof profile. Required, even when original_payload is present.
  @$pb.TagNumber(8)
  $6.Profile get profile => $_getN(7);
  @$pb.TagNumber(8)
  set profile($6.Profile v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasProfile() => $_has(7);
  @$pb.TagNumber(8)
  void clearProfile() => clearField(8);
  @$pb.TagNumber(8)
  $6.Profile ensureProfile() => $_ensure(7);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
