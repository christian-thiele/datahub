import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource_action.dart';

class ApertureDataResource {
  final DataBean bean;
  final Find<DataRepository> repository;
  final List<ApertureResourceAction> actions;

  const ApertureDataResource(
    this.bean,
    this.repository, {
    this.actions = const [],
  });
}
