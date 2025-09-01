import 'package:datahub_aperture_frontend/widgets/map/editor_layer.dart';
import 'package:datahub_aperture_frontend/widgets/map/ring_editor.dart';
import 'package:datahub_aperture_frontend/widgets/utils/immutable_list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class PolygonEditor extends StatelessWidget {
  final EditorPolygon value;
  final ValueChanged<EditorPolygon?> onChanged;

  const PolygonEditor({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MobileLayerTransformer(
      child: Stack(
        children: [
          RingEditor(
            value: value.bounds,
            onChanged: (v) {
              if (v.length > 2) {
                onChanged(value.copyWith(bounds: v));
              } else {
                onChanged(null);
              }
            },
          ),

          for (final (hIdx, hole) in value.holes.indexed)
            RingEditor(
              value: hole,
              onChanged: (v) {
                if (v.length > 2) {
                  onChanged(
                    value.copyWith(
                      holes: value.holes.copyWithReplaced(hIdx, v),
                    ),
                  );
                } else {
                  onChanged(
                    value.copyWith(holes: value.holes.copyWithRemoved(hIdx)),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
