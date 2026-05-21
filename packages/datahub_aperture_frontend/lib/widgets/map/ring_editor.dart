import 'package:datahub_aperture_frontend/widgets/map/utils.dart';
import 'package:datahub_aperture_frontend/widgets/utils/immutable_list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'handle.dart';

class RingEditor extends StatelessWidget {
  final List<LatLng> value;
  final ValueChanged<List<LatLng>> onChanged;

  const RingEditor({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final (vIdx, pos) in value.indexed)
          _DraggableHandle.positioned(
            context,
            position: pos,
            onChanged: (pos) => onChanged(value.copyWithReplaced(vIdx, pos)),
            onRemoved: () => onChanged(value.copyWithRemoved(vIdx)),
          ),
      ],
    );
  }
}

class _DraggableHandle extends StatelessWidget {
  final ValueChanged<Offset> onChanged;
  final VoidCallback onRemoved;

  const _DraggableHandle({required this.onChanged, required this.onRemoved});

  static Widget positioned(
    BuildContext context, {
    required LatLng position,
    required ValueChanged<LatLng> onChanged,
    required VoidCallback onRemoved,
  }) {
    final camera = MapCamera.of(context);
    final offset = camera.worldToScreen(position);
    return Positioned(
      left: offset.dx - 4,
      top: offset.dy - 4,
      child: _DraggableHandle(
        onChanged: (globalPosition) {
          final renderBox = context.findRenderObject() as RenderBox;
          onChanged(
            camera.screenToWorld(renderBox.globalToLocal(globalPosition)),
          );
        },
        onRemoved: onRemoved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, details) {
        if (details is KeyDownEvent) {
          switch (details.logicalKey) {
            case LogicalKeyboardKey.delete || LogicalKeyboardKey.backspace:
              onRemoved();
              return KeyEventResult.handled;
            default:
              break;
          }
        }

        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTapDown: (_) => Focus.of(context).requestFocus(),
            child: Draggable(
              onDragUpdate: (details) => onChanged(details.globalPosition),
              feedback: MouseRegion(
                hitTestBehavior: HitTestBehavior.opaque,
                cursor: SystemMouseCursors.grabbing,
                child: Handle(focused: true),
              ),
              childWhenDragging: SizedBox(),
              feedbackOffset: Offset(-4, -4),
              ignoringFeedbackPointer: false,
              child: MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                cursor: SystemMouseCursors.grab,
                child: Handle(focused: Focus.of(context).hasFocus),
              ),
            ),
          );
        },
      ),
    );
  }
}
