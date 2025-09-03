import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResourceDoubleFormField extends StatefulWidget {
  final InputDecoration decoration;
  final double? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<double>? onChanged;

  const ResourceDoubleFormField({
    super.key,
    required this.decoration,
    required this.value,
    this.error,
    this.isChanged = false,
    required this.onChanged,
  });

  @override
  State<ResourceDoubleFormField> createState() =>
      _ResourceDoubleFormFieldState();
}

class _ResourceDoubleFormFieldState extends State<ResourceDoubleFormField> {
  late final TextEditingController _controller;

  String _valueToText(double? value) {
    return (value ?? 0).toString();
  }

  @override
  void initState() {
    _controller = TextEditingController(text: _valueToText(widget.value));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ResourceDoubleFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != _valueToText(widget.value)) {
      _controller.text = _valueToText(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: widget.decoration,
      readOnly: widget.onChanged == null,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: (_) {
        if (_controller.text != _valueToText(widget.value)) {
          if (double.tryParse(_controller.text) case final value?) {
            widget.onChanged?.call(value);
          }
        }
      },
    );
  }
}
