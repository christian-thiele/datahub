//
//  Generated code. Do not modify.
//  source: opentelemetry/proto/profiles/v1experimental/pprofextended.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use aggregationTemporalityDescriptor instead')
const AggregationTemporality$json = {
  '1': 'AggregationTemporality',
  '2': [
    {'1': 'AGGREGATION_TEMPORALITY_UNSPECIFIED', '2': 0},
    {'1': 'AGGREGATION_TEMPORALITY_DELTA', '2': 1},
    {'1': 'AGGREGATION_TEMPORALITY_CUMULATIVE', '2': 2},
  ],
};

/// Descriptor for `AggregationTemporality`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List aggregationTemporalityDescriptor = $convert.base64Decode(
    'ChZBZ2dyZWdhdGlvblRlbXBvcmFsaXR5EicKI0FHR1JFR0FUSU9OX1RFTVBPUkFMSVRZX1VOU1'
    'BFQ0lGSUVEEAASIQodQUdHUkVHQVRJT05fVEVNUE9SQUxJVFlfREVMVEEQARImCiJBR0dSRUdB'
    'VElPTl9URU1QT1JBTElUWV9DVU1VTEFUSVZFEAI=');

@$core.Deprecated('Use buildIdKindDescriptor instead')
const BuildIdKind$json = {
  '1': 'BuildIdKind',
  '2': [
    {'1': 'BUILD_ID_LINKER', '2': 0},
    {'1': 'BUILD_ID_BINARY_HASH', '2': 1},
  ],
};

/// Descriptor for `BuildIdKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List buildIdKindDescriptor = $convert.base64Decode(
    'CgtCdWlsZElkS2luZBITCg9CVUlMRF9JRF9MSU5LRVIQABIYChRCVUlMRF9JRF9CSU5BUllfSE'
    'FTSBAB');

