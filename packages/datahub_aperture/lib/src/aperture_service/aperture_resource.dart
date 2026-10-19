import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/utils.dart';

import 'aperture_action.dart';

class const ApertureResource({
  required final Find<DataRepository> repository,
  final List<ApertureAction> actions = const [],
  final bool allowCreate = true,
  final bool allowUpdate = true,
  final bool allowDelete = true,
}) {
  ResourceDescription buildDescription(Iterable<DataBean> beans) =>
      buildResourceDescription(this, beans);
}
