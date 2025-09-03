import 'package:flutter/material.dart';

class ResourceTextFormField extends StatefulWidget {
  final InputDecoration decoration;
  final String? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<String>? onChanged;

  const ResourceTextFormField({
    super.key,
    required this.decoration,
    required this.value,
    this.error,
    this.isChanged = false,
    required this.onChanged,
  });

  @override
  State<ResourceTextFormField> createState() => _ResourceTextFormFieldState();
}

class _ResourceTextFormFieldState extends State<ResourceTextFormField> {
  late final TextEditingController _controller;

  String _valueToText(dynamic value) {
    return value?.toString() ?? '';
  }

  @override
  void initState() {
    _controller = TextEditingController(text: _valueToText(widget.value));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ResourceTextFormField oldWidget) {
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
      enabled: widget.onChanged != null,
      onChanged: (_) {
        if (_controller.text != _valueToText(widget.value)) {
          widget.onChanged?.call(_controller.text);
        }
      },
    );
  }
}
