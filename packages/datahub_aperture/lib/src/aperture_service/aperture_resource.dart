import 'package:datahub_aperture/api.dart';

import 'aperture_action.dart';
import 'aperture_resource_repository.dart';

class ApertureResource {
  final ResourceDescription description;
  final ApertureResourceRepository repository;
  final List<ApertureAction> actions;

  ApertureResource({
    required this.description,
    required this.repository,
    this.actions = const [],
  });
}
