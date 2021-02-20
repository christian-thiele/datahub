import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/utils.dart' as utils;

import 'dto/transfer_object.dart';

abstract class ApiEndpoint {
  final RoutePattern routePattern;

  ApiEndpoint(this.routePattern);

  Future<dynamic> get(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> post(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> put(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> patch(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();

  Future<dynamic> delete(ApiRequest request) =>
      throw ApiRequestException.methodNotAllowed();
}