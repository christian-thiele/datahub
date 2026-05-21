import 'package:datahub_aperture/api.dart';
import 'package:flutter/material.dart';

import 'lookup_menu.dart';

class ResourceTextFormField extends StatefulWidget {
  final InputDecoration decoration;
  final ResourceFieldLookup? lookup;
  final String? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<String>? onChanged;

  const ResourceTextFormField({
    super.key,
    required this.decoration,
    required this.lookup,
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
  late final FocusNode _focusNode;

  String _valueToText(dynamic value) {
    return value?.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _valueToText(widget.value));
    _controller.addListener(() {
      if (_controller.text != _valueToText(widget.value)) {
        widget.onChanged?.call(_controller.text);
      }
    });
    _focusNode = FocusNode();
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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      focusNode: _focusNode,
      controller: _controller,
      decoration: widget.decoration,
      readOnly: widget.onChanged == null,
      enabled: widget.onChanged != null,
    );

    if (widget.lookup case final lookup?) {
      return LookupMenu(
        controller: _controller,
        lookup: lookup,
        focusNode: _focusNode,
        child: field,
      );
    } else {
      return field;
    }
  }
}
