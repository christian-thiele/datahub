import 'package:datahub/data.dart';

part 'preferences.g.dart';

enum DateTimeFormatPreference { localized, numeric, iso }

enum TimeZonePreference { local, utc }

@Data()
class const Preferences({
  final String? language,
  final DateTimeFormatPreference dateTimeFormat =
      DateTimeFormatPreference.localized,
  final TimeZonePreference timeZone = TimeZonePreference.local,
}) extends $Preferences;
