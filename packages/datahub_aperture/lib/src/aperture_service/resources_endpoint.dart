import 'package:datahub/api.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource.dart';

class ResourcesEndpoint extends ApiEndpoint {
  final List<ApertureResource> resources;

  ResourcesEndpoint({required this.resources})
      : super(RoutePattern('/api/resources/{id?}'));

  @override
  Future<dynamic> get(ApiRequest request) async {
    if (request.route.getParam<String?>('id') case final id?) {
      return resources
          .firstWhere((e) => e.description.id == id,
              orElse: () => throw ApiRequestException.notFound())
          .description;
    }

    return resources.map((e) => e.description).toList();
  }
}
