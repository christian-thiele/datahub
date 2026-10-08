import 'package:datahub_aperture/api.dart';

bool isCompatibleBackendVersion(String? backendVersion) =>
    backendVersion == apertureVersion;

class IncompatibleBackendException implements Exception {
  final String? backendVersion;

  IncompatibleBackendException(this.backendVersion);

  @override
  String toString() =>
      'Incompatible backend version ${backendVersion ?? '(unknown)'}, '
      'frontend expects $apertureVersion.';
}
