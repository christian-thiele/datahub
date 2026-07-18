import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onSubmit;

  const SearchField({super.key, this.value = '', required this.onSubmit});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            enabledBorder: (_controller.text.isNotEmpty)
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
            hintText: S.of(context).search,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () => widget.onSubmit(''),
                    icon: Icon(Icons.clear),
                  )
                : null,
          ),
          onFieldSubmitted: (text) => widget.onSubmit(text),
        );
      },
    );
  }
}
