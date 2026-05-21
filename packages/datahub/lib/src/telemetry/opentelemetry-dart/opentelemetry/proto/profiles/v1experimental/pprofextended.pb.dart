//
//  Generated code. Do not modify.
//  source: opentelemetry/proto/profiles/v1experimental/pprofextended.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../common/v1/common.pb.dart' as $4;
import 'pprofextended.pbenum.dart';

export 'pprofextended.pbenum.dart';

/// Represents a complete profile, including sample types, samples,
/// mappings to binaries, locations, functions, string table, and additional metadata.
class Profile extends $pb.GeneratedMessage {
  factory Profile({
    $core.Iterable<ValueType>? sampleType,
    $core.Iterable<Sample>? sample,
    $core.Iterable<Mapping>? mapping,
    $core.Iterable<Location>? location,
    $core.Iterable<Function_>? function,
    $core.Iterable<$core.String>? stringTable,
    $fixnum.Int64? dropFrames,
    $fixnum.Int64? keepFrames,
    $fixnum.Int64? timeNanos,
    $fixnum.Int64? durationNanos,
    ValueType? periodType,
    $fixnum.Int64? period,
    $core.Iterable<$fixnum.Int64>? comment,
    $fixnum.Int64? defaultSampleType,
    $core.Iterable<$fixnum.Int64>? locationIndices,
    $core.Iterable<$4.KeyValue>? attributeTable,
    $core.Iterable<AttributeUnit>? attributeUnits,
    $core.Iterable<Link>? linkTable,
  }) {
    final $result = create();
    if (sampleType != null) {
      $result.sampleType.addAll(sampleType);
    }
    if (sample != null) {
      $result.sample.addAll(sample);
    }
    if (mapping != null) {
      $result.mapping.addAll(mapping);
    }
    if (location != null) {
      $result.location.addAll(location);
    }
    if (function != null) {
      $result.function.addAll(function);
    }
    if (stringTable != null) {
      $result.stringTable.addAll(stringTable);
    }
    if (dropFrames != null) {
      $result.dropFrames = dropFrames;
    }
    if (keepFrames != null) {
      $result.keepFrames = keepFrames;
    }
    if (timeNanos != null) {
      $result.timeNanos = timeNanos;
    }
    if (durationNanos != null) {
      $result.durationNanos = durationNanos;
    }
    if (periodType != null) {
      $result.periodType = periodType;
    }
    if (period != null) {
      $result.period = period;
    }
    if (comment != null) {
      $result.comment.addAll(comment);
    }
    if (defaultSampleType != null) {
      $result.defaultSampleType = defaultSampleType;
    }
    if (locationIndices != null) {
      $result.locationIndices.addAll(locationIndices);
    }
    if (attributeTable != null) {
      $result.attributeTable.addAll(attributeTable);
    }
    if (attributeUnits != null) {
      $result.attributeUnits.addAll(attributeUnits);
    }
    if (linkTable != null) {
      $result.linkTable.addAll(linkTable);
    }
    return $result;
  }
  Profile._() : super();
  factory Profile.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Profile.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Profile',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..pc<ValueType>(1, _omitFieldNames ? '' : 'sampleType', $pb.PbFieldType.PM,
        subBuilder: ValueType.create)
    ..pc<Sample>(2, _omitFieldNames ? '' : 'sample', $pb.PbFieldType.PM,
        subBuilder: Sample.create)
    ..pc<Mapping>(3, _omitFieldNames ? '' : 'mapping', $pb.PbFieldType.PM,
        subBuilder: Mapping.create)
    ..pc<Location>(4, _omitFieldNames ? '' : 'location', $pb.PbFieldType.PM,
        subBuilder: Location.create)
    ..pc<Function_>(5, _omitFieldNames ? '' : 'function', $pb.PbFieldType.PM,
        subBuilder: Function_.create)
    ..pPS(6, _omitFieldNames ? '' : 'stringTable')
    ..aInt64(7, _omitFieldNames ? '' : 'dropFrames')
    ..aInt64(8, _omitFieldNames ? '' : 'keepFrames')
    ..aInt64(9, _omitFieldNames ? '' : 'timeNanos')
    ..aInt64(10, _omitFieldNames ? '' : 'durationNanos')
    ..aOM<ValueType>(11, _omitFieldNames ? '' : 'periodType',
        subBuilder: ValueType.create)
    ..aInt64(12, _omitFieldNames ? '' : 'period')
    ..p<$fixnum.Int64>(13, _omitFieldNames ? '' : 'comment', $pb.PbFieldType.K6)
    ..aInt64(14, _omitFieldNames ? '' : 'defaultSampleType')
    ..p<$fixnum.Int64>(
        15, _omitFieldNames ? '' : 'locationIndices', $pb.PbFieldType.K6)
    ..pc<$4.KeyValue>(
        16, _omitFieldNames ? '' : 'attributeTable', $pb.PbFieldType.PM,
        subBuilder: $4.KeyValue.create)
    ..pc<AttributeUnit>(
        17, _omitFieldNames ? '' : 'attributeUnits', $pb.PbFieldType.PM,
        subBuilder: AttributeUnit.create)
    ..pc<Link>(18, _omitFieldNames ? '' : 'linkTable', $pb.PbFieldType.PM,
        subBuilder: Link.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Profile clone() => Profile()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Profile copyWith(void Function(Profile) updates) =>
      super.copyWith((message) => updates(message as Profile)) as Profile;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Profile create() => Profile._();
  Profile createEmptyInstance() => create();
  static $pb.PbList<Profile> createRepeated() => $pb.PbList<Profile>();
  @$core.pragma('dart2js:noInline')
  static Profile getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Profile>(create);
  static Profile? _defaultInstance;

  /// A description of the samples associated with each Sample.value.
  /// For a cpu profile this might be:
  ///   [["cpu","nanoseconds"]] or [["wall","seconds"]] or [["syscall","count"]]
  /// For a heap profile, this might be:
  ///   [["allocations","count"], ["space","bytes"]],
  /// If one of the values represents the number of events represented
  /// by the sample, by convention it should be at index 0 and use
  /// sample_type.unit == "count".
  @$pb.TagNumber(1)
  $core.List<ValueType> get sampleType => $_getList(0);

  /// The set of samples recorded in this profile.
  @$pb.TagNumber(2)
  $core.List<Sample> get sample => $_getList(1);

  /// Mapping from address ranges to the image/binary/library mapped
  /// into that address range.  mapping[0] will be the main binary.
  @$pb.TagNumber(3)
  $core.List<Mapping> get mapping => $_getList(2);

  /// Locations referenced by samples via location_indices.
  @$pb.TagNumber(4)
  $core.List<Location> get location => $_getList(3);

  /// Functions referenced by locations.
  @$pb.TagNumber(5)
  $core.List<Function_> get function => $_getList(4);

  /// A common table for strings referenced by various messages.
  /// string_table[0] must always be "".
  @$pb.TagNumber(6)
  $core.List<$core.String> get stringTable => $_getList(5);

  /// frames with Function.function_name fully matching the following
  /// regexp will be dropped from the samples, along with their successors.
  @$pb.TagNumber(7)
  $fixnum.Int64 get dropFrames => $_getI64(6);
  @$pb.TagNumber(7)
  set dropFrames($fixnum.Int64 v) {
    $_setInt64(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasDropFrames() => $_has(6);
  @$pb.TagNumber(7)
  void clearDropFrames() => clearField(7);

  /// frames with Function.function_name fully matching the following
  /// regexp will be kept, even if it matches drop_frames.
  @$pb.TagNumber(8)
  $fixnum.Int64 get keepFrames => $_getI64(7);
  @$pb.TagNumber(8)
  set keepFrames($fixnum.Int64 v) {
    $_setInt64(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasKeepFrames() => $_has(7);
  @$pb.TagNumber(8)
  void clearKeepFrames() => clearField(8);

  /// Time of collection (UTC) represented as nanoseconds past the epoch.
  @$pb.TagNumber(9)
  $fixnum.Int64 get timeNanos => $_getI64(8);
  @$pb.TagNumber(9)
  set timeNanos($fixnum.Int64 v) {
    $_setInt64(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasTimeNanos() => $_has(8);
  @$pb.TagNumber(9)
  void clearTimeNanos() => clearField(9);

  /// Duration of the profile, if a duration makes sense.
  @$pb.TagNumber(10)
  $fixnum.Int64 get durationNanos => $_getI64(9);
  @$pb.TagNumber(10)
  set durationNanos($fixnum.Int64 v) {
    $_setInt64(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasDurationNanos() => $_has(9);
  @$pb.TagNumber(10)
  void clearDurationNanos() => clearField(10);

  /// The kind of events between sampled occurrences.
  /// e.g [ "cpu","cycles" ] or [ "heap","bytes" ]
  @$pb.TagNumber(11)
  ValueType get periodType => $_getN(10);
  @$pb.TagNumber(11)
  set periodType(ValueType v) {
    setField(11, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasPeriodType() => $_has(10);
  @$pb.TagNumber(11)
  void clearPeriodType() => clearField(11);
  @$pb.TagNumber(11)
  ValueType ensurePeriodType() => $_ensure(10);

  /// The number of events between sampled occurrences.
  @$pb.TagNumber(12)
  $fixnum.Int64 get period => $_getI64(11);
  @$pb.TagNumber(12)
  set period($fixnum.Int64 v) {
    $_setInt64(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasPeriod() => $_has(11);
  @$pb.TagNumber(12)
  void clearPeriod() => clearField(12);

  /// Free-form text associated with the profile. The text is displayed as is
  /// to the user by the tools that read profiles (e.g. by pprof). This field
  /// should not be used to store any machine-readable information, it is only
  /// for human-friendly content. The profile must stay functional if this field
  /// is cleaned.
  @$pb.TagNumber(13)
  $core.List<$fixnum.Int64> get comment => $_getList(12);

  /// Index into the string table of the type of the preferred sample
  /// value. If unset, clients should default to the last sample value.
  @$pb.TagNumber(14)
  $fixnum.Int64 get defaultSampleType => $_getI64(13);
  @$pb.TagNumber(14)
  set defaultSampleType($fixnum.Int64 v) {
    $_setInt64(13, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasDefaultSampleType() => $_has(13);
  @$pb.TagNumber(14)
  void clearDefaultSampleType() => clearField(14);

  /// Array of locations referenced by samples.
  @$pb.TagNumber(15)
  $core.List<$fixnum.Int64> get locationIndices => $_getList(14);

  /// Lookup table for attributes.
  @$pb.TagNumber(16)
  $core.List<$4.KeyValue> get attributeTable => $_getList(15);

  /// Represents a mapping between Attribute Keys and Units.
  @$pb.TagNumber(17)
  $core.List<AttributeUnit> get attributeUnits => $_getList(16);

  /// Lookup table for links.
  @$pb.TagNumber(18)
  $core.List<Link> get linkTable => $_getList(17);
}

/// Represents a mapping between Attribute Keys and Units.
class AttributeUnit extends $pb.GeneratedMessage {
  factory AttributeUnit({
    $fixnum.Int64? attributeKey,
    $fixnum.Int64? unit,
  }) {
    final $result = create();
    if (attributeKey != null) {
      $result.attributeKey = attributeKey;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    return $result;
  }
  AttributeUnit._() : super();
  factory AttributeUnit.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AttributeUnit.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttributeUnit',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'attributeKey')
    ..aInt64(2, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AttributeUnit clone() => AttributeUnit()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AttributeUnit copyWith(void Function(AttributeUnit) updates) =>
      super.copyWith((message) => updates(message as AttributeUnit))
          as AttributeUnit;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttributeUnit create() => AttributeUnit._();
  AttributeUnit createEmptyInstance() => create();
  static $pb.PbList<AttributeUnit> createRepeated() =>
      $pb.PbList<AttributeUnit>();
  @$core.pragma('dart2js:noInline')
  static AttributeUnit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AttributeUnit>(create);
  static AttributeUnit? _defaultInstance;

  /// Index into string table.
  @$pb.TagNumber(1)
  $fixnum.Int64 get attributeKey => $_getI64(0);
  @$pb.TagNumber(1)
  set attributeKey($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasAttributeKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttributeKey() => clearField(1);

  /// Index into string table.
  @$pb.TagNumber(2)
  $fixnum.Int64 get unit => $_getI64(1);
  @$pb.TagNumber(2)
  set unit($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasUnit() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnit() => clearField(2);
}

/// A pointer from a profile Sample to a trace Span.
/// Connects a profile sample to a trace span, identified by unique trace and span IDs.
class Link extends $pb.GeneratedMessage {
  factory Link({
    $core.List<$core.int>? traceId,
    $core.List<$core.int>? spanId,
  }) {
    final $result = create();
    if (traceId != null) {
      $result.traceId = traceId;
    }
    if (spanId != null) {
      $result.spanId = spanId;
    }
    return $result;
  }
  Link._() : super();
  factory Link.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Link.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Link',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'traceId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'spanId', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Link clone() => Link()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Link copyWith(void Function(Link) updates) =>
      super.copyWith((message) => updates(message as Link)) as Link;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Link create() => Link._();
  Link createEmptyInstance() => create();
  static $pb.PbList<Link> createRepeated() => $pb.PbList<Link>();
  @$core.pragma('dart2js:noInline')
  static Link getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Link>(create);
  static Link? _defaultInstance;

  /// A unique identifier of a trace that this linked span is part of. The ID is a
  /// 16-byte array.
  @$pb.TagNumber(1)
  $core.List<$core.int> get traceId => $_getN(0);
  @$pb.TagNumber(1)
  set traceId($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTraceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTraceId() => clearField(1);

  /// A unique identifier for the linked span. The ID is an 8-byte array.
  @$pb.TagNumber(2)
  $core.List<$core.int> get spanId => $_getN(1);
  @$pb.TagNumber(2)
  set spanId($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSpanId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpanId() => clearField(2);
}

/// ValueType describes the type and units of a value, with an optional aggregation temporality.
class ValueType extends $pb.GeneratedMessage {
  factory ValueType({
    $fixnum.Int64? type,
    $fixnum.Int64? unit,
    AggregationTemporality? aggregationTemporality,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    if (aggregationTemporality != null) {
      $result.aggregationTemporality = aggregationTemporality;
    }
    return $result;
  }
  ValueType._() : super();
  factory ValueType.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ValueType.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValueType',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'unit')
    ..e<AggregationTemporality>(
        3, _omitFieldNames ? '' : 'aggregationTemporality', $pb.PbFieldType.OE,
        defaultOrMaker:
            AggregationTemporality.AGGREGATION_TEMPORALITY_UNSPECIFIED,
        valueOf: AggregationTemporality.valueOf,
        enumValues: AggregationTemporality.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ValueType clone() => ValueType()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ValueType copyWith(void Function(ValueType) updates) =>
      super.copyWith((message) => updates(message as ValueType)) as ValueType;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValueType create() => ValueType._();
  ValueType createEmptyInstance() => create();
  static $pb.PbList<ValueType> createRepeated() => $pb.PbList<ValueType>();
  @$core.pragma('dart2js:noInline')
  static ValueType getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValueType>(create);
  static ValueType? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get type => $_getI64(0);
  @$pb.TagNumber(1)
  set type($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get unit => $_getI64(1);
  @$pb.TagNumber(2)
  set unit($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasUnit() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnit() => clearField(2);

  @$pb.TagNumber(3)
  AggregationTemporality get aggregationTemporality => $_getN(2);
  @$pb.TagNumber(3)
  set aggregationTemporality(AggregationTemporality v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasAggregationTemporality() => $_has(2);
  @$pb.TagNumber(3)
  void clearAggregationTemporality() => clearField(3);
}

/// Each Sample records values encountered in some program
/// context. The program context is typically a stack trace, perhaps
/// augmented with auxiliary information like the thread-id, some
/// indicator of a higher level request being handled etc.
class Sample extends $pb.GeneratedMessage {
  factory Sample({
    $core.Iterable<$fixnum.Int64>? locationIndex,
    $core.Iterable<$fixnum.Int64>? value,
    $core.Iterable<Label>? label,
    $fixnum.Int64? locationsStartIndex,
    $fixnum.Int64? locationsLength,
    $core.int? stacktraceIdIndex,
    $core.Iterable<$fixnum.Int64>? attributes,
    $fixnum.Int64? link,
    $core.Iterable<$fixnum.Int64>? timestampsUnixNano,
  }) {
    final $result = create();
    if (locationIndex != null) {
      $result.locationIndex.addAll(locationIndex);
    }
    if (value != null) {
      $result.value.addAll(value);
    }
    if (label != null) {
      $result.label.addAll(label);
    }
    if (locationsStartIndex != null) {
      $result.locationsStartIndex = locationsStartIndex;
    }
    if (locationsLength != null) {
      $result.locationsLength = locationsLength;
    }
    if (stacktraceIdIndex != null) {
      $result.stacktraceIdIndex = stacktraceIdIndex;
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    if (link != null) {
      $result.link = link;
    }
    if (timestampsUnixNano != null) {
      $result.timestampsUnixNano.addAll(timestampsUnixNano);
    }
    return $result;
  }
  Sample._() : super();
  factory Sample.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Sample.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Sample',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'locationIndex', $pb.PbFieldType.KU6)
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'value', $pb.PbFieldType.K6)
    ..pc<Label>(3, _omitFieldNames ? '' : 'label', $pb.PbFieldType.PM,
        subBuilder: Label.create)
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'locationsStartIndex', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'locationsLength', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(
        9, _omitFieldNames ? '' : 'stacktraceIdIndex', $pb.PbFieldType.OU3)
    ..p<$fixnum.Int64>(
        10, _omitFieldNames ? '' : 'attributes', $pb.PbFieldType.KU6)
    ..a<$fixnum.Int64>(12, _omitFieldNames ? '' : 'link', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..p<$fixnum.Int64>(
        13, _omitFieldNames ? '' : 'timestampsUnixNano', $pb.PbFieldType.KU6)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Sample clone() => Sample()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Sample copyWith(void Function(Sample) updates) =>
      super.copyWith((message) => updates(message as Sample)) as Sample;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Sample create() => Sample._();
  Sample createEmptyInstance() => create();
  static $pb.PbList<Sample> createRepeated() => $pb.PbList<Sample>();
  @$core.pragma('dart2js:noInline')
  static Sample getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Sample>(create);
  static Sample? _defaultInstance;

  /// The indices recorded here correspond to locations in Profile.location.
  /// The leaf is at location_index[0]. [deprecated, superseded by locations_start_index / locations_length]
  @$pb.TagNumber(1)
  $core.List<$fixnum.Int64> get locationIndex => $_getList(0);

  /// The type and unit of each value is defined by the corresponding
  /// entry in Profile.sample_type. All samples must have the same
  /// number of values, the same as the length of Profile.sample_type.
  /// When aggregating multiple samples into a single sample, the
  /// result has a list of values that is the element-wise sum of the
  /// lists of the originals.
  @$pb.TagNumber(2)
  $core.List<$fixnum.Int64> get value => $_getList(1);

  ///  label includes additional context for this sample. It can include
  ///  things like a thread id, allocation size, etc.
  ///
  ///  NOTE: While possible, having multiple values for the same label key is
  ///  strongly discouraged and should never be used. Most tools (e.g. pprof) do
  ///  not have good (or any) support for multi-value labels. And an even more
  ///  discouraged case is having a string label and a numeric label of the same
  ///  name on a sample.  Again, possible to express, but should not be used.
  ///  [deprecated, superseded by attributes]
  @$pb.TagNumber(3)
  $core.List<Label> get label => $_getList(2);

  /// locations_start_index along with locations_length refers to to a slice of locations in Profile.location.
  /// Supersedes location_index.
  @$pb.TagNumber(7)
  $fixnum.Int64 get locationsStartIndex => $_getI64(3);
  @$pb.TagNumber(7)
  set locationsStartIndex($fixnum.Int64 v) {
    $_setInt64(3, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasLocationsStartIndex() => $_has(3);
  @$pb.TagNumber(7)
  void clearLocationsStartIndex() => clearField(7);

  /// locations_length along with locations_start_index refers to a slice of locations in Profile.location.
  /// Supersedes location_index.
  @$pb.TagNumber(8)
  $fixnum.Int64 get locationsLength => $_getI64(4);
  @$pb.TagNumber(8)
  set locationsLength($fixnum.Int64 v) {
    $_setInt64(4, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasLocationsLength() => $_has(4);
  @$pb.TagNumber(8)
  void clearLocationsLength() => clearField(8);

  /// A 128bit id that uniquely identifies this stacktrace, globally. Index into string table. [optional]
  @$pb.TagNumber(9)
  $core.int get stacktraceIdIndex => $_getIZ(5);
  @$pb.TagNumber(9)
  set stacktraceIdIndex($core.int v) {
    $_setUnsignedInt32(5, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasStacktraceIdIndex() => $_has(5);
  @$pb.TagNumber(9)
  void clearStacktraceIdIndex() => clearField(9);

  /// References to attributes in Profile.attribute_table. [optional]
  @$pb.TagNumber(10)
  $core.List<$fixnum.Int64> get attributes => $_getList(6);

  /// Reference to link in Profile.link_table. [optional]
  @$pb.TagNumber(12)
  $fixnum.Int64 get link => $_getI64(7);
  @$pb.TagNumber(12)
  set link($fixnum.Int64 v) {
    $_setInt64(7, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasLink() => $_has(7);
  @$pb.TagNumber(12)
  void clearLink() => clearField(12);

  /// Timestamps associated with Sample represented in nanoseconds. These timestamps are expected
  /// to fall within the Profile's time range. [optional]
  @$pb.TagNumber(13)
  $core.List<$fixnum.Int64> get timestampsUnixNano => $_getList(8);
}

/// Provides additional context for a sample,
/// such as thread ID or allocation size, with optional units. [deprecated]
class Label extends $pb.GeneratedMessage {
  factory Label({
    $fixnum.Int64? key,
    $fixnum.Int64? str,
    $fixnum.Int64? num,
    $fixnum.Int64? numUnit,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (str != null) {
      $result.str = str;
    }
    if (num != null) {
      $result.num = num;
    }
    if (numUnit != null) {
      $result.numUnit = numUnit;
    }
    return $result;
  }
  Label._() : super();
  factory Label.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Label.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Label',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'key')
    ..aInt64(2, _omitFieldNames ? '' : 'str')
    ..aInt64(3, _omitFieldNames ? '' : 'num')
    ..aInt64(4, _omitFieldNames ? '' : 'numUnit')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Label clone() => Label()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Label copyWith(void Function(Label) updates) =>
      super.copyWith((message) => updates(message as Label)) as Label;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Label create() => Label._();
  Label createEmptyInstance() => create();
  static $pb.PbList<Label> createRepeated() => $pb.PbList<Label>();
  @$core.pragma('dart2js:noInline')
  static Label getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Label>(create);
  static Label? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get key => $_getI64(0);
  @$pb.TagNumber(1)
  set key($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  /// At most one of the following must be present
  @$pb.TagNumber(2)
  $fixnum.Int64 get str => $_getI64(1);
  @$pb.TagNumber(2)
  set str($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasStr() => $_has(1);
  @$pb.TagNumber(2)
  void clearStr() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get num => $_getI64(2);
  @$pb.TagNumber(3)
  set num($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasNum() => $_has(2);
  @$pb.TagNumber(3)
  void clearNum() => clearField(3);

  /// Should only be present when num is present.
  /// Specifies the units of num.
  /// Use arbitrary string (for example, "requests") as a custom count unit.
  /// If no unit is specified, consumer may apply heuristic to deduce the unit.
  /// Consumers may also  interpret units like "bytes" and "kilobytes" as memory
  /// units and units like "seconds" and "nanoseconds" as time units,
  /// and apply appropriate unit conversions to these.
  @$pb.TagNumber(4)
  $fixnum.Int64 get numUnit => $_getI64(3);
  @$pb.TagNumber(4)
  set numUnit($fixnum.Int64 v) {
    $_setInt64(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasNumUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumUnit() => clearField(4);
}

/// Describes the mapping of a binary in memory, including its address range,
/// file offset, and metadata like build ID
class Mapping extends $pb.GeneratedMessage {
  factory Mapping({
    $fixnum.Int64? id,
    $fixnum.Int64? memoryStart,
    $fixnum.Int64? memoryLimit,
    $fixnum.Int64? fileOffset,
    $fixnum.Int64? filename,
    $fixnum.Int64? buildId,
    $core.bool? hasFunctions,
    $core.bool? hasFilenames,
    $core.bool? hasLineNumbers,
    $core.bool? hasInlineFrames,
    BuildIdKind? buildIdKind,
    $core.Iterable<$fixnum.Int64>? attributes,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (memoryStart != null) {
      $result.memoryStart = memoryStart;
    }
    if (memoryLimit != null) {
      $result.memoryLimit = memoryLimit;
    }
    if (fileOffset != null) {
      $result.fileOffset = fileOffset;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    if (buildId != null) {
      $result.buildId = buildId;
    }
    if (hasFunctions != null) {
      $result.hasFunctions = hasFunctions;
    }
    if (hasFilenames != null) {
      $result.hasFilenames = hasFilenames;
    }
    if (hasLineNumbers != null) {
      $result.hasLineNumbers = hasLineNumbers;
    }
    if (hasInlineFrames != null) {
      $result.hasInlineFrames = hasInlineFrames;
    }
    if (buildIdKind != null) {
      $result.buildIdKind = buildIdKind;
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    return $result;
  }
  Mapping._() : super();
  factory Mapping.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Mapping.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Mapping',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'memoryStart', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'memoryLimit', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'fileOffset', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(5, _omitFieldNames ? '' : 'filename')
    ..aInt64(6, _omitFieldNames ? '' : 'buildId')
    ..aOB(7, _omitFieldNames ? '' : 'hasFunctions')
    ..aOB(8, _omitFieldNames ? '' : 'hasFilenames')
    ..aOB(9, _omitFieldNames ? '' : 'hasLineNumbers')
    ..aOB(10, _omitFieldNames ? '' : 'hasInlineFrames')
    ..e<BuildIdKind>(
        11, _omitFieldNames ? '' : 'buildIdKind', $pb.PbFieldType.OE,
        defaultOrMaker: BuildIdKind.BUILD_ID_LINKER,
        valueOf: BuildIdKind.valueOf,
        enumValues: BuildIdKind.values)
    ..p<$fixnum.Int64>(
        12, _omitFieldNames ? '' : 'attributes', $pb.PbFieldType.KU6)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Mapping clone() => Mapping()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Mapping copyWith(void Function(Mapping) updates) =>
      super.copyWith((message) => updates(message as Mapping)) as Mapping;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Mapping create() => Mapping._();
  Mapping createEmptyInstance() => create();
  static $pb.PbList<Mapping> createRepeated() => $pb.PbList<Mapping>();
  @$core.pragma('dart2js:noInline')
  static Mapping getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Mapping>(create);
  static Mapping? _defaultInstance;

  /// Unique nonzero id for the mapping. [deprecated]
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// Address at which the binary (or DLL) is loaded into memory.
  @$pb.TagNumber(2)
  $fixnum.Int64 get memoryStart => $_getI64(1);
  @$pb.TagNumber(2)
  set memoryStart($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMemoryStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemoryStart() => clearField(2);

  /// The limit of the address range occupied by this mapping.
  @$pb.TagNumber(3)
  $fixnum.Int64 get memoryLimit => $_getI64(2);
  @$pb.TagNumber(3)
  set memoryLimit($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasMemoryLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemoryLimit() => clearField(3);

  /// Offset in the binary that corresponds to the first mapped address.
  @$pb.TagNumber(4)
  $fixnum.Int64 get fileOffset => $_getI64(3);
  @$pb.TagNumber(4)
  set fileOffset($fixnum.Int64 v) {
    $_setInt64(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasFileOffset() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileOffset() => clearField(4);

  /// The object this entry is loaded from.  This can be a filename on
  /// disk for the main binary and shared libraries, or virtual
  /// abstractions like "[vdso]".
  @$pb.TagNumber(5)
  $fixnum.Int64 get filename => $_getI64(4);
  @$pb.TagNumber(5)
  set filename($fixnum.Int64 v) {
    $_setInt64(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasFilename() => $_has(4);
  @$pb.TagNumber(5)
  void clearFilename() => clearField(5);

  /// A string that uniquely identifies a particular program version
  /// with high probability. E.g., for binaries generated by GNU tools,
  /// it could be the contents of the .note.gnu.build-id field.
  @$pb.TagNumber(6)
  $fixnum.Int64 get buildId => $_getI64(5);
  @$pb.TagNumber(6)
  set buildId($fixnum.Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasBuildId() => $_has(5);
  @$pb.TagNumber(6)
  void clearBuildId() => clearField(6);

  /// The following fields indicate the resolution of symbolic info.
  @$pb.TagNumber(7)
  $core.bool get hasFunctions => $_getBF(6);
  @$pb.TagNumber(7)
  set hasFunctions($core.bool v) {
    $_setBool(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasHasFunctions() => $_has(6);
  @$pb.TagNumber(7)
  void clearHasFunctions() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get hasFilenames => $_getBF(7);
  @$pb.TagNumber(8)
  set hasFilenames($core.bool v) {
    $_setBool(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasHasFilenames() => $_has(7);
  @$pb.TagNumber(8)
  void clearHasFilenames() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get hasLineNumbers => $_getBF(8);
  @$pb.TagNumber(9)
  set hasLineNumbers($core.bool v) {
    $_setBool(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasHasLineNumbers() => $_has(8);
  @$pb.TagNumber(9)
  void clearHasLineNumbers() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get hasInlineFrames => $_getBF(9);
  @$pb.TagNumber(10)
  set hasInlineFrames($core.bool v) {
    $_setBool(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasHasInlineFrames() => $_has(9);
  @$pb.TagNumber(10)
  void clearHasInlineFrames() => clearField(10);

  /// Specifies the kind of build id. See BuildIdKind enum for more details [optional]
  @$pb.TagNumber(11)
  BuildIdKind get buildIdKind => $_getN(10);
  @$pb.TagNumber(11)
  set buildIdKind(BuildIdKind v) {
    setField(11, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasBuildIdKind() => $_has(10);
  @$pb.TagNumber(11)
  void clearBuildIdKind() => clearField(11);

  /// References to attributes in Profile.attribute_table. [optional]
  @$pb.TagNumber(12)
  $core.List<$fixnum.Int64> get attributes => $_getList(11);
}

/// Describes function and line table debug information.
class Location extends $pb.GeneratedMessage {
  factory Location({
    $fixnum.Int64? id,
    $fixnum.Int64? mappingIndex,
    $fixnum.Int64? address,
    $core.Iterable<Line>? line,
    $core.bool? isFolded,
    $core.int? typeIndex,
    $core.Iterable<$fixnum.Int64>? attributes,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (mappingIndex != null) {
      $result.mappingIndex = mappingIndex;
    }
    if (address != null) {
      $result.address = address;
    }
    if (line != null) {
      $result.line.addAll(line);
    }
    if (isFolded != null) {
      $result.isFolded = isFolded;
    }
    if (typeIndex != null) {
      $result.typeIndex = typeIndex;
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    return $result;
  }
  Location._() : super();
  factory Location.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Location.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Location',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'mappingIndex', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'address', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pc<Line>(4, _omitFieldNames ? '' : 'line', $pb.PbFieldType.PM,
        subBuilder: Line.create)
    ..aOB(5, _omitFieldNames ? '' : 'isFolded')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'typeIndex', $pb.PbFieldType.OU3)
    ..p<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'attributes', $pb.PbFieldType.KU6)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Location clone() => Location()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Location copyWith(void Function(Location) updates) =>
      super.copyWith((message) => updates(message as Location)) as Location;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Location create() => Location._();
  Location createEmptyInstance() => create();
  static $pb.PbList<Location> createRepeated() => $pb.PbList<Location>();
  @$core.pragma('dart2js:noInline')
  static Location getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Location>(create);
  static Location? _defaultInstance;

  /// Unique nonzero id for the location.  A profile could use
  /// instruction addresses or any integer sequence as ids. [deprecated]
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// The index of the corresponding profile.Mapping for this location.
  /// It can be unset if the mapping is unknown or not applicable for
  /// this profile type.
  @$pb.TagNumber(2)
  $fixnum.Int64 get mappingIndex => $_getI64(1);
  @$pb.TagNumber(2)
  set mappingIndex($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMappingIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearMappingIndex() => clearField(2);

  /// The instruction address for this location, if available.  It
  /// should be within [Mapping.memory_start...Mapping.memory_limit]
  /// for the corresponding mapping. A non-leaf address may be in the
  /// middle of a call instruction. It is up to display tools to find
  /// the beginning of the instruction if necessary.
  @$pb.TagNumber(3)
  $fixnum.Int64 get address => $_getI64(2);
  @$pb.TagNumber(3)
  set address($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  ///  Multiple line indicates this location has inlined functions,
  ///  where the last entry represents the caller into which the
  ///  preceding entries were inlined.
  ///
  ///  E.g., if memcpy() is inlined into printf:
  ///     line[0].function_name == "memcpy"
  ///     line[1].function_name == "printf"
  @$pb.TagNumber(4)
  $core.List<Line> get line => $_getList(3);

  /// Provides an indication that multiple symbols map to this location's
  /// address, for example due to identical code folding by the linker. In that
  /// case the line information above represents one of the multiple
  /// symbols. This field must be recomputed when the symbolization state of the
  /// profile changes.
  @$pb.TagNumber(5)
  $core.bool get isFolded => $_getBF(4);
  @$pb.TagNumber(5)
  set isFolded($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasIsFolded() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsFolded() => clearField(5);

  /// Type of frame (e.g. kernel, native, python, hotspot, php). Index into string table.
  @$pb.TagNumber(6)
  $core.int get typeIndex => $_getIZ(5);
  @$pb.TagNumber(6)
  set typeIndex($core.int v) {
    $_setUnsignedInt32(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasTypeIndex() => $_has(5);
  @$pb.TagNumber(6)
  void clearTypeIndex() => clearField(6);

  /// References to attributes in Profile.attribute_table. [optional]
  @$pb.TagNumber(7)
  $core.List<$fixnum.Int64> get attributes => $_getList(6);
}

/// Details a specific line in a source code, linked to a function.
class Line extends $pb.GeneratedMessage {
  factory Line({
    $fixnum.Int64? functionIndex,
    $fixnum.Int64? line,
    $fixnum.Int64? column,
  }) {
    final $result = create();
    if (functionIndex != null) {
      $result.functionIndex = functionIndex;
    }
    if (line != null) {
      $result.line = line;
    }
    if (column != null) {
      $result.column = column;
    }
    return $result;
  }
  Line._() : super();
  factory Line.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Line.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Line',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'functionIndex', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(2, _omitFieldNames ? '' : 'line')
    ..aInt64(3, _omitFieldNames ? '' : 'column')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Line clone() => Line()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Line copyWith(void Function(Line) updates) =>
      super.copyWith((message) => updates(message as Line)) as Line;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Line create() => Line._();
  Line createEmptyInstance() => create();
  static $pb.PbList<Line> createRepeated() => $pb.PbList<Line>();
  @$core.pragma('dart2js:noInline')
  static Line getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Line>(create);
  static Line? _defaultInstance;

  /// The index of the corresponding profile.Function for this line.
  @$pb.TagNumber(1)
  $fixnum.Int64 get functionIndex => $_getI64(0);
  @$pb.TagNumber(1)
  set functionIndex($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasFunctionIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearFunctionIndex() => clearField(1);

  /// Line number in source code.
  @$pb.TagNumber(2)
  $fixnum.Int64 get line => $_getI64(1);
  @$pb.TagNumber(2)
  set line($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLine() => $_has(1);
  @$pb.TagNumber(2)
  void clearLine() => clearField(2);

  /// Column number in source code.
  @$pb.TagNumber(3)
  $fixnum.Int64 get column => $_getI64(2);
  @$pb.TagNumber(3)
  set column($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasColumn() => $_has(2);
  @$pb.TagNumber(3)
  void clearColumn() => clearField(3);
}

/// Describes a function, including its human-readable name, system name,
/// source file, and starting line number in the source.
class Function_ extends $pb.GeneratedMessage {
  factory Function_({
    $fixnum.Int64? id,
    $fixnum.Int64? name,
    $fixnum.Int64? systemName,
    $fixnum.Int64? filename,
    $fixnum.Int64? startLine,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (systemName != null) {
      $result.systemName = systemName;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    if (startLine != null) {
      $result.startLine = startLine;
    }
    return $result;
  }
  Function_._() : super();
  factory Function_.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Function_.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Function',
      package: const $pb.PackageName(_omitMessageNames
          ? ''
          : 'opentelemetry.proto.profiles.v1experimental'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(2, _omitFieldNames ? '' : 'name')
    ..aInt64(3, _omitFieldNames ? '' : 'systemName')
    ..aInt64(4, _omitFieldNames ? '' : 'filename')
    ..aInt64(5, _omitFieldNames ? '' : 'startLine')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Function_ clone() => Function_()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Function_ copyWith(void Function(Function_) updates) =>
      super.copyWith((message) => updates(message as Function_)) as Function_;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Function_ create() => Function_._();
  Function_ createEmptyInstance() => create();
  static $pb.PbList<Function_> createRepeated() => $pb.PbList<Function_>();
  @$core.pragma('dart2js:noInline')
  static Function_ getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Function_>(create);
  static Function_? _defaultInstance;

  /// Unique nonzero id for the function. [deprecated]
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// Name of the function, in human-readable form if available.
  @$pb.TagNumber(2)
  $fixnum.Int64 get name => $_getI64(1);
  @$pb.TagNumber(2)
  set name($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  /// Name of the function, as identified by the system.
  /// For instance, it can be a C++ mangled name.
  @$pb.TagNumber(3)
  $fixnum.Int64 get systemName => $_getI64(2);
  @$pb.TagNumber(3)
  set systemName($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSystemName() => $_has(2);
  @$pb.TagNumber(3)
  void clearSystemName() => clearField(3);

  /// Source file containing the function.
  @$pb.TagNumber(4)
  $fixnum.Int64 get filename => $_getI64(3);
  @$pb.TagNumber(4)
  set filename($fixnum.Int64 v) {
    $_setInt64(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasFilename() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilename() => clearField(4);

  /// Line number in source file.
  @$pb.TagNumber(5)
  $fixnum.Int64 get startLine => $_getI64(4);
  @$pb.TagNumber(5)
  set startLine($fixnum.Int64 v) {
    $_setInt64(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasStartLine() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartLine() => clearField(5);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
