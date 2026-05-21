import 'package:datahub_aperture/api.dart';

abstract interface class BootstrapRepository {
  Future<(Uri, ApertureBootstrap)> fetch();
}
