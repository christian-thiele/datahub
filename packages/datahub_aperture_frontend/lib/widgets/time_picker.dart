import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  const TimePicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        _NumberDial(
          onChanged: (v) =>
              onChanged(TimeOfDay(hour: v, minute: value.minute)),
          value: value.hour,
          min: 0,
          max: 23,
        ),
        _NumberDial(
          onChanged: (v) => onChanged(TimeOfDay(hour: value.hour, minute: v)),
          value: value.minute,
          min: 0,
          max: 59,
        ),
      ],
    );
  }
}

class _NumberDial extends StatelessWidget {
  final ValueChanged<int> onChanged;
  final int value;
  final int min;
  final int max;

  const _NumberDial({
    required this.onChanged,
    required this.value,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: Icon(Icons.arrow_drop_up),
        ),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: Icon(Icons.arrow_drop_down),
        ),
      ],
    );
  }
}
