import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/utils.dart';

import 'aperture_action.dart';

class ApertureResource {
  final Find<DataRepository> repository;
  final List<ApertureAction> actions;

  final bool allowCreate;
  final bool allowUpdate;
  final bool allowDelete;

  const ApertureResource({
    required this.repository,
    this.actions = const [],
    this.allowCreate = true,
    this.allowUpdate = true,
    this.allowDelete = true,
  });

  ResourceDescription buildDescription(Iterable<DataBean> beans) =>
      buildResourceDescription(this, beans);
}
