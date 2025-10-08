import 'dart:convert';
import 'dart:math' as math;

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/frontend_bundle.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_aperture/src/utils/static_bundle_endpoint.dart';

class ApertureApi extends ApiNode {
  final ApertureConfigDelegate configDelegate;

  final Config<String> oidcIssuer;
  final Config<String?> oidcAudience;
  final Config<List<String>> oidcScopes;
  final Config<String?> oidcClientId;
  final Config<String?> oidcClientSecret;
  final Config<String> oidcIdentityField;
  final Config<String> oidcUsernameField;

  ApertureApi({
    required this.configDelegate,
    this.oidcIssuer = const Config('aperture.oidcIssuer'),
    this.oidcAudience = const Config('aperture.oidcAudience'),
    this.oidcScopes = const Config('aperture.oidcScopes', defaultValue: []),
    this.oidcClientId = const Config('aperture.oidcClientId'),
    this.oidcClientSecret = const Config('aperture.oidcClientSecret'),
    this.oidcIdentityField =
        const Config('aperture.oidcIdentityField', defaultValue: 'sub'),
    this.oidcUsernameField =
        const Config('aperture.oidcUsernameField', defaultValue: 'email'),
  });

  @override
  List<ApiRoute> buildRoutes() {
    return [
      ResourceEndpoint(
        matcher: RoutePattern('/api/bootstrap'),
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
            matcher: RoutePattern('/api/resources/{id?}'),
            get: (request) async {
              final id = request.uri.pathSegments.elementAtOrNull(2);
              if (id case final id?) {
                return configDelegate.resources
                    .firstWhere((e) => e.description.id == id,
                        orElse: () => throw ApiRequestException.notFound())
                    .description;
              }

              return configDelegate.resources
                  .map((e) => e.description)
                  .toList();
            },
          ),
          for (final resource in configDelegate.resources)
            ResourceEndpoint(
              matcher: RoutePattern(
                  '/api/resources/${Uri.encodeComponent(resource.description.id)}/elements/{id?}'),
              get: (request) async {
                if (request.getRouteParam<String?>('id') case final id?) {
                  final revisionId = request.getParam<String?>('revisionId');
                  return await resource.repository.getElement(id, revisionId);
                }

                final offset = request.getParam<int?>('offset') ?? 0;
                final limit =
                    math.min(100, request.getParam<int?>('limit') ?? 50);
                final encodedFilter = request.getParam<String?>('filter');
                final filter = encodedFilter != null
                    ? $ResourceFilter.fromJson(jsonDecode(encodedFilter))
                    : null;

                return resource.repository.getElements(filter, offset, limit);
              },
              post: (request) async {
                if (request.getRouteParam<String?>('id') case String()) {
                  throw ApiRequestException.methodNotAllowed();
                }

                if (resource.repository
                    case final ApertureResourceWriteRepository repository) {
                  final data = await request.getData<ResourceRevisionRequest>(
                      $ResourceRevisionRequest.bean);
                  return await repository.createElement(
                    data.fieldData,
                    data.revisionLive,
                  );
                } else {
                  throw ApiRequestException.methodNotAllowed();
                }
              },
              patch: (request) async {
                if (request.getRouteParam<String?>('id') case final id?) {
                  final data =
                      await request.getData($ResourceRevisionRequest.bean);

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
              },
              delete: (request) async {
                if (request.getRouteParam<String?>('id') case final id?) {
                  final revisionLive =
                      request.getParam<DateTime?>('revisionLive');

                  if (resource.repository
                      case final ApertureResourceWriteRepository repository) {
                    return await repository.deleteElement(
                      id,
                      revisionLive,
                    );
                  } else {
                    throw ApiRequestException.methodNotAllowed();
                  }
                }

                throw ApiRequestException.methodNotAllowed();
              },
            ),
        ],
      ),
      StaticBundleEndpoint(
        matcher: RoutePattern('/*'),
        bundle: frontendBundle,
      ),
    ];
  }
}
