import 'package:datahub_aperture_frontend/blocs/preferences_cubit.dart';
import 'package:datahub_aperture_frontend/models/preferences.dart';
import 'package:datahub_aperture_frontend/services/preferences_service.dart';
import 'package:datahub_aperture_frontend/utils/date_time_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => DateTimeFormatter.current = const DateTimeFormatter());

  test('starts with the defaults', () async {
    final preferences = await PreferencesService().load();

    expect(preferences.language, isNull);
    expect(preferences.dateTimeFormat, DateTimeFormatPreference.localized);
    expect(preferences.timeZone, TimeZonePreference.local);
  });

  test('keeps changes for the next start', () async {
    final service = PreferencesService();
    final cubit = PreferencesCubit(service, await service.load());

    await cubit.setLanguage('de');
    await cubit.setDateTimeFormat(DateTimeFormatPreference.iso);
    await cubit.setTimeZone(TimeZonePreference.utc);
    await cubit.close();

    final preferences = await PreferencesService().load();
    expect(preferences.language, 'de');
    expect(preferences.dateTimeFormat, DateTimeFormatPreference.iso);
    expect(preferences.timeZone, TimeZonePreference.utc);
  });

  test('switches back to the language of the system', () async {
    final service = PreferencesService();
    final cubit = PreferencesCubit(service, const Preferences(language: 'de'));

    await cubit.setLanguage(null);

    expect(cubit.state.language, isNull);
    expect((await PreferencesService().load()).language, isNull);
  });

  test('starts with the defaults if the stored ones can not be read', () async {
    SharedPreferences.setMockInitialValues({
      'preferences': '{"dateTimeFormat":"unknown","timeZone":"utc"}',
    });

    final preferences = await PreferencesService().load();

    expect(preferences.dateTimeFormat, DateTimeFormatPreference.localized);
    expect(preferences.timeZone, TimeZonePreference.local);
  });

  test('formats date times as preferred', () async {
    final cubit = PreferencesCubit(
      PreferencesService(),
      const Preferences(timeZone: TimeZonePreference.utc),
    );
    expect(DateTimeFormatter.current.timeZone, TimeZonePreference.utc);

    await cubit.setDateTimeFormat(DateTimeFormatPreference.iso);
    expect(DateTimeFormatter.current.format, DateTimeFormatPreference.iso);
    expect(DateTimeFormatter.current.timeZone, TimeZonePreference.utc);
  });
}
