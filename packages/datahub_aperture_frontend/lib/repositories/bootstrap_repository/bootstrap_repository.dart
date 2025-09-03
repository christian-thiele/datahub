import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/repositories/repository.dart';

abstract interface class BootstrapRepository implements Repository {
  Future<ApertureBootstrap> fetch();
}
