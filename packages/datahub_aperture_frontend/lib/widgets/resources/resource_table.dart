import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:flutter/material.dart';

class ResourceTable extends StatelessWidget {
  final ResourceDescription resource;
  final List<ResourceData> entries;

  const ResourceTable({
    super.key,
    required this.resource,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      children: [
        TableRow(
          children: [
            for (final field in resource.fields)
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    field.name,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (final entry in entries)
          TableRow(
            children: [
              for (final field in resource.fields)
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      entry.fieldData[field.id].toString(),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
