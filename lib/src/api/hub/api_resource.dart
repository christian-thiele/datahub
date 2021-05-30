import 'package:boost/boost.dart';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub_common/common.dart';

abstract class ApiResource<TData> extends ApiEndpoint {
  static final isMeta = (String e) => e.startsWith('\$');

  final DTOFactory<TData> factory;
  final bool allowPatch, allowPost, allowDelete;

  ApiResource._(RoutePattern path, this.factory, this.allowPatch,
      this.allowPost, this.allowDelete)
      : super(path);

  Future<dynamic> getMetaData(String name);

  bool _isMetaRequest(ApiRequest request) {
    return request.queryParams.keys.any(isMeta);
  }

  Future<ApiResponse> _handleMetaRequest(ApiRequest request) async {
    final vars = request.queryParams.keys
        .where(isMeta)
        .map((e) => e.substring(1))
        .take(25); //TODO maybe setMetaParmLimit(...) or smth
    final result = <String, dynamic>{};
    for (final name in vars) {
      result[name] = await getMetaData(name);
    }
    return JsonResponse(result);
  }
}

abstract class ListApiResource<TData, TId> extends ApiResource<TData> {
  final String idParam;

  ListApiResource(RoutePattern path, DTOFactory<TData> factory,
      {this.idParam = 'id',
      bool allowPatch = true,
      bool allowPost = true,
      bool allowDelete = true})
      : super._(path, factory, allowPatch, allowPost, allowDelete) {
    if (!path.containsParam(idParam)) {
      throw ApiError(
          'ApiResource path does not contain the id placeholder: $idParam');
    }

    if (TId != String && TId != int) {
      throw ApiError('ApiResource only allows int or String as id type.');
    }

    if (TData is StringIdTransferObject && TId != String ||
        TData is IntIdTransferObject && TId != int) {
      throw ApiError('ApiResource<$TData, $TId> has mismatching id types.');
    }
  }

  //TODO implement getMetaData for length

  Future<TData> getElement(TId id);

  Future<List<TData>> getList(int offset, int limit);

  //TODO rethink return data structure
  Future<Tuple<int, TData>> postElement(TData element) async =>
      throw ApiError('postElement allowed but not implemented!');

  Future<TData> patchElement(TId id, TData element) async =>
      throw ApiError('patchElement allowed but not implemented!');

  Future deleteElement(TId id) async =>
      throw ApiError('deleteElement allowed but not implemented!');

  @override
  Future get(ApiRequest request) async {
    if (_isMetaRequest(request)) {
      return _handleMetaRequest(request);
    }

    final id = _findId(request.route);

    if (id != null) {
      return await getElement(id);
    } else {
      final offset = request.getParamInt('offset', 0);
      final limit = request.getParamInt('limit', 25);

      return await getList(offset, limit);
    }
  }

  @override
  Future post(ApiRequest request) async {
    if (!allowPost) {
      throw ApiRequestException.methodNotAllowed();
    }

    final json = request.getJsonBody();
    final data = factory.call(json);
    final result = await postElement(data);
    //TODO maybe don't reply with complete entry (performance?)
    return {'\$id': result.a, 'result': result.b};
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

    final json = request.getJsonBody();
    final data = factory.call(json);
    final result = await patchElement(id, data);
    //TODO maybe don't reply with complete entry (performance?)
    return {'\$id': id, 'result': result};
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

    return await deleteElement(id);
  }

  TId? _findId(Route route) {
    if (TId == int) {
      return route.getParamInt(idParam) as TId;
    } else if (TId == String) {
      return route.getParam(idParam) as TId;
    } else {
      return null;
    }
  }
}

abstract class SingleObjectApiResource<TData> extends ApiResource<TData> {
  SingleObjectApiResource(RoutePattern path, DTOFactory<TData> factory,
      {bool allowPatch = true, bool allowPost = true, bool allowDelete = true})
      : super._(path, factory, allowPatch, allowPost, allowDelete);

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

    final json = request.getJsonBody();
    final data = factory.call(json);
    final result = await postElement(data);
    //TODO maybe don't reply with complete entry (performance?)
    return {'result': result.b};
  }

  @override
  Future patch(ApiRequest request) async {
    if (!allowPatch) {
      throw ApiRequestException.methodNotAllowed();
    }

    final json = request.getJsonBody();
    final data = factory.call(json);
    final result = await patchElement(data);
    //TODO maybe don't reply with complete entry (performance?)
    return {'result': result};
  }

  @override
  Future delete(ApiRequest request) async {
    if (!allowDelete) {
      throw ApiRequestException.methodNotAllowed();
    }

    return await deleteElement();
  }
}
