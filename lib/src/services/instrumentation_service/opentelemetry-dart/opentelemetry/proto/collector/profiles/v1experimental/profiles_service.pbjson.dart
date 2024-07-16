//
//  Generated code. Do not modify.
//  source: opentelemetry/proto/collector/profiles/v1experimental/profiles_service.proto
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
import '../../../profiles/v1experimental/pprofextended.pbjson.dart' as $6;
import '../../../profiles/v1experimental/profiles.pbjson.dart' as $7;
import '../../../resource/v1/resource.pbjson.dart' as $1;

@$core.Deprecated('Use exportProfilesServiceRequestDescriptor instead')
const ExportProfilesServiceRequest$json = {
  '1': 'ExportProfilesServiceRequest',
  '2': [
    {'1': 'resource_profiles', '3': 1, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.ResourceProfiles', '10': 'resourceProfiles'},
  ],
};

/// Descriptor for `ExportProfilesServiceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportProfilesServiceRequestDescriptor = $convert.base64Decode(
    'ChxFeHBvcnRQcm9maWxlc1NlcnZpY2VSZXF1ZXN0EmoKEXJlc291cmNlX3Byb2ZpbGVzGAEgAy'
    'gLMj0ub3BlbnRlbGVtZXRyeS5wcm90by5wcm9maWxlcy52MWV4cGVyaW1lbnRhbC5SZXNvdXJj'
    'ZVByb2ZpbGVzUhByZXNvdXJjZVByb2ZpbGVz');

@$core.Deprecated('Use exportProfilesServiceResponseDescriptor instead')
const ExportProfilesServiceResponse$json = {
  '1': 'ExportProfilesServiceResponse',
  '2': [
    {'1': 'partial_success', '3': 1, '4': 1, '5': 11, '6': '.opentelemetry.proto.collector.profiles.v1experimental.ExportProfilesPartialSuccess', '10': 'partialSuccess'},
  ],
};

/// Descriptor for `ExportProfilesServiceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportProfilesServiceResponseDescriptor = $convert.base64Decode(
    'Ch1FeHBvcnRQcm9maWxlc1NlcnZpY2VSZXNwb25zZRJ8Cg9wYXJ0aWFsX3N1Y2Nlc3MYASABKA'
    'syUy5vcGVudGVsZW1ldHJ5LnByb3RvLmNvbGxlY3Rvci5wcm9maWxlcy52MWV4cGVyaW1lbnRh'
    'bC5FeHBvcnRQcm9maWxlc1BhcnRpYWxTdWNjZXNzUg5wYXJ0aWFsU3VjY2Vzcw==');

@$core.Deprecated('Use exportProfilesPartialSuccessDescriptor instead')
const ExportProfilesPartialSuccess$json = {
  '1': 'ExportProfilesPartialSuccess',
  '2': [
    {'1': 'rejected_profiles', '3': 1, '4': 1, '5': 3, '10': 'rejectedProfiles'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `ExportProfilesPartialSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportProfilesPartialSuccessDescriptor = $convert.base64Decode(
    'ChxFeHBvcnRQcm9maWxlc1BhcnRpYWxTdWNjZXNzEisKEXJlamVjdGVkX3Byb2ZpbGVzGAEgAS'
    'gDUhByZWplY3RlZFByb2ZpbGVzEiMKDWVycm9yX21lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2Fn'
    'ZQ==');

const $core.Map<$core.String, $core.dynamic> ProfilesServiceBase$json = {
  '1': 'ProfilesService',
  '2': [
    {'1': 'Export', '2': '.opentelemetry.proto.collector.profiles.v1experimental.ExportProfilesServiceRequest', '3': '.opentelemetry.proto.collector.profiles.v1experimental.ExportProfilesServiceResponse', '4': {}},
  ],
};

@$core.Deprecated('Use profilesServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ProfilesServiceBase$messageJson = {
  '.opentelemetry.proto.collector.profiles.v1experimental.ExportProfilesServiceRequest': ExportProfilesServiceRequest$json,
  '.opentelemetry.proto.profiles.v1experimental.ResourceProfiles': $7.ResourceProfiles$json,
  '.opentelemetry.proto.resource.v1.Resource': $1.Resource$json,
  '.opentelemetry.proto.common.v1.KeyValue': $0.KeyValue$json,
  '.opentelemetry.proto.common.v1.AnyValue': $0.AnyValue$json,
  '.opentelemetry.proto.common.v1.ArrayValue': $0.ArrayValue$json,
  '.opentelemetry.proto.common.v1.KeyValueList': $0.KeyValueList$json,
  '.opentelemetry.proto.profiles.v1experimental.ScopeProfiles': $7.ScopeProfiles$json,
  '.opentelemetry.proto.common.v1.InstrumentationScope': $0.InstrumentationScope$json,
  '.opentelemetry.proto.profiles.v1experimental.ProfileContainer': $7.ProfileContainer$json,
  '.opentelemetry.proto.profiles.v1experimental.Profile': $6.Profile$json,
  '.opentelemetry.proto.profiles.v1experimental.ValueType': $6.ValueType$json,
  '.opentelemetry.proto.profiles.v1experimental.Sample': $6.Sample$json,
  '.opentelemetry.proto.profiles.v1experimental.Label': $6.Label$json,
  '.opentelemetry.proto.profiles.v1experimental.Mapping': $6.Mapping$json,
  '.opentelemetry.proto.profiles.v1experimental.Location': $6.Location$json,
  '.opentelemetry.proto.profiles.v1experimental.Line': $6.Line$json,
  '.opentelemetry.proto.profiles.v1experimental.Function': $6.Function_$json,
  '.opentelemetry.proto.profiles.v1experimental.AttributeUnit': $6.AttributeUnit$json,
  '.opentelemetry.proto.profiles.v1experimental.Link': $6.Link$json,
  '.opentelemetry.proto.collector.profiles.v1experimental.ExportProfilesServiceResponse': ExportProfilesServiceResponse$json,
  '.opentelemetry.proto.collector.profiles.v1experimental.ExportProfilesPartialSuccess': ExportProfilesPartialSuccess$json,
};

/// Descriptor for `ProfilesService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List profilesServiceDescriptor = $convert.base64Decode(
    'Cg9Qcm9maWxlc1NlcnZpY2UStQEKBkV4cG9ydBJTLm9wZW50ZWxlbWV0cnkucHJvdG8uY29sbG'
    'VjdG9yLnByb2ZpbGVzLnYxZXhwZXJpbWVudGFsLkV4cG9ydFByb2ZpbGVzU2VydmljZVJlcXVl'
    'c3QaVC5vcGVudGVsZW1ldHJ5LnByb3RvLmNvbGxlY3Rvci5wcm9maWxlcy52MWV4cGVyaW1lbn'
    'RhbC5FeHBvcnRQcm9maWxlc1NlcnZpY2VSZXNwb25zZSIA');

