// ignore_for_file: dead_code

import 'dart:convert';
import 'dart:math' as math;

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_aperture/src/utils/data_description_builders.dart';

class ApertureApi extends ApiNode {
  final Config<String> title;
  final ApertureTheme theme;
  final ApertureTileSource tileSource;
  final List<ApertureResource> resources;
  final List<ApertureAction> actions;
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
    this.tileSource = const OpenStreetMapTileSource(),
    this.resources = const [],
    this.actions = const [],
    this.basePath = const Config(
      'aperture.basePath',
      defaultValue: '/aperture',
    ),
    this.oidcIssuer = const Config('aperture.oidcIssuer'),
    this.oidcAudience = const Config('aperture.oidcAudience'),
    this.oidcScopes = const Config('aperture.oidcScopes', defaultValue: []),
    this.oidcClientId = const Config(
      'aperture.oidcClientId',
      defaultValue: 'aperture',
    ),
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
        get: (request) async => ApertureBootstrap(
          version: apertureVersion,
          title: title.read(),
          theme: theme,
          environment: Context.ofZone().environment,
          mapTiles: await tileSource.resolve(),
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
              if (!resource.allowCreate) {
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
              } else if (findResourceWorkflow(resource) case final workflow?) {
                final id = repo.bean.requireIdField.valueOf(object);
                if (await repo.readById(id) != null) {
                  throw ApiRequestException(409, 'Element $id exists already.');
                }
                created = await workflow.start(object);
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

              if (!resource.allowUpdate) {
                throw ApiRequestException.methodNotAllowed();
              }

              final workflow = findResourceWorkflow(resource);
              var stateChanged = false;
              final result = await repo.atomic(() async {
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

                if (workflow != null && data.from == null) {
                  final stateField = workflow.describe().stateField;
                  stateChanged =
                      existing.toJson()[stateField] !=
                      (object as DataObject).toJson()[stateField];
                }

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

              if (stateChanged) {
                await workflow!.resume(elementId);
              }
              return result;
            },
            delete: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = resources.firstWhere(
                (resource) => buildResourceId(resource) == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final elementId = request.getRouteParam<String>('elementId');
              final repo = resource.repository.find();

              if (!resource.allowDelete) {
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

              final parameters = _decodeActionParameters(
                action,
                await request.getJsonBody(),
              );
              await action.handle(elementId, parameters);
              return {};
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

              final parameters = _decodeActionParameters(
                action,
                await request.getJsonBody(),
              );
              await action.handle(null, parameters);
              return {};
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern(
              '$base/api/resources/{resourceId}/workflow/events',
            ),
            get: (request) async {
              final workflow = _workflowOf(request);
              final offset = request.getParam<int?>('offset') ?? 0;
              final limit = math.min(
                100,
                request.getParam<int?>('limit') ?? 50,
              );
              final status = switch (request.getParam<String?>('status')) {
                final status? => const JsonDataCodec().decodeEnum(
                  status,
                  WorkflowEventStatus.values,
                  name: 'status',
                ),
                null => null,
              };

              final events = await workflow.events(
                elementId: request.getParam<String?>('elementId'),
                status: status,
                offset: offset,
                limit: limit + 1,
              );
              return ResourceWorkflowEventsResponse(
                hasNextPage: events.length > limit,
                data: [
                  for (final event in events.take(limit))
                    ResourceWorkflowEvent(
                      event: event,
                      running: workflow.isRunning(event),
                    ),
                ],
              );
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern(
              '$base/api/resources/{resourceId}/workflow/events/{eventId}',
            ),
            delete: (request) async {
              await _workflowOf(
                request,
              ).cancel(request.getRouteParam<String>('eventId'));
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern(
              '$base/api/resources/{resourceId}/workflow/events/{eventId}/retry',
            ),
            post: (request) async {
              await _workflowOf(
                request,
              ).retry(request.getRouteParam<String>('eventId'));
              return {};
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern(
              '$base/api/resources/{resourceId}/elements/{elementId}/workflow/history',
            ),
            get: (request) async {
              final workflow = _workflowOf(request);
              if (!workflow.describe().writesHistory) {
                throw ApiRequestException.notFound(
                  'The history of the workflow is not written.',
                );
              }

              return await workflow.history(
                request.getRouteParam<String>('elementId'),
                offset: request.getParam<int?>('offset') ?? 0,
                limit: math.min(100, request.getParam<int?>('limit') ?? 50),
                newestFirst: true,
              );
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern(
              '$base/api/resources/{resourceId}/elements/{elementId}/workflow/signals/{signalId}',
            ),
            post: (request) async {
              await _workflowOf(request).sendJson(
                request.getRouteParam<String>('signalId'),
                await request.getJsonBody(),
                elementId: request.getRouteParam<String>('elementId'),
              );
              return {};
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern(
              '$base/api/resources/{resourceId}/elements/{elementId}/workflow/resume',
            ),
            post: (request) async {
              await _workflowOf(
                request,
              ).resume(request.getRouteParam<String>('elementId'));
              return {};
            },
          ),
        ],
      ),
    ];
  }

  /// The workflow of the resource of [request], see [findResourceWorkflow].
  Workflow _workflowOf(ApiRequest request) {
    final resourceId = request.getRouteParam<String>('resourceId');
    final resource = resources.firstWhere(
      (resource) => buildResourceId(resource) == resourceId,
      orElse: () => throw ApiRequestException.notFound(),
    );
    return findResourceWorkflow(resource) ??
        (throw ApiRequestException.notFound('The resource has no workflow.'));
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
      if (filter case ResourceFilter(:final search?)) {
        elementFilter = _buildSearchFilter(repo, search);
      } else if (filter case ResourceFilter(
        :final type?,
        :final fieldId?,
        :final value,
      )) {
        elementFilter =
            _tryBuildFilter(
              bean.fields.firstWhere((e) => e.name == fieldId),
              switch (type) {
                ResourceFilterType.equals => CompareType.equals,
                ResourceFilterType.notEquals => CompareType.notEquals,
                ResourceFilterType.greaterThan => CompareType.greaterThan,
                ResourceFilterType.lessThan => CompareType.lessThan,
                ResourceFilterType.contains => CompareType.contains,
              },
              value,
            ) ??
            Filter.empty;
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

  static Filter _buildSearchFilter(DataRepository repo, String search) {
    final words = search.split(RegExp('\\W+'));

    final searchFields = <DataField>[];
    for (final field in repo.bean.fields) {
      final apertureField = field.metaOfType<ApertureField>();
      if (apertureField?.allowSearch == false) {
        continue;
      }

      bool isSearchField = switch (field) {
        DataField<dynamic, String?>() => true,
        DataField<dynamic, Enum?>() => true,
        DataField<dynamic, int?>() => true,
        DataField<dynamic, double?>() => true,
        DataField<dynamic, List<String?>?>() => true,
        _ => false,
      };

      if (isSearchField) {
        searchFields.add(field);
      }
    }

    return Filter.andGroup([
      for (final word in words)
        Filter.orGroup([
          for (final field in searchFields)
            ?_tryBuildFilter(field, CompareType.contains, word),
        ]),
    ]);
  }

  static Sort _buildSort(DataRepository repo, String? fieldId, bool ascending) {
    if (fieldId == null) {
      return Sort.empty;
    }
    final field = repo.bean.fields.firstWhere((e) => e.name == fieldId);
    return field.sort(ascending);
  }

  static Filter? _tryBuildFilter(
    DataField<dynamic, dynamic> field,
    CompareType type,
    String? value,
  ) {
    try {
      return CompareFilter(
        field,
        type,
        ValueExpression(_alignFieldValue(field, value)),
      );
    } on CodecException catch (e) {
      log.trace('Filter error. Discarding filter element.', error: e);
      return null;
    }
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

    if (field.type.isSubtypeOf<Enum?>()) {
      return value;
    }

    return const JsonDataCodec().decodeType(field.type, value);
  }

  static DataObject _decodeActionParameters(
    ApertureAction action,
    dynamic json,
  ) {
    try {
      return action.decodeParameters(json);
    } on CodecException catch (e) {
      _throwCodecApiException(e);
    }
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
