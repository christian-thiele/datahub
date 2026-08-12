import 'package:datahub_aperture_frontend/blocs/geo_editor/geo_editor_cubit.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_feature.dart';
import 'package:datahub_aperture_frontend/widgets/geo_editor/model/geo_type_restriction.dart';
import 'package:flutter/material.dart';

/// The button column of the geo editor.
///
/// Only the tools the [restriction] allows are offered, and a tool that cannot
/// add anything to the current value (a second polygon in a `Polygon` field
/// for example) is disabled.
class GeoEditorControls extends StatelessWidget {
  final GeoEditorState state;
  final GeoTypeRestriction restriction;
  final bool readOnly;
  final VoidCallback onFitPressed;
  final ValueChanged<GeoEditorTool> onToolPressed;
  final VoidCallback onFinishPressed;
  final VoidCallback onUndoPressed;
  final VoidCallback onCancelPressed;
  final VoidCallback onDeletePressed;

  const GeoEditorControls({
    super.key,
    required this.state,
    required this.restriction,
    required this.readOnly,
    required this.onFitPressed,
    required this.onToolPressed,
    required this.onFinishPressed,
    required this.onUndoPressed,
    required this.onCancelPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            _GeoEditorButton(
              icon: Icons.filter_center_focus,
              tooltip: 'Zoom to geometry',
              onPressed: state.document.isNotEmpty ? onFitPressed : null,
            ),
            if (!readOnly)
              if (draft != null) ...[
                _GeoEditorButton(
                  icon: Icons.check,
                  tooltip: 'Finish shape (Enter)',
                  active: true,
                  onPressed: draft.canComplete ? onFinishPressed : null,
                ),
                _GeoEditorButton(
                  icon: Icons.undo,
                  tooltip: 'Remove last point (Backspace)',
                  onPressed: onUndoPressed,
                ),
                _GeoEditorButton(
                  icon: Icons.close,
                  tooltip: 'Cancel drawing (Esc)',
                  onPressed: onCancelPressed,
                ),
              ] else ...[
                for (final kind in restriction.kinds)
                  _GeoEditorButton(
                    icon: _iconOf(kind),
                    tooltip: _tooltipOf(kind),
                    active: state.tool == GeoEditorTool.of(kind),
                    onPressed:
                        restriction.canAdd(kind, state.document.features) ||
                            state.tool == GeoEditorTool.of(kind)
                        ? () => onToolPressed(GeoEditorTool.of(kind))
                        : null,
                  ),
                if (state.selection is GeoPolygonFeature)
                  _GeoEditorButton(
                    icon: Icons.remove_circle_outline,
                    tooltip: 'Cut a hole into the selected polygon',
                    active: state.tool == GeoEditorTool.hole,
                    onPressed: () => onToolPressed(GeoEditorTool.hole),
                  ),
                if (state.hasSelection)
                  _GeoEditorButton(
                    icon: Icons.delete_outline,
                    tooltip: state.selectedVertex != null
                        ? 'Delete selected point (Del)'
                        : 'Delete selected shape (Del)',
                    danger: true,
                    onPressed: onDeletePressed,
                  ),
              ],
          ],
        ),
      ),
    );
  }

  static IconData _iconOf(GeoFeatureKind kind) => switch (kind) {
    GeoFeatureKind.point => Icons.place_outlined,
    GeoFeatureKind.line => Icons.polyline_outlined,
    GeoFeatureKind.polygon => Icons.pentagon_outlined,
  };

  static String _tooltipOf(GeoFeatureKind kind) => switch (kind) {
    GeoFeatureKind.point => 'Draw a point',
    GeoFeatureKind.line => 'Draw a line',
    GeoFeatureKind.polygon => 'Draw a polygon',
  };
}

class _GeoEditorButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;
  final bool danger;

  const _GeoEditorButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.active = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        iconSize: const WidgetStatePropertyAll(16),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => switch (states) {
            _ when states.contains(WidgetState.disabled) =>
              colors.surface.withAlpha(120),
            _ when active => colors.primary,
            _ when danger => colors.errorContainer,
            _ => colors.primaryContainer,
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => switch (states) {
            _ when states.contains(WidgetState.disabled) =>
              colors.onSurface.withAlpha(90),
            _ when active => colors.onPrimary,
            _ when danger => colors.onErrorContainer,
            _ => colors.onPrimaryContainer,
          },
        ),
      ),
    );
  }
}

/// The status line of the geo editor, describing the value and what the
/// active tool does.
class GeoEditorHint extends StatelessWidget {
  final GeoEditorState state;
  final GeoTypeRestriction restriction;
  final bool readOnly;

  const GeoEditorHint({
    super.key,
    required this.state,
    required this.restriction,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withAlpha(220),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.document.describe(restriction),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
