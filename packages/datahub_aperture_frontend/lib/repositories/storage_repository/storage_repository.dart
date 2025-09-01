import 'package:datahub_aperture_frontend/models/authentication.dart';

import '../repository.dart';

abstract interface class StorageRepository implements Repository {
  Future<Authentication?> getStoredAuthentication();

  Future<void> storeAuthentication(Authentication auth);

  Future<void> clear();
}