@$core.Deprecated('Use profileDescriptor instead')
const Profile$json = {
  '1': 'Profile',
  '2': [
    {'1': 'sample_type', '3': 1, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.ValueType', '10': 'sampleType'},
    {'1': 'sample', '3': 2, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.Sample', '10': 'sample'},
    {'1': 'mapping', '3': 3, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.Mapping', '10': 'mapping'},
    {'1': 'location', '3': 4, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.Location', '10': 'location'},
    {'1': 'location_indices', '3': 15, '4': 3, '5': 3, '10': 'locationIndices'},
    {'1': 'function', '3': 5, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.Function', '10': 'function'},
    {'1': 'attribute_table', '3': 16, '4': 3, '5': 11, '6': '.opentelemetry.proto.common.v1.KeyValue', '10': 'attributeTable'},
    {'1': 'attribute_units', '3': 17, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.AttributeUnit', '10': 'attributeUnits'},
    {'1': 'link_table', '3': 18, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.Link', '10': 'linkTable'},
    {'1': 'string_table', '3': 6, '4': 3, '5': 9, '10': 'stringTable'},
    {'1': 'drop_frames', '3': 7, '4': 1, '5': 3, '10': 'dropFrames'},
    {'1': 'keep_frames', '3': 8, '4': 1, '5': 3, '10': 'keepFrames'},
    {'1': 'time_nanos', '3': 9, '4': 1, '5': 3, '10': 'timeNanos'},
    {'1': 'duration_nanos', '3': 10, '4': 1, '5': 3, '10': 'durationNanos'},
    {'1': 'period_type', '3': 11, '4': 1, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.ValueType', '10': 'periodType'},
    {'1': 'period', '3': 12, '4': 1, '5': 3, '10': 'period'},
    {'1': 'comment', '3': 13, '4': 3, '5': 3, '10': 'comment'},
    {'1': 'default_sample_type', '3': 14, '4': 1, '5': 3, '10': 'defaultSampleType'},
  ],
};

/// Descriptor for `Profile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileDescriptor = $convert.base64Decode(
    'CgdQcm9maWxlElcKC3NhbXBsZV90eXBlGAEgAygLMjYub3BlbnRlbGVtZXRyeS5wcm90by5wcm'
    '9maWxlcy52MWV4cGVyaW1lbnRhbC5WYWx1ZVR5cGVSCnNhbXBsZVR5cGUSSwoGc2FtcGxlGAIg'
    'AygLMjMub3BlbnRlbGVtZXRyeS5wcm90by5wcm9maWxlcy52MWV4cGVyaW1lbnRhbC5TYW1wbG'
    'VSBnNhbXBsZRJOCgdtYXBwaW5nGAMgAygLMjQub3BlbnRlbGVtZXRyeS5wcm90by5wcm9maWxl'
    'cy52MWV4cGVyaW1lbnRhbC5NYXBwaW5nUgdtYXBwaW5nElEKCGxvY2F0aW9uGAQgAygLMjUub3'
    'BlbnRlbGVtZXRyeS5wcm90by5wcm9maWxlcy52MWV4cGVyaW1lbnRhbC5Mb2NhdGlvblIIbG9j'
    'YXRpb24SKQoQbG9jYXRpb25faW5kaWNlcxgPIAMoA1IPbG9jYXRpb25JbmRpY2VzElEKCGZ1bm'
    'N0aW9uGAUgAygLMjUub3BlbnRlbGVtZXRyeS5wcm90by5wcm9maWxlcy52MWV4cGVyaW1lbnRh'
    'bC5GdW5jdGlvblIIZnVuY3Rpb24SUAoPYXR0cmlidXRlX3RhYmxlGBAgAygLMicub3BlbnRlbG'
    'VtZXRyeS5wcm90by5jb21tb24udjEuS2V5VmFsdWVSDmF0dHJpYnV0ZVRhYmxlEmMKD2F0dHJp'
    'YnV0ZV91bml0cxgRIAMoCzI6Lm9wZW50ZWxlbWV0cnkucHJvdG8ucHJvZmlsZXMudjFleHBlcm'
    'ltZW50YWwuQXR0cmlidXRlVW5pdFIOYXR0cmlidXRlVW5pdHMSUAoKbGlua190YWJsZRgSIAMo'
    'CzIxLm9wZW50ZWxlbWV0cnkucHJvdG8ucHJvZmlsZXMudjFleHBlcmltZW50YWwuTGlua1IJbG'
    'lua1RhYmxlEiEKDHN0cmluZ190YWJsZRgGIAMoCVILc3RyaW5nVGFibGUSHwoLZHJvcF9mcmFt'
    'ZXMYByABKANSCmRyb3BGcmFtZXMSHwoLa2VlcF9mcmFtZXMYCCABKANSCmtlZXBGcmFtZXMSHQ'
    'oKdGltZV9uYW5vcxgJIAEoA1IJdGltZU5hbm9zEiUKDmR1cmF0aW9uX25hbm9zGAogASgDUg1k'
    'dXJhdGlvbk5hbm9zElcKC3BlcmlvZF90eXBlGAsgASgLMjYub3BlbnRlbGVtZXRyeS5wcm90by'
    '5wcm9maWxlcy52MWV4cGVyaW1lbnRhbC5WYWx1ZVR5cGVSCnBlcmlvZFR5cGUSFgoGcGVyaW9k'
    'GAwgASgDUgZwZXJpb2QSGAoHY29tbWVudBgNIAMoA1IHY29tbWVudBIuChNkZWZhdWx0X3NhbX'
    'BsZV90eXBlGA4gASgDUhFkZWZhdWx0U2FtcGxlVHlwZQ==');

@$core.Deprecated('Use attributeUnitDescriptor instead')
const AttributeUnit$json = {
  '1': 'AttributeUnit',
  '2': [
    {'1': 'attribute_key', '3': 1, '4': 1, '5': 3, '10': 'attributeKey'},
    {'1': 'unit', '3': 2, '4': 1, '5': 3, '10': 'unit'},
  ],
};

/// Descriptor for `AttributeUnit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attributeUnitDescriptor = $convert.base64Decode(
    'Cg1BdHRyaWJ1dGVVbml0EiMKDWF0dHJpYnV0ZV9rZXkYASABKANSDGF0dHJpYnV0ZUtleRISCg'
    'R1bml0GAIgASgDUgR1bml0');

@$core.Deprecated('Use linkDescriptor instead')
const Link$json = {
  '1': 'Link',
  '2': [
    {'1': 'trace_id', '3': 1, '4': 1, '5': 12, '10': 'traceId'},
    {'1': 'span_id', '3': 2, '4': 1, '5': 12, '10': 'spanId'},
  ],
};

/// Descriptor for `Link`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkDescriptor = $convert.base64Decode(
    'CgRMaW5rEhkKCHRyYWNlX2lkGAEgASgMUgd0cmFjZUlkEhcKB3NwYW5faWQYAiABKAxSBnNwYW'
    '5JZA==');

@$core.Deprecated('Use valueTypeDescriptor instead')
const ValueType$json = {
  '1': 'ValueType',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 3, '10': 'type'},
    {'1': 'unit', '3': 2, '4': 1, '5': 3, '10': 'unit'},
    {'1': 'aggregation_temporality', '3': 3, '4': 1, '5': 14, '6': '.opentelemetry.proto.profiles.v1experimental.AggregationTemporality', '10': 'aggregationTemporality'},
  ],
};

/// Descriptor for `ValueType`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List valueTypeDescriptor = $convert.base64Decode(
    'CglWYWx1ZVR5cGUSEgoEdHlwZRgBIAEoA1IEdHlwZRISCgR1bml0GAIgASgDUgR1bml0EnwKF2'
    'FnZ3JlZ2F0aW9uX3RlbXBvcmFsaXR5GAMgASgOMkMub3BlbnRlbGVtZXRyeS5wcm90by5wcm9m'
    'aWxlcy52MWV4cGVyaW1lbnRhbC5BZ2dyZWdhdGlvblRlbXBvcmFsaXR5UhZhZ2dyZWdhdGlvbl'
    'RlbXBvcmFsaXR5');

@$core.Deprecated('Use sampleDescriptor instead')
const Sample$json = {
  '1': 'Sample',
  '2': [
    {'1': 'location_index', '3': 1, '4': 3, '5': 4, '10': 'locationIndex'},
    {'1': 'locations_start_index', '3': 7, '4': 1, '5': 4, '10': 'locationsStartIndex'},
    {'1': 'locations_length', '3': 8, '4': 1, '5': 4, '10': 'locationsLength'},
    {'1': 'stacktrace_id_index', '3': 9, '4': 1, '5': 13, '10': 'stacktraceIdIndex'},
    {'1': 'value', '3': 2, '4': 3, '5': 3, '10': 'value'},
    {'1': 'label', '3': 3, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.Label', '10': 'label'},
    {'1': 'attributes', '3': 10, '4': 3, '5': 4, '10': 'attributes'},
    {'1': 'link', '3': 12, '4': 1, '5': 4, '10': 'link'},
    {'1': 'timestamps_unix_nano', '3': 13, '4': 3, '5': 4, '10': 'timestampsUnixNano'},
  ],
};

/// Descriptor for `Sample`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sampleDescriptor = $convert.base64Decode(
    'CgZTYW1wbGUSJQoObG9jYXRpb25faW5kZXgYASADKARSDWxvY2F0aW9uSW5kZXgSMgoVbG9jYX'
    'Rpb25zX3N0YXJ0X2luZGV4GAcgASgEUhNsb2NhdGlvbnNTdGFydEluZGV4EikKEGxvY2F0aW9u'
    'c19sZW5ndGgYCCABKARSD2xvY2F0aW9uc0xlbmd0aBIuChNzdGFja3RyYWNlX2lkX2luZGV4GA'
    'kgASgNUhFzdGFja3RyYWNlSWRJbmRleBIUCgV2YWx1ZRgCIAMoA1IFdmFsdWUSSAoFbGFiZWwY'
    'AyADKAsyMi5vcGVudGVsZW1ldHJ5LnByb3RvLnByb2ZpbGVzLnYxZXhwZXJpbWVudGFsLkxhYm'
    'VsUgVsYWJlbBIeCgphdHRyaWJ1dGVzGAogAygEUgphdHRyaWJ1dGVzEhIKBGxpbmsYDCABKARS'
    'BGxpbmsSMAoUdGltZXN0YW1wc191bml4X25hbm8YDSADKARSEnRpbWVzdGFtcHNVbml4TmFubw'
    '==');

@$core.Deprecated('Use labelDescriptor instead')
const Label$json = {
  '1': 'Label',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {'1': 'str', '3': 2, '4': 1, '5': 3, '10': 'str'},
    {'1': 'num', '3': 3, '4': 1, '5': 3, '10': 'num'},
    {'1': 'num_unit', '3': 4, '4': 1, '5': 3, '10': 'numUnit'},
  ],
};

/// Descriptor for `Label`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List labelDescriptor = $convert.base64Decode(
    'CgVMYWJlbBIQCgNrZXkYASABKANSA2tleRIQCgNzdHIYAiABKANSA3N0chIQCgNudW0YAyABKA'
    'NSA251bRIZCghudW1fdW5pdBgEIAEoA1IHbnVtVW5pdA==');

