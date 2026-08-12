import 'package:datahub/data.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/geo_editor.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_type_restriction.dart';
import 'package:flutter/material.dart';

class ResourceGeometryFormField extends StatelessWidget {
  static const _editorHeight = 384.0;

  final InputDecoration decoration;
  final Geometry? value;
  final String? error;
  final bool isChanged;
  final ValueChanged<Geometry?>? onChanged;

  /// The geometry types the field accepts.
  final GeoTypeRestriction restriction;

  const ResourceGeometryFormField({
    super.key,
    required this.decoration,
    this.value,
    this.error,
    required this.isChanged,
    this.onChanged,
    this.restriction = const GeoTypeRestriction.any(),
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = switch (InputDecorationTheme.of(context).border) {
      OutlineInputBorder(:final borderRadius) => borderRadius,
      _ => BorderRadius.zero,
    };

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: SizedBox(
              height: _editorHeight,
              child: GeoEditor(
                value: value,
                restriction: restriction,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: InputDecorator(
              decoration: decoration,
              child: const SizedBox(height: _editorHeight + 8),
            ),
          ),
        ),
      ],
    );
  }
}
