import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/utils.dart' as utils;

import 'dto/transfer_object.dart';

abstract class ApiEndpoint {
  final RoutePattern routePattern;

  ApiEndpoint(this.routePattern);

  Future<dynamic> get(ApiRequest request) =>
      throw ApiRequestException.forbidden();

  Future<dynamic> post(ApiRequest request) =>
      throw ApiRequestException.forbidden();

  Future<dynamic> put(ApiRequest request) =>
      throw ApiRequestException.forbidden();

  Future<dynamic> patch(ApiRequest request) =>
      throw ApiRequestException.forbidden();

  Future<dynamic> delete(ApiRequest request) =>
      throw ApiRequestException.forbidden();
}

//TODO maybe as hubresource?
abstract class ApiResource<TData extends TransferObject> extends ApiEndpoint {
  final DTOFactory? factory;

  ApiResource(path, this.factory) : super(path);

  Future<dynamic> getMetaData(String name);

  Future<TData> getElement(int id);

  Future<List<TData>> getList(int offset, int limit);
}
