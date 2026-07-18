import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/utils.dart';

import 'aperture_action.dart';

class ApertureResource {
  final Find<DataRepository> repository;
  final List<ApertureAction> actions;

  const ApertureResource({required this.repository, this.actions = const []});

  ResourceDescription buildDescription(Iterable<DataBean> beans) =>
      buildResourceDescription(this, beans);
}
