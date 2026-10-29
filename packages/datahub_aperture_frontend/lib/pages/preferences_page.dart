import 'package:datahub_aperture_frontend/blocs/preferences_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/models/preferences.dart';
import 'package:datahub_aperture_frontend/utils/date_time_formatter.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _languageNames = {'en': 'English', 'de': 'Deutsch'};

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = ApertureColors.of(context);

    return BasePage(
      child: BlocBuilder<PreferencesCubit, Preferences>(
        builder: (context, preferences) {
          final cubit = context.read<PreferencesCubit>();
          return ListView(
            children: [
              PageHeader(
                title: s.preferences,
                leading: const IconTile(Icons.settings, size: 40),
              ),
              const SizedBox(height: 4),
              Text(
                s.preferencesHint,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 20,
                        children: [
                          _Section(
                            icon: Icons.translate,
                            title: s.language,
                            children: [
                              _LanguageField(
                                language: preferences.language,
                                onChanged: cubit.setLanguage,
                              ),
                            ],
                          ),
                          const Divider(),
                          _Section(
                            icon: Icons.schedule,
                            title: s.dateAndTime,
                            children: [
                              _DateTimeFormatField(
                                preferences: preferences,
                                onChanged: cubit.setDateTimeFormat,
                              ),
                              _TimeZoneField(
                                timeZone: preferences.timeZone,
                                onChanged: cubit.setTimeZone,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(icon, size: 18, color: colors.textMuted),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        ...children,
      ],
    );
  }
}

class _LanguageField extends StatelessWidget {
  final String? language;
  final ValueChanged<String?> onChanged;

  const _LanguageField({required this.language, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final languages = [
      for (final locale in S.delegate.supportedLocales) locale.languageCode,
    ];

    return DropdownButtonFormField<String?>(
      decoration: InputDecoration(labelText: S.of(context).language),
      initialValue: languages.contains(language) ? language : null,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(S.of(context).systemLanguage),
        ),
        for (final language in languages)
          DropdownMenuItem(
            value: language,
            child: Text(_languageNames[language] ?? language),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DateTimeFormatField extends StatelessWidget {
  final Preferences preferences;
  final ValueChanged<DateTimeFormatPreference> onChanged;

  const _DateTimeFormatField({
    required this.preferences,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final now = DateTime.timestamp();

    return DropdownButtonFormField<DateTimeFormatPreference>(
      decoration: InputDecoration(labelText: s.dateTimeFormat),
      initialValue: preferences.dateTimeFormat,
      isExpanded: true,
      items: [
        for (final format in DateTimeFormatPreference.values)
          DropdownMenuItem(
            value: format,
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Text(
                    DateTimeFormatter(
                      format: format,
                      timeZone: preferences.timeZone,
                    ).formatDateTime(now),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  switch (format) {
                    DateTimeFormatPreference.localized =>
                      s.dateTimeFormatLocalized,
                    DateTimeFormatPreference.numeric => s.dateTimeFormatNumeric,
                    DateTimeFormatPreference.iso => s.dateTimeFormatIso,
                  },
                  style: TextStyle(color: ApertureColors.of(context).textMuted),
                ),
              ],
            ),
          ),
      ],
      onChanged: (format) => onChanged(format!),
    );
  }
}

class _TimeZoneField extends StatelessWidget {
  final TimeZonePreference timeZone;
  final ValueChanged<TimeZonePreference> onChanged;

  const _TimeZoneField({required this.timeZone, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(s.timeZone, style: textTheme.labelMedium),
        SegmentedButton<TimeZonePreference>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: TimeZonePreference.local,
              label: Text(
                s.timeZoneLocal(_formatOffset(DateTime.now().timeZoneOffset)),
              ),
            ),
            ButtonSegment(
              value: TimeZonePreference.utc,
              label: Text(s.timeZoneUtc),
            ),
          ],
          selected: {timeZone},
          onSelectionChanged: (selection) => onChanged(selection.single),
        ),
        Text(
          s.timeZoneHint,
          style: textTheme.bodySmall?.copyWith(
            color: ApertureColors.of(context).textMuted,
          ),
        ),
      ],
    );
  }

  /// [offset] from UTC, like `UTC+01:00`.
  static String _formatOffset(Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }
}
