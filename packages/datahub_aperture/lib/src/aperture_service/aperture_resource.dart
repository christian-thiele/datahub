import 'package:datahub_aperture/api.dart';

import 'aperture_resource_repository.dart';

class ApertureResource {
  final ResourceDescription description;
  final ApertureResourceRepository repository;

  ApertureResource({required this.description, required this.repository});
}
