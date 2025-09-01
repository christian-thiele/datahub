import 'dart:convert';
import 'dart:math';

import 'package:datahub/api.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource_repository.dart';

import 'package:datahub_aperture/api.dart';

class ResourceElementEndpoint extends ApiEndpoint {
  final ApertureResource resource;

  ResourceElementEndpoint({
    required this.resource,
  }) : super(RoutePattern(
            '/api/resources/${Uri.encodeComponent(resource.description.id)}/elements/{id?}'));

  @override
  Future<dynamic> get(ApiRequest request) async {
    if (request.route.getParam<String?>('id') case final id?) {
      final revisionId = request.getParam<String?>('revisionId');

      return await resource.repository.getElement(id, revisionId);
    }

    final offset = request.getParam<int?>('offset') ?? 0;
    final limit = min(100, request.getParam<int?>('limit') ?? 50);
    final encodedFilter = request.getParam<String?>('filter');
    final filter = encodedFilter != null
        ? ResourceFilter.bean.fromJson(jsonDecode(encodedFilter))
        : null;

    return resource.repository.getElements(filter, offset, limit);
  }

  @override
  Future<ResourceData> post(ApiRequest request) async {
    if (request.route.getParam<String?>('id') case String()) {
      throw ApiRequestException.methodNotAllowed();
    }

    if (resource.repository
        case final ApertureResourceWriteRepository repository) {
      final data = await request
          .getData<ResourceRevisionRequest>(ResourceRevisionRequest.bean);
      return await repository.createElement(
        data.fieldData,
        data.revisionLive,
      );
    } else {
      throw ApiRequestException.methodNotAllowed();
    }
  }

  @override
  Future<ResourceData> patch(ApiRequest request) async {
    if (request.route.getParam<String?>('id') case final id?) {
      final data = await request.getData(ResourceRevisionRequest.bean);

      if (resource.repository
          case final ApertureResourceWriteRepository repository) {
        return await repository.updateElement(
          id,
          data.fieldData,
          data.revisionLive,
        );
      } else {
        throw ApiRequestException.methodNotAllowed();
      }
    }

    throw ApiRequestException.methodNotAllowed();
  }

  @override
  Future<ResourceData> delete(ApiRequest request) async {
    if (request.route.getParam<String?>('id') case final id?) {
      final revisionLive = request.getParam<DateTime?>('revisionLive');

      if (resource.repository
          case final ApertureResourceWriteRepository repository) {
        return await repository.deleteElement(id, revisionLive);
      } else {
        throw ApiRequestException.methodNotAllowed();
      }
    }

    throw ApiRequestException.methodNotAllowed();
  }
}
