import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/collection.dart';

/// Standardized REST collection endpoint.
///
/// This endpoint provides a REST interface for querying paged collections.
///
/// To enable single item requests by id, override [getItemById] and make sure
/// [routePattern] contains an id route parameter. If the parameter name is not
/// 'id', provide the correct parameter name in [idParam].
/// To disable single item requests use [void] as [Id] type parameter and
/// omit the id route parameter.
abstract class RestCollectionEndpoint<T, Id> extends ApiEndpoint {
  final String idParam;
  final int defaultQueryLength;

  RestCollectionEndpoint(
    super.routePattern, {
    this.idParam = 'id',
    this.defaultQueryLength = 25,
  });

  @override
  Future get(ApiRequest request) async {
    final id = request.route.getParam<Id?>(idParam);
    if (id != null) {
      if (TypeCheck<void>().isSubtypeOf<Id>()) {
        throw ApiRequestException.notFound();
      }

      return await getItemById(request, id);
    }

    if (request.getParam<String?>('\$count') != null) {
      return JsonResponse({'count': await getLength(request)});
    }

    final offset = request.getParam<int?>('offset') ?? 0;
    final length = request.getParam<int?>('length') ?? defaultQueryLength;
    return await getItems(request, offset, length);
  }

  Future<T> getItemById(ApiRequest request, Id id) =>
      throw ApiRequestException.notFound();

  Future<int> getLength(ApiRequest request);

  Future<List<T>> getItems(ApiRequest request, int offset, int length);
}
