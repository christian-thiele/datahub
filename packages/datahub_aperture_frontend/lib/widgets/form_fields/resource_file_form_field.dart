import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/models/file_value.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ResourceFileFormField extends StatelessWidget {
  final ResourceField field;
  final FileValue? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<FileValue?>? onChanged;

  const ResourceFileFormField({
    super.key,
    required this.field,
    this.value,
    this.error,
    required this.isChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        errorText: error,
        labelText: isChanged ? '${field.name} *' : field.name,
        labelStyle: TextStyle(fontWeight: isChanged ? FontWeight.bold : null),
      ),
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
                          value.name,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          formatFileSize(value.data.length),
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
                      final result = await FilePicker.platform.pickFiles(
                        withData: true,
                      );

                      if (result case final result?) {
                        if (result.files.first case PlatformFile(
                          :final name,
                          :final bytes?,
                        )) {
                          onChanged?.call(FileValue(name: name, data: bytes));
                        }
                      }
                    },
                    icon: Icon(Icons.upload),
                  ),
              ],
            ),

            if (value case final value?
                when value.name.endsWith('.png') ||
                    value.name.endsWith('.jpg') ||
                    value.name.endsWith('.jpeg'))
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 256, maxHeight: 256),
                child: Image.memory(value.data, fit: BoxFit.contain),
              ),
          ],
        ),
      ),
    );
  }
}
