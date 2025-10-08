import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/services.dart';

class ApertureDataResource {
  final DataBean bean;
  final Find<DataRepository> repository;

  const ApertureDataResource(this.bean, this.repository);
}
