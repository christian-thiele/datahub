import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/services.dart';

class ApertureDataResource {
  final DataBean bean;
  final ApertureResourceRepository repository;

  const ApertureDataResource(this.bean, this.repository);
}
