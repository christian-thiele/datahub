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

@$core.Deprecated('Use exportProfilesServiceRequestDescriptor instead')
const ExportProfilesServiceRequest$json = {
  '1': 'ExportProfilesServiceRequest',
  '2': [
    {
      '1': 'resource_profiles',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.opentelemetry.proto.profiles.v1experimental.ResourceProfiles',
      '10': 'resourceProfiles'
    },
  ],
};

/// Descriptor for `ExportProfilesServiceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportProfilesServiceRequestDescriptor =
    $convert.base64Decode(
        'ChxFeHBvcnRQcm9maWxlc1NlcnZpY2VSZXF1ZXN0EmoKEXJlc291cmNlX3Byb2ZpbGVzGAEgAy'
        'gLMj0ub3BlbnRlbGVtZXRyeS5wcm90by5wcm9maWxlcy52MWV4cGVyaW1lbnRhbC5SZXNvdXJj'
        'ZVByb2ZpbGVzUhByZXNvdXJjZVByb2ZpbGVz');

@$core.Deprecated('Use exportProfilesServiceResponseDescriptor instead')
const ExportProfilesServiceResponse$json = {
  '1': 'ExportProfilesServiceResponse',
  '2': [
    {
      '1': 'partial_success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6':
          '.opentelemetry.proto.collector.profiles.v1experimental.ExportProfilesPartialSuccess',
      '10': 'partialSuccess'
    },
  ],
};

/// Descriptor for `ExportProfilesServiceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportProfilesServiceResponseDescriptor =
    $convert.base64Decode(
        'Ch1FeHBvcnRQcm9maWxlc1NlcnZpY2VSZXNwb25zZRJ8Cg9wYXJ0aWFsX3N1Y2Nlc3MYASABKA'
        'syUy5vcGVudGVsZW1ldHJ5LnByb3RvLmNvbGxlY3Rvci5wcm9maWxlcy52MWV4cGVyaW1lbnRh'
        'bC5FeHBvcnRQcm9maWxlc1BhcnRpYWxTdWNjZXNzUg5wYXJ0aWFsU3VjY2Vzcw==');

@$core.Deprecated('Use exportProfilesPartialSuccessDescriptor instead')
const ExportProfilesPartialSuccess$json = {
  '1': 'ExportProfilesPartialSuccess',
  '2': [
    {
      '1': 'rejected_profiles',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'rejectedProfiles'
    },
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `ExportProfilesPartialSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportProfilesPartialSuccessDescriptor =
    $convert.base64Decode(
        'ChxFeHBvcnRQcm9maWxlc1BhcnRpYWxTdWNjZXNzEisKEXJlamVjdGVkX3Byb2ZpbGVzGAEgAS'
        'gDUhByZWplY3RlZFByb2ZpbGVzEiMKDWVycm9yX21lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2Fn'
        'ZQ==');
