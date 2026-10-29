import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/models/preferences.dart';
import 'package:datahub_aperture_frontend/utils/date_time_formatter.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/date_time_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _value = DateTime.utc(2026, 10, 29, 14, 5, 9);

/// Holds the value of the field like a form does, and records the values the
/// field emits.
class _Host extends StatefulWidget {
  final DateTime? initialValue;
  final List<DateTime> emitted;

  const _Host({required this.initialValue, required this.emitted});

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late DateTime? value = widget.initialValue;

  @override
  Widget build(BuildContext context) => DateTimeFormField(
    value: value,
    onChanged: (v) => setState(() {
      widget.emitted.add(v);
      value = v;
    }),
  );
}

/// Pumps the field with [value], shown as preferred by [formatter], and
/// returns the values it emits.
Future<List<DateTime>> _pump(
  WidgetTester tester,
  DateTimeFormatter formatter, {
  DateTime? value,
}) async {
  DateTimeFormatter.current = formatter;
  final emitted = <DateTime>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: _Host(initialValue: value, emitted: emitted),
      ),
    ),
  );
  return emitted;
}

List<String> _texts(WidgetTester tester) => [
  for (final field in tester.widgetList<TextField>(find.byType(TextField)))
    field.controller!.text,
];

/// Enters [text] into the time part of the field and leaves it.
Future<void> _enterTime(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).last, text);
  FocusManager.instance.primaryFocus!.unfocus();
  await tester.pump();
}

void main() {
  setUpAll(() => initializeDateFormatting());
  tearDown(() => DateTimeFormatter.current = const DateTimeFormatter());

  const utc = DateTimeFormatter(
    format: DateTimeFormatPreference.iso,
    timeZone: TimeZonePreference.utc,
  );
  const local = DateTimeFormatter(
    format: DateTimeFormatPreference.iso,
    timeZone: TimeZonePreference.local,
  );

  testWidgets('shows its value in the preferred format', (tester) async {
    await _pump(tester, utc, value: _value.toLocal());

    expect(_texts(tester), ['2026-10-29', '14:05:09']);
  });

  testWidgets('takes a time in UTC if preferred', (tester) async {
    final emitted = await _pump(tester, utc, value: _value.toLocal());

    await _enterTime(tester, '08:30');

    expect(emitted, [DateTime.utc(2026, 10, 29, 8, 30)]);
    expect(emitted.single.isUtc, isTrue);
    expect(_texts(tester), ['2026-10-29', '08:30:00']);
  });

  testWidgets('takes a time in local time if preferred', (tester) async {
    final emitted = await _pump(tester, local, value: _value);
    final localValue = _value.toLocal();

    await _enterTime(tester, '08:30');

    expect(emitted, [
      DateTime(localValue.year, localValue.month, localValue.day, 8, 30),
    ]);
    expect(emitted.single.isUtc, isFalse);
  });
}
