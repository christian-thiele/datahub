import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_config.dart';
import 'package:datahub_aperture/src/aperture_service/resource_element_endpoint.dart';
import 'package:datahub_aperture/src/aperture_service/resources_endpoint.dart';

/// This service provides Endpoints for serving the Aperture frontend.
///
/// TODO(CTH): docs
class ApertureService extends ApiService {
  ApertureService({
    String? config,
    required ApertureConfigDelegate apertureConfig,
  }) : super(
          config,
          [
            ResourcesEndpoint(resources: apertureConfig.resources),
            for (final resource in apertureConfig.resources)
              ResourceElementEndpoint(resource: resource),
          ],
        );
}
