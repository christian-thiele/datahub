import 'dart:typed_data';

import 'package:cl_datahub/src/utils/utils.dart';

import 'dto/transfer_object.dart';

abstract class ApiEndpoint {
  final String path;

  ApiEndpoint(this.path);

  Future<dynamic> get(Map<String, dynamic> urlParams,
      Map<String, dynamic> queryParams);

  Future<dynamic> post(Map<String, dynamic> urlParams,
      Map<String, dynamic> queryParams, Uint8List bodyBytes);

  Future<dynamic> put(Map<String, dynamic> urlParams,
      Map<String, dynamic> queryParams, Uint8List bodyBytes);

  Future<dynamic> patch(Map<String, dynamic> urlParams,
      Map<String, dynamic> queryParams, Uint8List bodyBytes);

  Future<dynamic> delete(Map<String, dynamic> urlParams,
      Map<String, dynamic> queryParams);
}

//TODO maybe as hubresource?
abstract class ApiResource<TData extends TransferObject> extends ApiEndpoint {
  final DTOFactory? factory;

  ApiResource(String path, this.factory) : super(path);

  Future<dynamic> getMetaData(String name);

  Future<TData> getElement(int id);

  Future<List<TData>> getList(int offset, int limit);

  bool matchRoute(String route) {
    return matchPlaceholders(path, route);
  }
}