import 'package:bloc/bloc.dart';
import 'package:datahub_aperture_frontend/models/preferences.dart';
import 'package:datahub_aperture_frontend/services/preferences_service.dart';
import 'package:datahub_aperture_frontend/utils/date_time_formatter.dart';

/// The preferences of the user, saved on every change.
///
/// Also keeps [DateTimeFormatter.current] up to date, so date times are shown
/// as preferred wherever they are formatted.
class PreferencesCubit extends Cubit<Preferences> {
  final PreferencesService _preferencesService;

  PreferencesCubit(this._preferencesService, super.initialState) {
    DateTimeFormatter.current = DateTimeFormatter.of(state);
  }

  Future<void> setLanguage(String? language) => _update(
    Preferences(
      language: language,
      dateTimeFormat: state.dateTimeFormat,
      timeZone: state.timeZone,
    ),
  );

  Future<void> setDateTimeFormat(DateTimeFormatPreference format) => _update(
    Preferences(
      language: state.language,
      dateTimeFormat: format,
      timeZone: state.timeZone,
    ),
  );

  Future<void> setTimeZone(TimeZonePreference timeZone) => _update(
    Preferences(
      language: state.language,
      dateTimeFormat: state.dateTimeFormat,
      timeZone: timeZone,
    ),
  );

  Future<void> _update(Preferences preferences) async {
    DateTimeFormatter.current = DateTimeFormatter.of(preferences);
    emit(preferences);
    await _preferencesService.save(preferences);
  }
}
