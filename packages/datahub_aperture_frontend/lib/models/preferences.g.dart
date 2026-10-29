// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Preferences with DataObject<Preferences> {
  const $Preferences();
  static const $$codec = JsonDataCodec();
  static final $language = DataField<Preferences, String?>(
    name: 'language',
    valueOf: (p) => p.language,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $dateTimeFormat =
      DataField<Preferences, DateTimeFormatPreference>(
        name: 'dateTimeFormat',
        valueOf: (p) => p.dateTimeFormat,
        fromJson: (value, {String? name}) => $$codec.decodeEnum(
          (value ?? DateTimeFormatPreference.localized),
          DateTimeFormatPreference.values,
          name: name,
        ),
        toJson: (value) => $$codec.encodeEnum(value),
        defaultValue: DateTimeFormatPreference.localized,
        constraints: [EnumConstraint(values: DateTimeFormatPreference.values)],
      );

  static final $timeZone = DataField<Preferences, TimeZonePreference>(
    name: 'timeZone',
    valueOf: (p) => p.timeZone,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? TimeZonePreference.local),
      TimeZonePreference.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    defaultValue: TimeZonePreference.local,
    constraints: [EnumConstraint(values: TimeZonePreference.values)],
  );

  static final DataBean<Preferences> bean = DataBean<Preferences>(
    name: 'Preferences',
    fields: List<DataField<Preferences, dynamic>>.unmodifiable([
      $language,
      $dateTimeFormat,
      $timeZone,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Preferences, dynamic>> get $$fields => bean.fields;
  Preferences copyWith({
    String? language,
    bool nullLanguage = false,
    DateTimeFormatPreference? dateTimeFormat,
    TimeZonePreference? timeZone,
  }) {
    final $data = this as Preferences;
    return Preferences(
      language: nullLanguage ? null : (language ?? $data.language),
      dateTimeFormat: dateTimeFormat ?? $data.dateTimeFormat,
      timeZone: timeZone ?? $data.timeZone,
    );
  }

  static Preferences fromValues(Map<String, dynamic> data) {
    return Preferences(
      language: data['language'],
      dateTimeFormat:
          data['dateTimeFormat'] ?? DateTimeFormatPreference.localized,
      timeZone: data['timeZone'] ?? TimeZonePreference.local,
    );
  }

  static Preferences fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Preferences, data.runtimeType, name);
    }
    return Preferences(
      language: $language.fromJson(
        data['language'],
        name: DataCodec.childName(name, 'language'),
      ),
      dateTimeFormat: $dateTimeFormat.fromJson(
        data['dateTimeFormat'],
        name: DataCodec.childName(name, 'dateTimeFormat'),
      ),
      timeZone: $timeZone.fromJson(
        data['timeZone'],
        name: DataCodec.childName(name, 'timeZone'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Preferences;
    return {
      'language': $language.toJson($$data.language),
      'dateTimeFormat': $dateTimeFormat.toJson($$data.dateTimeFormat),
      'timeZone': $timeZone.toJson($$data.timeZone),
    }..removeWhere((k, v) => v == null);
  }
}