@$core.Deprecated('Use mappingDescriptor instead')
const Mapping$json = {
  '1': 'Mapping',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'memory_start', '3': 2, '4': 1, '5': 4, '10': 'memoryStart'},
    {'1': 'memory_limit', '3': 3, '4': 1, '5': 4, '10': 'memoryLimit'},
    {'1': 'file_offset', '3': 4, '4': 1, '5': 4, '10': 'fileOffset'},
    {'1': 'filename', '3': 5, '4': 1, '5': 3, '10': 'filename'},
    {'1': 'build_id', '3': 6, '4': 1, '5': 3, '10': 'buildId'},
    {'1': 'build_id_kind', '3': 11, '4': 1, '5': 14, '6': '.opentelemetry.proto.profiles.v1experimental.BuildIdKind', '10': 'buildIdKind'},
    {'1': 'attributes', '3': 12, '4': 3, '5': 4, '10': 'attributes'},
    {'1': 'has_functions', '3': 7, '4': 1, '5': 8, '10': 'hasFunctions'},
    {'1': 'has_filenames', '3': 8, '4': 1, '5': 8, '10': 'hasFilenames'},
    {'1': 'has_line_numbers', '3': 9, '4': 1, '5': 8, '10': 'hasLineNumbers'},
    {'1': 'has_inline_frames', '3': 10, '4': 1, '5': 8, '10': 'hasInlineFrames'},
  ],
};

