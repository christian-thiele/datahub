import 'package:boost/boost.dart';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub_common/common.dart';

abstract class ApiResource<TData> extends ApiEndpoint {
  static final isMeta = (String e) => e.startsWith('\$');

  final TransferBean<TData> bean;
  final bool allowPatch, allowPost, allowDelete;

  ApiResource._(RoutePattern path, this.bean, this.allowPatch, this.allowPost,
      this.allowDelete)
      : super(path);

  Future<dynamic> getMetaData(ApiRequest request, String name);

  bool _isMetaRequest(ApiRequest request) {
    return request.queryParams.keys.any(isMeta);
  }

  Future<ApiResponse> _handleMetaRequest(ApiRequest request) async {
    final vars = request.queryParams.keys
        .where(isMeta)
        .map((e) => e.substring(1))
        .take(50);
    final result = <String, dynamic>{};
    for (final name in vars) {
      result[name] = await getMetaData(request, name);
    }
    return JsonResponse(result);
  }
}

abstract class ListApiResource<TData, TId> extends ApiResource<TData> {
  final String idParam;

  ListApiResource(RoutePattern path, TransferBean<TData> bean,
      {this.idParam = 'id',
      bool allowPatch = true,
      bool allowPost = true,
      bool allowDelete = true})
      : super._(path, bean, allowPatch, allowPost, allowDelete) {
    if (!path.containsParam(idParam)) {
      throw ApiError(
          'ApiResource path does not contain the id placeholder: $idParam');
    }

    if (TId != String && TId != int) {
      throw ApiError('ApiResource only allows int or String as id type.');
    }
  }

  @override
  Future<dynamic> getMetaData(ApiRequest request, String name) async {
    if (name.toLowerCase() == 'count') {
      return getSize(request);
    }

    throw ApiRequestException.notFound('Meta-Property $name not found.');
  }

  Future<TData> getElement(ApiRequest request, TId id);

  Future<List<TData>> getList(ApiRequest request, int offset, int limit);

  Future<int> getSize(ApiRequest request);

  //TODO rethink return data structure
  Future<Tuple<TId, TData>> postElement(
          ApiRequest request, TData element) async =>
      throw ApiError('postElement allowed but not implemented!');

  Future<TData> patchElement(ApiRequest request, TId id, TData element) async =>
      throw ApiError('patchElement allowed but not implemented!');

  Future deleteElement(ApiRequest request, TId id) async =>
      throw ApiError('deleteElement allowed but not implemented!');

  @override
  Future get(ApiRequest request) async {
    if (_isMetaRequest(request)) {
      return _handleMetaRequest(request);
    }

    final id = _findId(request.route);

    if (id != null) {
      return await getElement(request, id);
    } else {
      final offset = request.getParam<int>('offset', 0);
      final limit = request.getParam<int>('limit', 25);

      return await getList(request, offset, limit);
    }
  }

  @override
  Future post(ApiRequest request) async {
    if (!allowPost) {
      throw ApiRequestException.methodNotAllowed();
    }

    final json = await request.getJsonBody();
    final data = bean.toObject(json);
    final result = await postElement(request, data);
    return result.b;
  }

  @override
  Future patch(ApiRequest request) async {
    if (!allowPatch) {
      throw ApiRequestException.methodNotAllowed();
    }

    final id = _findId(request.route);
    if (id == null) {
      throw ApiRequestException.badRequest('Missing id');
    }

    final json = await request.getJsonBody();
    final data = bean.toObject(json);
    final result = await patchElement(request, id, data);
    return result;
  }

  @override
  Future delete(ApiRequest request) async {
    if (!allowDelete) {
      throw ApiRequestException.methodNotAllowed();
    }

    final id = _findId(request.route);
    if (id == null) {
      throw ApiRequestException.badRequest('Missing id');
    }

    return await deleteElement(request, id);
  }

  TId? _findId(Route route) {
    if (TId == int) {
      return route.getParamInt(idParam) as TId?;
    } else if (TId == String) {
      return route.getParam(idParam) as TId?;
    } else {
      return null;
    }
  }
}

abstract class SingleObjectApiResource<TData> extends ApiResource<TData> {
  SingleObjectApiResource(RoutePattern path, TransferBean<TData> bean,
      {bool allowPatch = true, bool allowPost = true, bool allowDelete = true})
      : super._(path, bean, allowPatch, allowPost, allowDelete);

  Future<TData> getElement();

  //TODO rethink return data structure
  Future<Tuple<int, TData>> postElement(TData element) async =>
      throw ApiError('postElement allowed but not implemented!');

  Future<TData> patchElement(TData element) async =>
      throw ApiError('patchElement allowed but not implemented!');

  Future deleteElement() async =>
      throw ApiError('deleteElement allowed but not implemented!');

  @override
  Future get(ApiRequest request) async {
    if (_isMetaRequest(request)) {
      return _handleMetaRequest(request);
    }

    return await getElement();
  }

  @override
  Future post(ApiRequest request) async {
    if (!allowPost) {
      throw ApiRequestException.methodNotAllowed();
    }

    final json = await request.getJsonBody();
    final data = bean.toObject(json);
    final result = await postElement(data);
    return {'result': result.b};
  }

  @override
  Future patch(ApiRequest request) async {
    if (!allowPatch) {
      throw ApiRequestException.methodNotAllowed();
    }

    final json = await request.getJsonBody();
    final data = bean.toObject(json);
    final result = await patchElement(data);
    return {'result': result};
  }

  @override
  Future delete(ApiRequest request) async {
    if (!allowDelete) {
      throw ApiRequestException.methodNotAllowed();
    }

    return await deleteElement();
  }

  @override
  Future<dynamic> getMetaData(ApiRequest request, String name) async {
    throw ApiRequestException.notFound('Meta-Property $name not found.');
  }
}
