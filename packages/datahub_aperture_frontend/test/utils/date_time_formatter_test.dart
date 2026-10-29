import 'package:datahub_aperture_frontend/models/preferences.dart';
import 'package:datahub_aperture_frontend/utils/date_time_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

final _value = DateTime.utc(2026, 10, 29, 14, 5, 9);

String _format(DateTimeFormatPreference format) => DateTimeFormatter(
  format: format,
  timeZone: TimeZonePreference.utc,
).formatDateTime(_value);

void main() {
  setUpAll(() => initializeDateFormatting());

  test('formats date times as preferred', () {
    Intl.withLocale('en', () {
      expect(_format(DateTimeFormatPreference.localized), 'Oct 29, 2026 14:05');
      expect(_format(DateTimeFormatPreference.numeric), '10/29/2026 14:05');
      expect(_format(DateTimeFormatPreference.iso), '2026-10-29 14:05:09');
    });
  });

  test('formats date times in the language', () {
    Intl.withLocale('de', () {
      expect(
        _format(DateTimeFormatPreference.localized),
        '29. Okt. 2026 14:05',
      );
      expect(_format(DateTimeFormatPreference.numeric), '29.10.2026 14:05');
      expect(_format(DateTimeFormatPreference.iso), '2026-10-29 14:05:09');
    });
  });

  test('shows date times in the preferred time zone', () {
    const utc = DateTimeFormatter(timeZone: TimeZonePreference.utc);
    const local = DateTimeFormatter(timeZone: TimeZonePreference.local);

    expect(utc.convert(_value.toLocal()), _value);
    expect(utc.convert(_value.toLocal()).isUtc, isTrue);
    expect(local.convert(_value), _value.toLocal());
    expect(local.convert(_value).isUtc, isFalse);

    Intl.withLocale('en', () {
      expect(utc.formatTime(_value.toLocal()), '14:05');
      expect(
        local.formatTime(_value),
        DateFormat.Hm().format(_value.toLocal()),
      );
    });
  });
}
