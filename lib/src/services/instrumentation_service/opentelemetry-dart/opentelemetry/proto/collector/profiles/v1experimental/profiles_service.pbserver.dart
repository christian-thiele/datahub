//
//  Generated code. Do not modify.
//  source: opentelemetry/proto/collector/profiles/v1experimental/profiles_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'profiles_service.pb.dart' as $8;
import 'profiles_service.pbjson.dart';

export 'profiles_service.pb.dart';

abstract class ProfilesServiceBase extends $pb.GeneratedService {
  $async.Future<$8.ExportProfilesServiceResponse> export(
      $pb.ServerContext ctx, $8.ExportProfilesServiceRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Export':
        return $8.ExportProfilesServiceRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Export':
        return this.export(ctx, request as $8.ExportProfilesServiceRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ProfilesServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => ProfilesServiceBase$messageJson;
}
