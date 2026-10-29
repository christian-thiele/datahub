import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub_aperture_frontend/models/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the [Preferences] of the user on this device (in the local storage of
/// the browser on the web).
class PreferencesService {
  static const _preferencesKey = 'preferences';
  final _prefs = Lazy<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
  );

  /// The stored preferences, the defaults if there are none or they can not
  /// be read.
  Future<Preferences> load() async {
    final prefs = await _prefs.get();
    if (prefs.getString(_preferencesKey) case final json?) {
      try {
        return $Preferences.fromJson(jsonDecode(json));
      } catch (_) {
        // defaults instead
      }
    }

    return const Preferences();
  }

  Future<void> save(Preferences preferences) async {
    final prefs = await _prefs.get();
    await prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
  }
}
