import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BoolFilterSection extends StatefulWidget {
  final String name;
  final void Function(ResourceFilterType, bool? value) onSubmit;

  const BoolFilterSection({
    super.key,
    required this.name,
    required this.onSubmit,
  });

  @override
  State<BoolFilterSection> createState() => _BoolFilterSectionState();
}

class _BoolFilterSectionState extends State<BoolFilterSection> {
  bool value = false;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
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
            child: IconText(Icons.toggle_on, widget.name, iconSize: 16),
          ),
          GestureDetector(
            onTap: () {
              focusNode.requestFocus();
              setState(() {
                value = !value;
              });
            },
            child: Focus(
              autofocus: true,
              focusNode: focusNode,
              onKeyEvent: (focus, event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.enter) {
                    widget.onSubmit(ResourceFilterType.equals, value);
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.space) {
                    setState(() {
                      value = !value;
                    });
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: ListenableBuilder(
                listenable: focusNode,
                builder: (context, _) => InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(6),
                  ),
                  isFocused: focusNode.hasFocus,
                  child: Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: IgnorePointer(
                      child: Checkbox(
                        tristate: false,
                        value: value,
                        onChanged: (v) => setState(() {
                          value = v ?? false;
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
