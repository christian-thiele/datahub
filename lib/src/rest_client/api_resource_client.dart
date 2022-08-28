import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub/collection.dart';
import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

import 'rest_client.dart' as rest;

class ApiEndpointClient {
  final String baseUrl;
  final String path;

  const ApiEndpointClient(this.baseUrl, this.path);

  Future<TResponse> get<TResponse>({
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    final response = await rest.request<TResponse, TResponse>(
      baseUrl,
      RoutePattern(path),
      params,
      ApiRequestMethod.GET,
      query: query,
      headers: headers,
      bean: bean,
    );
    response.throwOnError();
    return response.data;
  }

  Future<TResponse> post<TResponse>(
    dynamic body, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    final response = await rest.request<TResponse, TResponse>(
      baseUrl,
      RoutePattern(path),
      params,
      ApiRequestMethod.POST,
      query: query,
      headers: headers,
      body: body,
      bean: bean,
    );
    response.throwOnError();
    return response.data;
  }

  Future<TResponse> put<TResponse>(
    dynamic body, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    final response = await rest.request<TResponse, TResponse>(
      baseUrl,
      RoutePattern(path),
      params,
      ApiRequestMethod.PUT,
      query: query,
      headers: headers,
      body: body,
      bean: bean,
    );
    response.throwOnError();
    return response.data;
  }

  Future<TResponse> patch<TResponse>(
    dynamic body, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<TResponse>? bean,
  }) async {
    final response = await rest.request<TResponse, TResponse>(
      baseUrl,
      RoutePattern(path),
      params,
      ApiRequestMethod.PATCH,
      query: query,
      headers: headers,
      body: body,
      bean: bean,
    );
    response.throwOnError();
    return response.data;
  }

  Future<void> delete({
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final response = await rest.request<void, void>(
      baseUrl,
      RoutePattern(path),
      params,
      ApiRequestMethod.DELETE,
      query: query,
      headers: headers,
    );
    response.throwOnError();
  }
}

class ApiResourceClient<TData> extends ApiEndpointClient {
  final TransferBean<TData>? bean;

  const ApiResourceClient(
    super.baseUrl,
    super.path, {
    this.bean,
  });

  Future<T> getMetaData<T>(
    String key, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final response =
        await rest.request<Map<String, dynamic>, Map<String, dynamic>>(
      baseUrl,
      RoutePattern(path),
      params,
      ApiRequestMethod.GET,
      query: {'\$$key': null, ...query},
      headers: headers,
    );
    response.throwOnError();
    return decodeTyped<T>(response.data[key]);
  }

  Future<TData> getObject({
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final response = await rest.getObject<TData>(
      path,
      baseUrl: baseUrl,
      urlParams: params,
      query: query,
      headers: headers,
      bean: bean,
    );
    response.throwOnError();
    return response.data;
  }
}

class ListApiResourceClient<TData, TId> extends ApiResourceClient<TData>
    implements ParameterizedCollection<TData> {
  final String idParam;

  const ListApiResourceClient(
    super.baseUrl,
    super.path, {
    super.bean,
    this.idParam = 'id',
  });

  @override
  Future<List<TData>> getItems(
    int offset,
    int limit, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final response = await rest.getList<TData>(
      path,
      urlParams: params,
      query: {'offset': offset.toString(), 'limit': limit.toString(), ...query},
      headers: headers,
      bean: bean,
    );
    response.throwOnError();
    return response.data;
  }

  @override
  Future<int> getSize({
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    return await getMetaData<int>(
      'size',
      params: params,
      query: query,
      headers: headers,
    );
  }

  Future<TData> getElement(
    TId id, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final response = await rest.getObject<TData>(
      '$path/{$idParam}',
      baseUrl: baseUrl,
      urlParams: {
        ...params,
        idParam: id,
      },
      query: query,
      headers: headers,
      bean: bean,
    );
    response.throwOnError();
    return response.data;
  }

  Future<TData> postElement(
    TData element, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final response = await rest.postObject<TData>(
      path,
      element,
      baseUrl: baseUrl,
      urlParams: params,
      query: query,
      headers: headers,
      bean: bean,
    );
    response.throwOnError();
    return response.data;
  }

  Future<TData> patchElement(
    TData element, {
    TId? id,
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final elementId = id ??
        (element is TransferObjectBase<String> ||
                element is TransferObjectBase<int>
            ? (element as TransferObjectBase).getId()
            : null);

    final response = await rest.patchObject(
      elementId != null ? '$path/{$idParam}' : path,
      element,
      baseUrl: baseUrl,
      urlParams: {
        ...params,
        if (elementId != null) idParam: elementId,
      },
      query: query,
      headers: headers,
      bean: bean,
    );

    response.throwOnError();
    return response.data;
  }

  Future<void> deleteElement(
    TId id, {
    Map<String, dynamic> params = const {},
    Map<String, String?> query = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final response = await rest.delete(
      '$path/{$idParam}',
      baseUrl: baseUrl,
      urlParams: {
        ...params,
        idParam: id,
      },
      query: query,
      headers: headers,
    );
    response.throwOnError();
    return response.data;
  }

  @override
  CollectionMapper<TData, T> map<T>(FutureOr<T> Function(TData) mapper) =>
      CollectionMapper(this, mapper);
}
