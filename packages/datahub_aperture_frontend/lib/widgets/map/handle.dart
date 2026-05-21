import 'package:datahub_aperture_frontend/widgets/map/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Handle extends StatelessWidget {
  final bool focused;

  const Handle({super.key, this.focused = false});

  static Widget positioned(BuildContext context, {required LatLng position}) {
    final camera = MapCamera.of(context);
    final offset = camera.worldToScreen(position);
    return Positioned(left: offset.dx - 4, top: offset.dy - 4, child: Handle());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: focused
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onPrimary.withAlpha(150),
        border: Border.all(
          strokeAlign: BorderSide.strokeAlignOutside,
          color: Theme.of(
            context,
          ).colorScheme.primary.withAlpha(focused ? 150 : 100),
          width: focused ? 3 : 2,
        ),
      ),
      duration: const Duration(milliseconds: 100),
    );
  }
}