/// Descriptor for `Mapping`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mappingDescriptor = $convert.base64Decode(
    'CgdNYXBwaW5nEg4KAmlkGAEgASgEUgJpZBIhCgxtZW1vcnlfc3RhcnQYAiABKARSC21lbW9yeV'
    'N0YXJ0EiEKDG1lbW9yeV9saW1pdBgDIAEoBFILbWVtb3J5TGltaXQSHwoLZmlsZV9vZmZzZXQY'
    'BCABKARSCmZpbGVPZmZzZXQSGgoIZmlsZW5hbWUYBSABKANSCGZpbGVuYW1lEhkKCGJ1aWxkX2'
    'lkGAYgASgDUgdidWlsZElkElwKDWJ1aWxkX2lkX2tpbmQYCyABKA4yOC5vcGVudGVsZW1ldHJ5'
    'LnByb3RvLnByb2ZpbGVzLnYxZXhwZXJpbWVudGFsLkJ1aWxkSWRLaW5kUgtidWlsZElkS2luZB'
    'IeCgphdHRyaWJ1dGVzGAwgAygEUgphdHRyaWJ1dGVzEiMKDWhhc19mdW5jdGlvbnMYByABKAhS'
    'DGhhc0Z1bmN0aW9ucxIjCg1oYXNfZmlsZW5hbWVzGAggASgIUgxoYXNGaWxlbmFtZXMSKAoQaG'
    'FzX2xpbmVfbnVtYmVycxgJIAEoCFIOaGFzTGluZU51bWJlcnMSKgoRaGFzX2lubGluZV9mcmFt'
    'ZXMYCiABKAhSD2hhc0lubGluZUZyYW1lcw==');

