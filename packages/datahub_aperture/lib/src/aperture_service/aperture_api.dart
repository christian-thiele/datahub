// ignore_for_file: dead_code

import 'dart:convert';
import 'dart:math' as math;

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_aperture/src/utils/data_description_builders.dart';

class ApertureApi extends ApiNode {
  final Config<String> title;
  final ApertureTheme theme;
  final List<ApertureResource> resources;
  final List<ApertureAction> actions;
  final List<ApertureModule> modules;
  final Config<String> basePath;
  final Config<String> oidcIssuer;
  final Config<String?> oidcAudience;
  final Config<List<String>> oidcScopes;
  final Config<String?> oidcClientId;
  final Config<String?> oidcClientSecret;
  final Config<String> oidcIdentityField;
  final Config<String> oidcUsernameField;

  const ApertureApi({
    this.title = const Config('aperture.title', defaultValue: 'Aperture'),
    this.theme = const ApertureTheme(),
    this.resources = const [],
    this.actions = const [],
    this.modules = const [],
    this.basePath = const Config(
      'aperture.basePath',
      defaultValue: '/aperture',
    ),
    this.oidcIssuer = const Config('aperture.oidcIssuer'),
    this.oidcAudience = const Config('aperture.oidcAudience'),
    this.oidcScopes = const Config('aperture.oidcScopes', defaultValue: []),
    this.oidcClientId = const Config('aperture.oidcClientId'),
    this.oidcClientSecret = const Config('aperture.oidcClientSecret'),
    this.oidcIdentityField = const Config(
      'aperture.oidcIdentityField',
      defaultValue: 'sub',
    ),
    this.oidcUsernameField = const Config(
      'aperture.oidcUsernameField',
      defaultValue: 'email',
    ),
  });

