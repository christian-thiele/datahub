//
//  Generated code. Do not modify.
//  source: opentelemetry/proto/collector/metrics/v1/metrics_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../../common/v1/common.pbjson.dart' as $0;
import '../../../metrics/v1/metrics.pbjson.dart' as $4;
import '../../../resource/v1/resource.pbjson.dart' as $1;

@$core.Deprecated('Use exportMetricsServiceRequestDescriptor instead')
const ExportMetricsServiceRequest$json = {
  '1': 'ExportMetricsServiceRequest',
  '2': [
    {'1': 'resource_metrics', '3': 1, '4': 3, '5': 11, '6': '.opentelemetry.proto.metrics.v1.ResourceMetrics', '10': 'resourceMetrics'},
  ],
};

/// Descriptor for `ExportMetricsServiceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportMetricsServiceRequestDescriptor = $convert.base64Decode(
    'ChtFeHBvcnRNZXRyaWNzU2VydmljZVJlcXVlc3QSWgoQcmVzb3VyY2VfbWV0cmljcxgBIAMoCz'
    'IvLm9wZW50ZWxlbWV0cnkucHJvdG8ubWV0cmljcy52MS5SZXNvdXJjZU1ldHJpY3NSD3Jlc291'
    'cmNlTWV0cmljcw==');

@$core.Deprecated('Use exportMetricsServiceResponseDescriptor instead')
const ExportMetricsServiceResponse$json = {
  '1': 'ExportMetricsServiceResponse',
  '2': [
    {'1': 'partial_success', '3': 1, '4': 1, '5': 11, '6': '.opentelemetry.proto.collector.metrics.v1.ExportMetricsPartialSuccess', '10': 'partialSuccess'},
  ],
};

/// Descriptor for `ExportMetricsServiceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportMetricsServiceResponseDescriptor = $convert.base64Decode(
    'ChxFeHBvcnRNZXRyaWNzU2VydmljZVJlc3BvbnNlEm4KD3BhcnRpYWxfc3VjY2VzcxgBIAEoCz'
    'JFLm9wZW50ZWxlbWV0cnkucHJvdG8uY29sbGVjdG9yLm1ldHJpY3MudjEuRXhwb3J0TWV0cmlj'
    'c1BhcnRpYWxTdWNjZXNzUg5wYXJ0aWFsU3VjY2Vzcw==');

@$core.Deprecated('Use exportMetricsPartialSuccessDescriptor instead')
const ExportMetricsPartialSuccess$json = {
  '1': 'ExportMetricsPartialSuccess',
  '2': [
    {'1': 'rejected_data_points', '3': 1, '4': 1, '5': 3, '10': 'rejectedDataPoints'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `ExportMetricsPartialSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportMetricsPartialSuccessDescriptor = $convert.base64Decode(
    'ChtFeHBvcnRNZXRyaWNzUGFydGlhbFN1Y2Nlc3MSMAoUcmVqZWN0ZWRfZGF0YV9wb2ludHMYAS'
    'ABKANSEnJlamVjdGVkRGF0YVBvaW50cxIjCg1lcnJvcl9tZXNzYWdlGAIgASgJUgxlcnJvck1l'
    'c3NhZ2U=');

const $core.Map<$core.String, $core.dynamic> MetricsServiceBase$json = {
  '1': 'MetricsService',
  '2': [
    {'1': 'Export', '2': '.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest', '3': '.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceResponse', '4': {}},
  ],
};

@$core.Deprecated('Use metricsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> MetricsServiceBase$messageJson = {
  '.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest': ExportMetricsServiceRequest$json,
  '.opentelemetry.proto.metrics.v1.ResourceMetrics': $4.ResourceMetrics$json,
  '.opentelemetry.proto.resource.v1.Resource': $1.Resource$json,
  '.opentelemetry.proto.common.v1.KeyValue': $0.KeyValue$json,
  '.opentelemetry.proto.common.v1.AnyValue': $0.AnyValue$json,
  '.opentelemetry.proto.common.v1.ArrayValue': $0.ArrayValue$json,
  '.opentelemetry.proto.common.v1.KeyValueList': $0.KeyValueList$json,
  '.opentelemetry.proto.metrics.v1.ScopeMetrics': $4.ScopeMetrics$json,
  '.opentelemetry.proto.common.v1.InstrumentationScope': $0.InstrumentationScope$json,
  '.opentelemetry.proto.metrics.v1.Metric': $4.Metric$json,
  '.opentelemetry.proto.metrics.v1.Gauge': $4.Gauge$json,
  '.opentelemetry.proto.metrics.v1.NumberDataPoint': $4.NumberDataPoint$json,
  '.opentelemetry.proto.metrics.v1.Exemplar': $4.Exemplar$json,
  '.opentelemetry.proto.metrics.v1.Sum': $4.Sum$json,
  '.opentelemetry.proto.metrics.v1.Histogram': $4.Histogram$json,
  '.opentelemetry.proto.metrics.v1.HistogramDataPoint': $4.HistogramDataPoint$json,
  '.opentelemetry.proto.metrics.v1.ExponentialHistogram': $4.ExponentialHistogram$json,
  '.opentelemetry.proto.metrics.v1.ExponentialHistogramDataPoint': $4.ExponentialHistogramDataPoint$json,
  '.opentelemetry.proto.metrics.v1.ExponentialHistogramDataPoint.Buckets': $4.ExponentialHistogramDataPoint_Buckets$json,
  '.opentelemetry.proto.metrics.v1.Summary': $4.Summary$json,
  '.opentelemetry.proto.metrics.v1.SummaryDataPoint': $4.SummaryDataPoint$json,
  '.opentelemetry.proto.metrics.v1.SummaryDataPoint.ValueAtQuantile': $4.SummaryDataPoint_ValueAtQuantile$json,
  '.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceResponse': ExportMetricsServiceResponse$json,
  '.opentelemetry.proto.collector.metrics.v1.ExportMetricsPartialSuccess': ExportMetricsPartialSuccess$json,
};

/// Descriptor for `MetricsService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List metricsServiceDescriptor = $convert.base64Decode(
    'Cg5NZXRyaWNzU2VydmljZRKZAQoGRXhwb3J0EkUub3BlbnRlbGVtZXRyeS5wcm90by5jb2xsZW'
    'N0b3IubWV0cmljcy52MS5FeHBvcnRNZXRyaWNzU2VydmljZVJlcXVlc3QaRi5vcGVudGVsZW1l'
    'dHJ5LnByb3RvLmNvbGxlY3Rvci5tZXRyaWNzLnYxLkV4cG9ydE1ldHJpY3NTZXJ2aWNlUmVzcG'
    '9uc2UiAA==');

