import 'dart:convert';

import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:boost/boost.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_repository.dart';

class SharedPrefsStorageRepository implements StorageRepository {
  final _prefs = Lazy<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
  );
  static const _authKey = 'authentication';

  SharedPrefsStorageRepository();

  @override
  Future<void> initialize() async {
    await _prefs.get();
  }

  @override
  Future<Authentication?> getStoredAuthentication() async {
    final serialized = (await _prefs.get()).getString(_authKey);
    if (serialized != null) {
      try {
        return Authentication.fromJson(jsonDecode(serialized));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> storeAuthentication(Authentication auth) async {
    (await _prefs.get()).setString(_authKey, jsonEncode(auth));
  }

  @override
  Future<void> clear() async {
    await (await _prefs.get()).clear();
  }

  @override
  Future<void> close() async {}
}
