import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final Color? color;
  final String? message;

  const LoadingView({super.key, this.color, this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ApertureSpinner(color: color),
            if (message != null)
              Text(message!, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
