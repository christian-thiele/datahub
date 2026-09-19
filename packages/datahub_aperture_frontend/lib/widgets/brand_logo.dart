import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
import 'package:datahub_aperture_frontend/widgets/utils/dynamic_memory_image.dart';
import 'package:flutter/material.dart';

/// The logo configured for this deployment, or the Aperture logo.
class BrandLogo extends StatelessWidget {
  final double height;
  final bool compact;

  const BrandLogo({super.key, this.height = 32, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return DynamicMemoryImage(
      bytes: Bootstrap.of(context).theme.logo,
      width: compact ? height : height * 4,
      height: height,
      color: Theme.of(context).colorScheme.primary,
      fallback: ApertureLogo(
        size: height,
        withText: !compact,
        color: colors.textStrong,
        markGradient: colors.brandGradient,
      ),
    );
  }
}
