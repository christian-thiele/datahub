//
//  Generated code. Do not modify.
//  source: opentelemetry/proto/profiles/v1experimental/profiles.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use profilesDataDescriptor instead')
const ProfilesData$json = {
  '1': 'ProfilesData',
  '2': [
    {'1': 'resource_profiles', '3': 1, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.ResourceProfiles', '10': 'resourceProfiles'},
  ],
};

/// Descriptor for `ProfilesData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profilesDataDescriptor = $convert.base64Decode(
    'CgxQcm9maWxlc0RhdGESagoRcmVzb3VyY2VfcHJvZmlsZXMYASADKAsyPS5vcGVudGVsZW1ldH'
    'J5LnByb3RvLnByb2ZpbGVzLnYxZXhwZXJpbWVudGFsLlJlc291cmNlUHJvZmlsZXNSEHJlc291'
    'cmNlUHJvZmlsZXM=');

@$core.Deprecated('Use resourceProfilesDescriptor instead')
const ResourceProfiles$json = {
  '1': 'ResourceProfiles',
  '2': [
    {'1': 'resource', '3': 1, '4': 1, '5': 11, '6': '.opentelemetry.proto.resource.v1.Resource', '10': 'resource'},
    {'1': 'scope_profiles', '3': 2, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.ScopeProfiles', '10': 'scopeProfiles'},
    {'1': 'schema_url', '3': 3, '4': 1, '5': 9, '10': 'schemaUrl'},
  ],
  '9': [
    {'1': 1000, '2': 1001},
  ],
};

/// Descriptor for `ResourceProfiles`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resourceProfilesDescriptor = $convert.base64Decode(
    'ChBSZXNvdXJjZVByb2ZpbGVzEkUKCHJlc291cmNlGAEgASgLMikub3BlbnRlbGVtZXRyeS5wcm'
    '90by5yZXNvdXJjZS52MS5SZXNvdXJjZVIIcmVzb3VyY2USYQoOc2NvcGVfcHJvZmlsZXMYAiAD'
    'KAsyOi5vcGVudGVsZW1ldHJ5LnByb3RvLnByb2ZpbGVzLnYxZXhwZXJpbWVudGFsLlNjb3BlUH'
    'JvZmlsZXNSDXNjb3BlUHJvZmlsZXMSHQoKc2NoZW1hX3VybBgDIAEoCVIJc2NoZW1hVXJsSgYI'
    '6AcQ6Qc=');

@$core.Deprecated('Use scopeProfilesDescriptor instead')
const ScopeProfiles$json = {
  '1': 'ScopeProfiles',
  '2': [
    {'1': 'scope', '3': 1, '4': 1, '5': 11, '6': '.opentelemetry.proto.common.v1.InstrumentationScope', '10': 'scope'},
    {'1': 'profiles', '3': 2, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.ProfileContainer', '10': 'profiles'},
    {'1': 'schema_url', '3': 3, '4': 1, '5': 9, '10': 'schemaUrl'},
  ],
};

/// Descriptor for `ScopeProfiles`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scopeProfilesDescriptor = $convert.base64Decode(
    'Cg1TY29wZVByb2ZpbGVzEkkKBXNjb3BlGAEgASgLMjMub3BlbnRlbGVtZXRyeS5wcm90by5jb2'
    '1tb24udjEuSW5zdHJ1bWVudGF0aW9uU2NvcGVSBXNjb3BlElkKCHByb2ZpbGVzGAIgAygLMj0u'
    'b3BlbnRlbGVtZXRyeS5wcm90by5wcm9maWxlcy52MWV4cGVyaW1lbnRhbC5Qcm9maWxlQ29udG'
    'FpbmVyUghwcm9maWxlcxIdCgpzY2hlbWFfdXJsGAMgASgJUglzY2hlbWFVcmw=');

@$core.Deprecated('Use profileContainerDescriptor instead')
const ProfileContainer$json = {
  '1': 'ProfileContainer',
  '2': [
    {'1': 'profile_id', '3': 1, '4': 1, '5': 12, '10': 'profileId'},
    {'1': 'start_time_unix_nano', '3': 2, '4': 1, '5': 6, '10': 'startTimeUnixNano'},
    {'1': 'end_time_unix_nano', '3': 3, '4': 1, '5': 6, '10': 'endTimeUnixNano'},
    {'1': 'attributes', '3': 4, '4': 3, '5': 11, '6': '.opentelemetry.proto.common.v1.KeyValue', '10': 'attributes'},
    {'1': 'dropped_attributes_count', '3': 5, '4': 1, '5': 13, '10': 'droppedAttributesCount'},
    {'1': 'original_payload_format', '3': 6, '4': 1, '5': 9, '10': 'originalPayloadFormat'},
    {'1': 'original_payload', '3': 7, '4': 1, '5': 12, '10': 'originalPayload'},
    {'1': 'profile', '3': 8, '4': 1, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.Profile', '10': 'profile'},
  ],
};

/// Descriptor for `ProfileContainer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileContainerDescriptor = $convert.base64Decode(
    'ChBQcm9maWxlQ29udGFpbmVyEh0KCnByb2ZpbGVfaWQYASABKAxSCXByb2ZpbGVJZBIvChRzdG'
    'FydF90aW1lX3VuaXhfbmFubxgCIAEoBlIRc3RhcnRUaW1lVW5peE5hbm8SKwoSZW5kX3RpbWVf'
    'dW5peF9uYW5vGAMgASgGUg9lbmRUaW1lVW5peE5hbm8SRwoKYXR0cmlidXRlcxgEIAMoCzInLm'
    '9wZW50ZWxlbWV0cnkucHJvdG8uY29tbW9uLnYxLktleVZhbHVlUgphdHRyaWJ1dGVzEjgKGGRy'
    'b3BwZWRfYXR0cmlidXRlc19jb3VudBgFIAEoDVIWZHJvcHBlZEF0dHJpYnV0ZXNDb3VudBI2Ch'
    'dvcmlnaW5hbF9wYXlsb2FkX2Zvcm1hdBgGIAEoCVIVb3JpZ2luYWxQYXlsb2FkRm9ybWF0EikK'
    'EG9yaWdpbmFsX3BheWxvYWQYByABKAxSD29yaWdpbmFsUGF5bG9hZBJOCgdwcm9maWxlGAggAS'
    'gLMjQub3BlbnRlbGVtZXRyeS5wcm90by5wcm9maWxlcy52MWV4cGVyaW1lbnRhbC5Qcm9maWxl'
    'Ugdwcm9maWxl');

