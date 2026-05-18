import 'dart:typed_data';

import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ResourceFileFormField extends StatelessWidget {
  final InputDecoration decoration;
  final Uint8List? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<Uint8List?>? onChanged;

  const ResourceFileFormField({
    super.key,
    required this.decoration,
    this.value,
    this.error,
    required this.isChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: decoration,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(Icons.file_present_outlined),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (value case final value?) ...[
                        Text(
                          S.of(context).fileSelected,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          formatFileSize(value.length),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                      if (value == null)
                        Text(
                          S.of(context).emptyFile,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                    ],
                  ),
                ),
                if (onChanged != null && value != null)
                  IconButton(
                    onPressed: () => onChanged?.call(null),
                    icon: Icon(Icons.delete_outline),
                  ),

                if (onChanged != null)
                  IconButton(
                    onPressed: () async {
                      final result = await FilePicker.pickFiles(withData: true);

                      if (result case final result?) {
                        if (result.files.first case PlatformFile(
                          :final bytes?,
                        )) {
                          //onChanged?.call(FileValue(name: name, data: bytes));
                          onChanged?.call(bytes);
                        }
                      }
                    },
                    icon: Icon(Icons.upload),
                  ),
              ],
            ),

            if (value case final value?)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 256, maxHeight: 256),
                child: Image.memory(
                  value,
                  fit: BoxFit.contain,
                  errorBuilder: (context, _, _) {
                    return SizedBox.shrink();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
