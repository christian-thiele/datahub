import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/animation/error_wiggle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFormField extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final InputDecoration decoration;

  const DateTimeFormField({
    super.key,
    required this.value,
    required this.onChanged,
    this.decoration = const InputDecoration(),
  });

  @override
  State<DateTimeFormField> createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends State<DateTimeFormField>
    with TickerProviderStateMixin {
  late final FocusNode _dateFocus;
  late final FocusNode _timeFocus;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  final DateFormat _dateDisplayFormat = DateFormat.yMMMMd();
  final DateFormat _timeDisplayFormat = DateFormat.Hm();
  late final AnimationController _dateErrorController;
  late final AnimationController _timeErrorController;

  final _dateParseFormats = [
    DateFormat('yyyy-MM-dd'),
    DateFormat('yyyy/MM/dd'),
    DateFormat('yyyy/dd/MM'),
    DateFormat('dd.MM.yyyy'),
    DateFormat('dd.MMMM.yyyy'),
    DateFormat('dd.MM'),
    DateFormat('dd.MMMM'),
  ];

  @override
  void initState() {
    super.initState();
    _dateFocus = FocusNode();
    _timeFocus = FocusNode();

    _dateController = TextEditingController(
      text: widget.value != null
          ? _dateDisplayFormat.format(widget.value!)
          : null,
    );
    _timeController = TextEditingController(
      text: widget.value != null
          ? _timeDisplayFormat.format(widget.value!)
          : null,
    );

    _dateFocus.addListener(() {
      if (!_dateFocus.hasFocus && widget.onChanged != null) {
        _processDate(_dateController.text);
      }
    });

    _timeFocus.addListener(() {
      if (!_timeFocus.hasFocus && widget.onChanged != null) {
        _processTime(_timeController.text);
      }
    });

    _dateErrorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _timeErrorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _dateFocus.dispose();
    _timeFocus.dispose();
    _dateErrorController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DateTimeFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value != null) {
        _dateController.text = _dateDisplayFormat.format(widget.value!);
        _timeController.text = _timeDisplayFormat.format(widget.value!);
      } else {
        _dateController.text = '';
        _timeController.text = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: widget.decoration,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        spacing: 16,
        children: [
          Expanded(
            flex: 2,
            child: ErrorWiggle(
              controller: _dateErrorController,
              child: TextField(
                decoration: InputDecoration.collapsed(
                  hintText: S.of(context).date,
                ),
                controller: _dateController,
                focusNode: _dateFocus,
                enabled: widget.onChanged != null,
                onTap: () {
                  _dateController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _dateController.text.length,
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            width: 0,
            height: 24,
          ),
          Expanded(
            child: ErrorWiggle(
              controller: _timeErrorController,
              child: Row(
                children: [
                  const Icon(Icons.access_time),
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration.collapsed(
                        hintText: S.of(context).time,
                      ),
                      controller: _timeController,
                      focusNode: _timeFocus,
                      enabled: widget.onChanged != null,
                      onTap: () {
                        _timeController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _timeController.text.length,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processDate(String text) {
    DateTime? result = _dateDisplayFormat.tryParseLoose(text);

    for (final format in _dateParseFormats) {
      if (result != null) {
        break;
      }

      result = format.tryParseLoose(text);
    }

    if (result case final date?) {
      final value = (widget.value ?? DateTime.now()).copyWith(
        year: date.year,
        month: date.month,
        day: date.day,
      );
      _dateController.text = _dateDisplayFormat.format(value);
      widget.onChanged?.call(value);
    } else {
      _dateErrorController.forward(from: 0);
      _dateController.text = widget.value != null
          ? _dateDisplayFormat.format(widget.value!)
          : '';
    }
  }

  void _processTime(String text) {
    DateTime? result = _timeDisplayFormat.tryParseLoose(text);

    if (result == null) {
      if (int.tryParse(text) case final hour? when hour >= 0 && hour < 24) {
        result = DateTime(0, 0, 0, hour);
      }
    }

    if (result case final date?) {
      final value = (widget.value ?? DateTime.now()).copyWith(
        hour: date.hour,
        minute: date.minute,
        second: date.second,
        millisecond: date.millisecond,
        microsecond: date.microsecond,
      );
      _timeController.text = _timeDisplayFormat.format(value);
      widget.onChanged?.call(value);
    } else {
      _timeErrorController.forward(from: 0);
      _timeController.text = widget.value != null
          ? _timeDisplayFormat.format(widget.value!)
          : '';
    }
  }
}