  @override
  List<ApiRoute> buildRoutes() {
    final base = basePath.read();
    return [
      ResourceEndpoint(
        matcher: AllOfRouteMatcher(
          matchers: [RoutePattern('$base/api/bootstrap')],
        ),
        get: (request) => ApertureBootstrap(
          title: title.read(),
          theme: theme,
          environment: Context.ofZone().environment,
          oidcIssuer: oidcIssuer.read(),
          oidcScopes: oidcScopes.read(),
          oidcClientId: oidcClientId.read(),
          oidcClientSecret: oidcClientSecret.read(),
        ),
      ),
      JwtAuthMiddleware(
        issuer: oidcIssuer,
        audience: oidcAudience,
        routes: [
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/resources/'),
            get: (request) async {
              final beans = resources
                  .map((e) => e.repository.find().bean)
                  .toList();

              return resources.map((e) => e.buildDescription(beans)).toList();
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/resources/{resourceId}'),
            get: (request) async {
              final id = request.getRouteParam<String>('resourceId');

              final beans = resources
                  .map((e) => e.repository.find().bean)
                  .toList();

              return resources
                  .firstWhere(
                    (e) => buildResourceId(e) == id,
                    orElse: () => throw ApiRequestException.notFound(),
                  )
                  .buildDescription(beans);
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/resources/{resourceId}/elements'),
            get: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = resources.firstWhere(
                (resource) => buildResourceId(resource) == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final repo = resource.repository.find();
              final offset = request.getParam<int?>('offset') ?? 0;
              final limit = math.min(
                100,
                request.getParam<int?>('limit') ?? 50,
              );
              final encodedFilter = request.getParam<String?>('filter');
              final filter = encodedFilter != null
                  ? $ResourceFilter.fromJson(jsonDecode(encodedFilter))
                  : null;

              final sortFieldId = request.getParam<String?>('sort');
              final sortAscending = request.getParam<bool?>('asc') ?? true;

              final elements = await repo.readAll(
                filter: _buildFilter(repo, filter),
                sort: _buildSort(repo, sortFieldId, sortAscending),
                offset: offset,
                limit: limit + 1,
              );

              return ResourceElementsResponse(
                total: null,
                hasNextPage: elements.length > limit,
                data: elements
                    .take(limit)
                    .map((e) => _toResourceData(repo, e))
                    .toList(),
              );
            },
            post: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = resources.firstWhere(
                (resource) => buildResourceId(resource) == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final repo = resource.repository.find();
              const isWritableRepository = true; //TODO
              if (!isWritableRepository) {
                throw ApiRequestException.methodNotAllowed();
              }

              final data = await request.getData<ResourceRevisionRequest>(
                $ResourceRevisionRequest.bean,
              );

              final dynamic object;
              try {
                object = repo.bean.fromJson(data.fieldData);
              } on CodecException catch (e) {
                _throwCodecApiException(e);
              }

              repo.bean.validateConstraints(object);

              final DataObject created;
              if (data.from case final from?) {
                if (repo case RevisableDataRepository repo) {
                  created = await repo.create(object, from: from);
                } else {
                  throw ApiRequestException.badRequest(
                    'Repository does not support revisions.',
                  );
                }
              } else {
                created = await repo.create(object);
              }

              return _toResourceData(repo, created);
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern(
              '$base/api/resources/{resourceId}/elements/{elementId}',
            ),
            get: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = resources.firstWhere(
                (resource) => buildResourceId(resource) == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );
              final repo = resource.repository.find();

              final elementId = request.getRouteParam<String>('elementId');

              if (repo case RevisableDataRepository repo) {
                final version = request.getParam<int?>('version');
                final object = await repo.revisableReadById(
                  elementId,
                  version: version,
                );
                if (object == null) {
                  throw ApiRequestException.notFound();
                }
                final revisions = await repo.readRevisionsById(elementId);
                return _toResourceData(repo, object, revisions);
              } else {
                final object = await repo.readById(elementId);
                if (object == null) {
                  throw ApiRequestException.notFound();
                }
                return _toResourceData(repo, object);
              }
            },
            patch: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = resources.firstWhere(
                (resource) => buildResourceId(resource) == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final elementId = request.getRouteParam<String>('elementId');
              final data = await request.getData($ResourceRevisionRequest.bean);
              final repo = resource.repository.find();

              const isWritableRepository = true; //TODO
              if (!isWritableRepository) {
                throw ApiRequestException.methodNotAllowed();
              }

              return await repo.atomic(() async {
                final existing = await repo.readById(elementId);
                if (existing == null) {
                  throw ApiRequestException.notFound();
                }

                final combined = {...existing.toJson(), ...data.fieldData};

                final dynamic object;
                try {
                  object = repo.bean.fromJson(combined);
                } on CodecException catch (e) {
                  _throwCodecApiException(e);
                }

                repo.bean.validateConstraints(object);

                if (data.from case final from?) {
                  if (repo case RevisableDataRepository repo) {
                    await repo.updateById(object, from: from);
                  } else {
                    throw ApiRequestException.badRequest(
                      'Repository does not support revisions.',
                    );
                  }
                } else {
                  await repo.updateById(object);
                }
                if (repo case RevisableDataRepository repo) {
                  final revisions = await repo.readRevisionsById(elementId);
                  return _toResourceData(repo, revisions.first, revisions);
                } else {
                  final updated = await repo.readById(elementId);
                  return _toResourceData(repo, updated);
                }
              });
            },
            delete: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = resources.firstWhere(
                (resource) => buildResourceId(resource) == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final elementId = request.getRouteParam<String>('elementId');
              final repo = resource.repository.find();

              const isWritableRepository = true; // TODO
              if (!isWritableRepository) {
                throw ApiRequestException.methodNotAllowed();
              }

              if (request.getParam<DateTime?>('from') case final from?) {
                if (repo case RevisableDataRepository repo) {
                  await repo.deleteById(elementId, from: from);
                } else {
                  throw ApiRequestException.badRequest(
                    'Repository does not support revisions.',
                  );
                }
              } else {
                await repo.deleteById(elementId);
              }
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern(
              '$base/api/resources/{resourceId}/elements/{elementId}/actions/{actionId}',
            ),
            post: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final elementId = request.getRouteParam<String>('elementId');
              final actionId = request.getRouteParam<String>('actionId');

              final resource = resources.firstWhere(
                (resource) => buildResourceId(resource) == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final action = resource.actions.firstWhere(
                (action) => buildResourceActionId(action) == actionId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final parameters = await request.getJsonBody();

              final taskId = await action.handle(elementId, parameters);
              return {if (taskId != null) 'taskId': taskId};
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/actions'),
            get: (request) async {
              final beans = resources
                  .map((e) => e.repository.find().bean)
                  .toList();

              return actions.map((e) => e.buildDescription(beans)).toList();
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/actions/{actionId}'),
            post: (request) async {
              final actionId = request.getRouteParam<String>('actionId');

              final action = actions.firstWhere(
                (action) => buildResourceActionId(action) == actionId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final parameters = await request.getJsonBody();
              final taskId = await action.handle(null, parameters);
              return {if (taskId != null) 'taskId': taskId};
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/modules'),
            get: (request) async {
              return modules.map((e) => e.description).toList();
            },
          ),
          for (final module in modules)
            ...module.buildApiRoutes(
              '$base/api/modules/${module.description.id}',
            ),
        ],
      ),
    ];
  }

  static ResourceData _toResourceData(
    DataRepository repo,
    dynamic object, [
    List<RevisionData>? revisions,
  ]) {
    if (object case RevisionData(:final data, :final version)) {
      return ResourceData(
        id: repo.bean.requireIdField.valueOf(data).toString(),
        fieldData: data.toJson(),
        version: version,
        revisions: [
          for (final revision in revisions ?? <RevisionData>[])
            ResourceRevisionInfo(
              version: revision.version,
              type: switch (revision) {
                RevisionData(isDeleted: true) => ResourceRevisionType.delete,
                RevisionData(version: 0) => ResourceRevisionType.create,
                _ => ResourceRevisionType.update,
              },
              timestamp: revision.created,
              live: revision.from,
              userId: revision.creator,
              userName: revision.creator,
            ),
        ],
      );
    }

    return ResourceData(
      id: repo.bean.requireIdField.valueOf(object).toString(),
      fieldData: object.toJson(),
    );
  }

  static Filter _buildFilter(DataRepository repo, ResourceFilter? filter) {
    try {
      final bean = repo.bean;
      if (filter == null) {
        return Filter.empty;
      }

      final Filter elementFilter;
      if (filter case ResourceFilter(
        :final type?,
        :final fieldId?,
        :final value,
      )) {
        final field = bean.fields.firstWhere((e) => e.name == fieldId);
        elementFilter = CompareFilter(field, switch (type) {
          ResourceFilterType.equals => CompareType.equals,
          ResourceFilterType.notEquals => CompareType.notEquals,
          ResourceFilterType.greaterThan => CompareType.greaterThan,
          ResourceFilterType.lessThan => CompareType.lessThan,
          ResourceFilterType.contains => CompareType.contains,
        }, ValueExpression(_alignFieldValue(field, value)));
      } else {
        elementFilter = Filter.empty;
      }

      return Filter.andGroup([
        Filter.andGroup(
          (filter.and ?? <ResourceFilter>[]).map((e) => _buildFilter(repo, e)),
        ),
        Filter.orGroup(
          (filter.or ?? <ResourceFilter>[]).map((e) => _buildFilter(repo, e)),
        ),
        elementFilter,
      ]);
    } catch (e) {
      log.warn('Filter error: ${e.toString()}');
      return Filter.empty;
    }
  }

  static Sort _buildSort(DataRepository repo, String? fieldId, bool ascending) {
    if (fieldId == null) {
      return Sort.empty;
    }
    final field = repo.bean.fields.firstWhere((e) => e.name == fieldId);
    return field.sort(ascending);
  }

  // TODO find a way not to need this?
  static dynamic _alignFieldValue(
    DataField<dynamic, dynamic> field,
    String? value,
  ) {
    if (field.type.accepts(value)) {
      return value;
    }

    if (field.type.isSubtypeOf<List?>()) {
      return value;
    }

    return const JsonDataCodec().decodeType(field.type, value);
  }

  static Never _throwCodecApiException(CodecException e) {
    throw ApiRequestException(
      400,
      e.message,
      data: {
        if (e.name != null)
          'fields': {
            e.name: [e.message],
          },
      },
    );
  }
}
