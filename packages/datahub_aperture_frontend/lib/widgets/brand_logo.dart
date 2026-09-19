import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
import 'package:datahub_aperture_frontend/widgets/utils/dynamic_memory_image.dart';
import 'package:flutter/material.dart';

/// The logo configured for this deployment, or the Aperture logo.
class BrandLogo extends StatelessWidget {
  final double height;

  /// Shows only the mark of the Aperture logo, and fits a configured logo
  /// into a square.
  final bool markOnly;

  const BrandLogo({super.key, this.height = 32, this.markOnly = false});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return DynamicMemoryImage(
      bytes: Bootstrap.of(context).theme.logo,
      width: markOnly ? height : height * 4,
      height: height,
      color: Theme.of(context).colorScheme.primary,
      fallback: ApertureLogo(
        size: height,
        withText: !markOnly,
        color: colors.textStrong,
        markGradient: colors.brandGradient,
      ),
    );
  }
}
