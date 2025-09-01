import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleFilterSection extends StatefulWidget {
  final String name;
  final void Function(ResourceFilterType, double value) onSubmit;

  const DoubleFilterSection({
    super.key,
    required this.name,
    required this.onSubmit,
  });

  @override
  State<DoubleFilterSection> createState() => _DoubleFilterSectionState();
}

class _DoubleFilterSectionState extends State<DoubleFilterSection> {
  late final TextEditingController controller;
  ResourceFilterType type = ResourceFilterType.equals;
  String? error;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.labelLarge,
            child: IconText(Icons.numbers, widget.name, iconSize: 16),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            spacing: 8,
            children: [
              SizedBox(
                width: 80,
                child: DropdownButtonFormField<ResourceFilterType>(
                  initialValue: type,
                  isExpanded: false,
                  items: [
                    DropdownMenuItem<ResourceFilterType>(
                      value: ResourceFilterType.equals,
                      child: Text('='),
                    ),
                    DropdownMenuItem<ResourceFilterType>(
                      value: ResourceFilterType.notEquals,
                      child: Text('≠'),
                    ),
                    DropdownMenuItem<ResourceFilterType>(
                      value: ResourceFilterType.lessThan,
                      child: Text('<'),
                    ),
                    DropdownMenuItem<ResourceFilterType>(
                      value: ResourceFilterType.greaterThan,
                      child: Text('>'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      type = value ?? ResourceFilterType.equals;
                    });
                  },
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(errorText: error),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (value) {
                    if (double.tryParse(value) != null) {
                      setState(() {
                        error = null;
                      });
                    }
                  },
                  onFieldSubmitted: (_) => _submit(),
                  onEditingComplete: () => _submit(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    final number = double.tryParse(controller.text);
    if (number != null) {
      widget.onSubmit(type, number);
    } else {
      setState(() {
        error = 'Invalid number';
      });
    }
  }
}
