import 'package:datahub_aperture/src/aperture_service/resource_element_endpoint.dart';

import 'aperture_resource_repository.dart';
import 'models/api.dart';

class ApertureResource {
  final ResourceDescription description;
  final ApertureResourceRepository repository;

  ApertureResource({required this.description, required this.repository});
}
