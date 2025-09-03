import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResourceIntFormField extends StatefulWidget {
  final InputDecoration decoration;
  final int? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<int>? onChanged;

  const ResourceIntFormField({
    super.key,
    required this.decoration,
    required this.value,
    this.error,
    this.isChanged = false,
    required this.onChanged,
  });

  @override
  State<ResourceIntFormField> createState() => _ResourceIntFormFieldState();
}

class _ResourceIntFormFieldState extends State<ResourceIntFormField> {
  late final TextEditingController _controller;

  String _valueToText(int? value) {
    return (value ?? 0).toString();
  }

  @override
  void initState() {
    _controller = TextEditingController(text: _valueToText(widget.value));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ResourceIntFormField oldWidget) {
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
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      readOnly: widget.onChanged == null,
      onChanged: (_) {
        if (_controller.text != _valueToText(widget.value)) {
          if (int.tryParse(_controller.text) case final value?) {
            widget.onChanged?.call(value);
          }
        }
      },
    );
  }
}
