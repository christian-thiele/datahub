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

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'profiles_service.pb.dart' as $2;

export 'profiles_service.pb.dart';

@$pb.GrpcServiceName(
    'opentelemetry.proto.collector.profiles.v1experimental.ProfilesService')
class ProfilesServiceClient extends $grpc.Client {
  static final _$export = $grpc.ClientMethod<$2.ExportProfilesServiceRequest,
          $2.ExportProfilesServiceResponse>(
      '/opentelemetry.proto.collector.profiles.v1experimental.ProfilesService/Export',
      ($2.ExportProfilesServiceRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $2.ExportProfilesServiceResponse.fromBuffer(value));

  ProfilesServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$2.ExportProfilesServiceResponse> export(
      $2.ExportProfilesServiceRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$export, request, options: options);
  }
}

@$pb.GrpcServiceName(
    'opentelemetry.proto.collector.profiles.v1experimental.ProfilesService')
abstract class ProfilesServiceBase extends $grpc.Service {
  $core.String get $name =>
      'opentelemetry.proto.collector.profiles.v1experimental.ProfilesService';

  ProfilesServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.ExportProfilesServiceRequest,
            $2.ExportProfilesServiceResponse>(
        'Export',
        export_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $2.ExportProfilesServiceRequest.fromBuffer(value),
        ($2.ExportProfilesServiceResponse value) => value.writeToBuffer()));
  }

  $async.Future<$2.ExportProfilesServiceResponse> export_Pre(
      $grpc.ServiceCall call,
      $async.Future<$2.ExportProfilesServiceRequest> request) async {
    return export(call, await request);
  }

  $async.Future<$2.ExportProfilesServiceResponse> export(
      $grpc.ServiceCall call, $2.ExportProfilesServiceRequest request);
}
