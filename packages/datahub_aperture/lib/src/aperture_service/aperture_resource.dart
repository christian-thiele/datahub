import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/utils.dart';

import 'aperture_action.dart';
import 'resource_utils.dart';

class const ApertureResource<T extends DataObject>({
  required final Find<DataRepository<T>> repository,
  final List<ApertureAction> actions = const [],
  final DataField<T, dynamic>? defaultSortField,
  final bool defaultSortAscending = true,
  final SearchFilterBuilder? searchBuilder,
  final bool allowCreate = true,
  final bool allowUpdate = true,
  final bool allowDelete = true,
}) {
  ResourceDescription buildDescription(Iterable<DataBean> beans) =>
      buildResourceDescription(this, beans);
}
