import 'package:boost/boost.dart';
import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/api_error.dart';

abstract class ApiResource<TData> extends ApiEndpoint {
  final TData Function(Map<String, dynamic>) factory;
  final bool allowPatch, allowPost, allowDelete;

  ApiResource(path, this.factory,
      {this.allowPatch = true, this.allowPost = true, this.allowDelete = true})
      : super(path);

  Future<dynamic> getMetaData(String name);

  Future<TData> getElement(int id);

  Future<List<TData>> getList(int offset, int limit);

  //TODO rethink return data structure
  Future<Tuple<int, TData>> postElement(TData element) async =>
      throw ApiError('postElement allowed but not implemented!');

  Future<TData> patchElement(int id, TData element) async =>
      throw ApiError('patchElement allowed but not implemented!');

  Future deleteElement(int id) async =>
      throw ApiError('deleteElement allowed but not implemented!');

  @override
  Future get(ApiRequest request) async {
    final isMeta = (String e) => e.startsWith('\$');
    if (request.queryParams.keys.any(isMeta)) {
      final vars = request.queryParams.keys
          .where(isMeta)
          .take(25); //TODO maybe setMetaParmLimit(...) or smth
      final result = [];
      for (final name in vars) {
        result.add(await getMetaData(name));
      }
      return result;
    }

    final id = request.route.getParamInt('id');
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
    return {'\$id': result.a, 'result:': result.b};
  }

  @override
  Future patch(ApiRequest request) async {
    if (!allowPatch) {
      throw ApiRequestException.methodNotAllowed();
    }

    final id = request.route.getParamInt('id');
    if (id == null) {
      throw ApiRequestException.badRequest('Missing id');
    }

    final json = request.getJsonBody();
    final data = factory.call(json);
    final result = await patchElement(id, data);
    //TODO maybe don't reply with complete entry (performance?)
    return {'\$id': id, 'result:': result};
  }

  @override
  Future delete(ApiRequest request) async {
    if (!allowDelete) {
      throw ApiRequestException.methodNotAllowed();
    }

    final id = request.route.getParamInt('id');
    if (id == null) {
      throw ApiRequestException.badRequest('Missing id');
    }

    return await deleteElement(id);
  }
}
