import 'dart:convert';
import 'dart:math' as math;

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/services.dart';

class ApertureApi extends ApiNode {
  final ApertureConfigDelegate configDelegate;

  final Config<String> basePath;
  final Config<String> oidcIssuer;
  final Config<String?> oidcAudience;
  final Config<List<String>> oidcScopes;
  final Config<String?> oidcClientId;
  final Config<String?> oidcClientSecret;
  final Config<String> oidcIdentityField;
  final Config<String> oidcUsernameField;

  ApertureApi({
    required this.configDelegate,
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
          matchers: [
            RoutePattern('$base/*'),
            HeaderRouteMatcher(header: 'x-aperture-flare', value: 'bootstrap'),
          ],
        ),
        get: (request) => ApertureBootstrap(
          title: 'Aperture',
          theme: configDelegate.theme,
          baseUrl: configDelegate.baseUrl,
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
              return configDelegate.resources
                  .map((e) => e.description)
                  .toList();
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/resources/{resourceId}'),
            get: (request) async {
              final id = request.getRouteParam<String>('resourceId');
              return configDelegate.resources
                  .firstWhere(
                    (e) => e.description.id == id,
                    orElse: () => throw ApiRequestException.notFound(),
                  )
                  .description;
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/resources/{resourceId}/elements'),
            get: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = configDelegate.resources.firstWhere(
                (resource) => resource.description.id == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final offset = request.getParam<int?>('offset') ?? 0;
              final limit = math.min(
                100,
                request.getParam<int?>('limit') ?? 50,
              );
              final encodedFilter = request.getParam<String?>('filter');
              final filter = encodedFilter != null
                  ? $ResourceFilter.fromJson(jsonDecode(encodedFilter))
                  : null;

              return resource.repository.getElements(filter, offset, limit);
            },
            post: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = configDelegate.resources.firstWhere(
                (resource) => resource.description.id == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              if (resource.repository
                  case final ApertureResourceWriteRepository repository) {
                final data = await request.getData<ResourceRevisionRequest>(
                  $ResourceRevisionRequest.bean,
                );
                return await repository.createElement(
                  data.fieldData,
                  data.revisionLive,
                );
              } else {
                throw ApiRequestException.methodNotAllowed();
              }
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern(
              '$base/api/resources/{resourceId}/elements/{elementId}',
            ),
            get: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = configDelegate.resources.firstWhere(
                (resource) => resource.description.id == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final elementId = request.getRouteParam<String>('elementId');
              final revisionId = request.getParam<String?>('revisionId');
              return await resource.repository.getElement(
                elementId,
                revisionId,
              );
            },
            patch: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = configDelegate.resources.firstWhere(
                (resource) => resource.description.id == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final elementId = request.getRouteParam<String>('elementId');
              final data = await request.getData($ResourceRevisionRequest.bean);

              if (resource.repository
                  case final ApertureResourceWriteRepository repository) {
                return await repository.updateElement(
                  elementId,
                  data.fieldData,
                  data.revisionLive,
                );
              } else {
                throw ApiRequestException.methodNotAllowed();
              }
            },
            delete: (request) async {
              final resourceId = request.getRouteParam<String>('resourceId');
              final resource = configDelegate.resources.firstWhere(
                (resource) => resource.description.id == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final elementId = request.getRouteParam<String>('elementId');
              final revisionLive = request.getParam<DateTime?>('revisionLive');

              if (resource.repository
                  case final ApertureResourceWriteRepository repository) {
                return await repository.deleteElement(elementId, revisionLive);
              } else {
                throw ApiRequestException.methodNotAllowed();
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

              final resource = configDelegate.resources.firstWhere(
                (resource) => resource.description.id == resourceId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final action = resource.actions.firstWhere(
                (action) => action.description.id == actionId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final parameters = await request.getJsonBody();

              final taskId = await action.handler(elementId, parameters);
              return {if (taskId != null) 'taskId': taskId};
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/actions'),
            get: (request) async {
              return configDelegate.actions.map((e) => e.description).toList();
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/actions/{actionId}'),
            post: (request) async {
              final actionId = request.getRouteParam<String>('actionId');

              final action = configDelegate.actions.firstWhere(
                (action) => action.description.id == actionId,
                orElse: () => throw ApiRequestException.notFound(),
              );

              final parameters = await request.getJsonBody();
              final taskId = await action.handler(null, parameters);
              return {if (taskId != null) 'taskId': taskId};
            },
          ),
          ResourceEndpoint(
            matcher: RoutePattern('$base/api/modules'),
            get: (request) async {
              return configDelegate.modules.map((e) => e.description).toList();
            },
          ),
          for (final module in configDelegate.modules)
            ...module.buildApiRoutes(
              '$base/api/modules/${module.description.id}',
            ),
        ],
      ),
    ];
  }
}
