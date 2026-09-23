import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/lookup_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResourceIntFormField extends StatefulWidget {
  final InputDecoration decoration;
  final ResourceFieldLookup? lookup;
  final int? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<int?>? onChanged;

  const ResourceIntFormField({
    super.key,
    required this.decoration,
    required this.value,
    this.error,
    this.isChanged = false,
    required this.onChanged,
    this.lookup,
  });

  @override
  State<ResourceIntFormField> createState() => _ResourceIntFormFieldState();
}

class _ResourceIntFormFieldState extends State<ResourceIntFormField> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;

  late int? _value = widget.value;

  String _valueToText(int? value) {
    return value?.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController(text: _valueToText(_value));
    _controller.addListener(() {
      final text = _controller.text;
      final value = int.tryParse(text);
      if ((value != null || text.isEmpty) && value != _value) {
        _value = value;
        widget.onChanged?.call(value);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ResourceIntFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _value) {
      _value = widget.value;
      _controller.text = _valueToText(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget field(InputDecoration decoration, [TextStyle? style]) =>
        TextFormField(
          decoration: decoration,
          style: style,
          focusNode: _focusNode,
          controller: _controller,
          inputFormatters: widget.lookup == null
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
              : null,
          readOnly: widget.onChanged == null,
        );

    if (widget.lookup case final lookup?) {
      return LookupMenu(
        controller: _controller,
        lookup: lookup,
        focusNode: _focusNode,
        value: widget.value,
        decoration: widget.decoration,
        readOnly: widget.onChanged == null,
        fieldBuilder: field,
      );
    } else {
      return field(widget.decoration);
    }
  }
}