@$core.Deprecated('Use locationDescriptor instead')
const Location$json = {
  '1': 'Location',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'mapping_index', '3': 2, '4': 1, '5': 4, '10': 'mappingIndex'},
    {'1': 'address', '3': 3, '4': 1, '5': 4, '10': 'address'},
    {'1': 'line', '3': 4, '4': 3, '5': 11, '6': '.opentelemetry.proto.profiles.v1experimental.Line', '10': 'line'},
    {'1': 'is_folded', '3': 5, '4': 1, '5': 8, '10': 'isFolded'},
    {'1': 'type_index', '3': 6, '4': 1, '5': 13, '10': 'typeIndex'},
    {'1': 'attributes', '3': 7, '4': 3, '5': 4, '10': 'attributes'},
  ],
};

/// Descriptor for `Location`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationDescriptor = $convert.base64Decode(
    'CghMb2NhdGlvbhIOCgJpZBgBIAEoBFICaWQSIwoNbWFwcGluZ19pbmRleBgCIAEoBFIMbWFwcG'
    'luZ0luZGV4EhgKB2FkZHJlc3MYAyABKARSB2FkZHJlc3MSRQoEbGluZRgEIAMoCzIxLm9wZW50'
    'ZWxlbWV0cnkucHJvdG8ucHJvZmlsZXMudjFleHBlcmltZW50YWwuTGluZVIEbGluZRIbCglpc1'
    '9mb2xkZWQYBSABKAhSCGlzRm9sZGVkEh0KCnR5cGVfaW5kZXgYBiABKA1SCXR5cGVJbmRleBIe'
    'CgphdHRyaWJ1dGVzGAcgAygEUgphdHRyaWJ1dGVz');

@$core.Deprecated('Use lineDescriptor instead')
const Line$json = {
  '1': 'Line',
  '2': [
    {'1': 'function_index', '3': 1, '4': 1, '5': 4, '10': 'functionIndex'},
    {'1': 'line', '3': 2, '4': 1, '5': 3, '10': 'line'},
    {'1': 'column', '3': 3, '4': 1, '5': 3, '10': 'column'},
  ],
};

/// Descriptor for `Line`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lineDescriptor = $convert.base64Decode(
    'CgRMaW5lEiUKDmZ1bmN0aW9uX2luZGV4GAEgASgEUg1mdW5jdGlvbkluZGV4EhIKBGxpbmUYAi'
    'ABKANSBGxpbmUSFgoGY29sdW1uGAMgASgDUgZjb2x1bW4=');

@$core.Deprecated('Use function_Descriptor instead')
const Function_$json = {
  '1': 'Function',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 3, '10': 'name'},
    {'1': 'system_name', '3': 3, '4': 1, '5': 3, '10': 'systemName'},
    {'1': 'filename', '3': 4, '4': 1, '5': 3, '10': 'filename'},
    {'1': 'start_line', '3': 5, '4': 1, '5': 3, '10': 'startLine'},
  ],
};

/// Descriptor for `Function`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List function_Descriptor = $convert.base64Decode(
    'CghGdW5jdGlvbhIOCgJpZBgBIAEoBFICaWQSEgoEbmFtZRgCIAEoA1IEbmFtZRIfCgtzeXN0ZW'
    '1fbmFtZRgDIAEoA1IKc3lzdGVtTmFtZRIaCghmaWxlbmFtZRgEIAEoA1IIZmlsZW5hbWUSHQoK'
    'c3RhcnRfbGluZRgFIAEoA1IJc3RhcnRMaW5l');

