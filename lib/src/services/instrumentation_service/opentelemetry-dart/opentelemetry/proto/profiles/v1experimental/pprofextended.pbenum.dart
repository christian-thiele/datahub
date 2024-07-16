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

import 'package:protobuf/protobuf.dart' as $pb;

/// Specifies the method of aggregating metric values, either DELTA (change since last report)
/// or CUMULATIVE (total since a fixed start time).
class AggregationTemporality extends $pb.ProtobufEnum {
  static const AggregationTemporality AGGREGATION_TEMPORALITY_UNSPECIFIED =
      AggregationTemporality._(
          0, _omitEnumNames ? '' : 'AGGREGATION_TEMPORALITY_UNSPECIFIED');
  static const AggregationTemporality AGGREGATION_TEMPORALITY_DELTA =
      AggregationTemporality._(
          1, _omitEnumNames ? '' : 'AGGREGATION_TEMPORALITY_DELTA');
  static const AggregationTemporality AGGREGATION_TEMPORALITY_CUMULATIVE =
      AggregationTemporality._(
          2, _omitEnumNames ? '' : 'AGGREGATION_TEMPORALITY_CUMULATIVE');

  static const $core.List<AggregationTemporality> values =
      <AggregationTemporality>[
    AGGREGATION_TEMPORALITY_UNSPECIFIED,
    AGGREGATION_TEMPORALITY_DELTA,
    AGGREGATION_TEMPORALITY_CUMULATIVE,
  ];

  static final $core.Map<$core.int, AggregationTemporality> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static AggregationTemporality? valueOf($core.int value) => _byValue[value];

  const AggregationTemporality._($core.int v, $core.String n) : super(v, n);
}

/// Indicates the semantics of the build_id field.
class BuildIdKind extends $pb.ProtobufEnum {
  static const BuildIdKind BUILD_ID_LINKER =
      BuildIdKind._(0, _omitEnumNames ? '' : 'BUILD_ID_LINKER');
  static const BuildIdKind BUILD_ID_BINARY_HASH =
      BuildIdKind._(1, _omitEnumNames ? '' : 'BUILD_ID_BINARY_HASH');

  static const $core.List<BuildIdKind> values = <BuildIdKind>[
    BUILD_ID_LINKER,
    BUILD_ID_BINARY_HASH,
  ];

  static final $core.Map<$core.int, BuildIdKind> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static BuildIdKind? valueOf($core.int value) => _byValue[value];

  const BuildIdKind._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
