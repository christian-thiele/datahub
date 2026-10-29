import 'package:datahub_aperture_frontend/models/preferences.dart';
import 'package:intl/intl.dart';

/// Shows and reads date times as the user prefers, in the language of
/// [Intl.defaultLocale].
class DateTimeFormatter {
  /// The formatter of the preferences of the user, kept up to date by
  /// `PreferencesCubit` like [Intl.defaultLocale] is by the localizations.
  static DateTimeFormatter current = const DateTimeFormatter();

  final DateTimeFormatPreference format;
  final TimeZonePreference timeZone;

  const DateTimeFormatter({
    this.format = DateTimeFormatPreference.localized,
    this.timeZone = TimeZonePreference.local,
  });

  DateTimeFormatter.of(Preferences preferences)
    : this(format: preferences.dateTimeFormat, timeZone: preferences.timeZone);

  DateFormat get dateFormat => switch (format) {
    DateTimeFormatPreference.localized => DateFormat.yMMMd(),
    DateTimeFormatPreference.numeric => DateFormat.yMd(),
    DateTimeFormatPreference.iso => DateFormat('yyyy-MM-dd'),
  };

  DateFormat get timeFormat => switch (format) {
    DateTimeFormatPreference.localized ||
    DateTimeFormatPreference.numeric => DateFormat.Hm(),
    DateTimeFormatPreference.iso => DateFormat('HH:mm:ss'),
  };

  /// The same point in time as [value], in the preferred time zone.
  DateTime convert(DateTime value) => switch (timeZone) {
    TimeZonePreference.local => value.toLocal(),
    TimeZonePreference.utc => value.toUtc(),
  };

  /// The current time in the preferred time zone.
  DateTime now() => convert(DateTime.timestamp());

  String formatDateTime(DateTime value) {
    final converted = convert(value);
    return '${dateFormat.format(converted)} ${timeFormat.format(converted)}';
  }

  String formatDate(DateTime value) => dateFormat.format(convert(value));

  String formatTime(DateTime value) => timeFormat.format(convert(value));
}
