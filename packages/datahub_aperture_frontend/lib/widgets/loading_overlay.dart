import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool loading;

  const LoadingOverlay({super.key, required this.child, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        if (loading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: ModalBarrier(
              dismissible: false,
              color: Theme.of(context).dialogTheme.barrierColor,
            ),
          ),
        if (loading) Center(child: Card(child: LoadingView())),
      ],
    );
  }
}
