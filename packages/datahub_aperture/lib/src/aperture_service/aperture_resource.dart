import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';

import 'aperture_action.dart';

class ApertureResource {
  final ResourceDescription description;
  final Find<DataRepository> repository;
  final List<ApertureAction> actions;

  ApertureResource({
    required this.description,
    required this.repository,
    this.actions = const [],
  });
}
