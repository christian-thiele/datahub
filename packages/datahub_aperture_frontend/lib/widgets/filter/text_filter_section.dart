import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:flutter/material.dart';

class TextFilterSection extends StatefulWidget {
  final String name;
  final void Function(ResourceFilterType, String value) onSubmit;

  const TextFilterSection({
    super.key,
    required this.name,
    required this.onSubmit,
  });

  @override
  State<TextFilterSection> createState() => _TextFilterSectionState();
}

class _TextFilterSectionState extends State<TextFilterSection> {
  late final TextEditingController controller;
  ResourceFilterType type = ResourceFilterType.contains;

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
            child: IconText(Icons.abc, widget.name),
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
                      value: ResourceFilterType.contains,
                      child: Text('≈'),
                    ),
                    DropdownMenuItem<ResourceFilterType>(
                      value: ResourceFilterType.equals,
                      child: Text('='),
                    ),
                    DropdownMenuItem<ResourceFilterType>(
                      value: ResourceFilterType.notEquals,
                      child: Text('≠'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      type = value ?? ResourceFilterType.contains;
                    });
                  },
                ),
              ),
              Expanded(
                child: TextFormField(
                  autofocus: true,
                  controller: controller,
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
    widget.onSubmit(type, controller.text);
  }
}
