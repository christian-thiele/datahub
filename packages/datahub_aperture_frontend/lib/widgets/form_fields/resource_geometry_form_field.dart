import 'package:datahub/data.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/geo_editor.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_type_restriction.dart';
import 'package:flutter/material.dart';

class ResourceGeometryFormField extends StatelessWidget {
  static const _editorHeight = 384.0;

  static const _labelInset = 8.0;

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
    final decoration = this.decoration.applyDefaults(
      InputDecorationTheme.of(context),
    );
    final hasError = decoration.errorText != null || decoration.error != null;
    final hasSubtext =
        hasError ||
        decoration.helperText != null ||
        decoration.helper != null ||
        decoration.counterText != null ||
        decoration.counter != null;

    final border =
        WidgetStateProperty.resolveAs<InputBorder?>(decoration.border, {
          if (decoration.enabled == false) WidgetState.disabled,
          if (hasError) WidgetState.error,
        });
    final borderRadius = switch (border) {
      OutlineInputBorder(:final borderRadius) => borderRadius,
      _ => BorderRadius.zero,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: _labelInset),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Only the border, fill and label are drawn behind the editor,
              // the subtext goes below the field, so that it does not take
              // space from the border.
              Positioned.fill(
                child: IgnorePointer(
                  child: InputDecorator(
                    expands: true,
                    decoration: InputDecoration(
                      label: decoration.label,
                      labelText: decoration.labelText,
                      labelStyle: decoration.labelStyle,
                      floatingLabelStyle: decoration.floatingLabelStyle,
                      floatingLabelBehavior: decoration.floatingLabelBehavior,
                      floatingLabelAlignment: decoration.floatingLabelAlignment,
                      isDense: decoration.isDense,
                      contentPadding: decoration.contentPadding,
                      filled: decoration.filled,
                      fillColor: decoration.fillColor,
                      border: decoration.border,
                      enabledBorder: decoration.enabledBorder,
                      disabledBorder: decoration.disabledBorder,
                      errorBorder: decoration.errorBorder,
                      focusedBorder: decoration.focusedBorder,
                      focusedErrorBorder: decoration.focusedErrorBorder,
                      enabled: decoration.enabled,
                      // Keeps the error state without reserving subtext space.
                      error: hasError ? const SizedBox.shrink() : null,
                    ),
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: _labelInset),
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
            ],
          ),
        ),
        if (hasSubtext)
          InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: (decoration.contentPadding?.horizontal ?? 24) / 2,
              ),
              filled: false,
              border: InputBorder.none,
              enabled: decoration.enabled,
              helper: decoration.helper,
              helperText: decoration.helperText,
              helperStyle: decoration.helperStyle,
              helperMaxLines: decoration.helperMaxLines,
              error: decoration.error,
              errorText: decoration.errorText,
              errorStyle: decoration.errorStyle,
              errorMaxLines: decoration.errorMaxLines,
              counter: decoration.counter,
              counterText: decoration.counterText,
              counterStyle: decoration.counterStyle,
            ),
            child: const SizedBox.shrink(),
          ),
      ],
    );
  }
}
