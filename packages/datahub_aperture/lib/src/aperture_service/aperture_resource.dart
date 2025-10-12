import 'package:datahub_aperture/api.dart';

import 'aperture_resource_action.dart';
import 'aperture_resource_repository.dart';

class ApertureResource {
  final ResourceDescription description;
  final ApertureResourceRepository repository;
  final List<ApertureResourceAction> actions;

  ApertureResource({
    required this.description,
    required this.repository,
    this.actions = const [],
  });
}
