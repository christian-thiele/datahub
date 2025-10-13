import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/utils/dynamic_memory_image.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DynamicMemoryImage(
              bytes: Bootstrap.of(context).theme.logo,
              width: 128,
              height: 48,
              color: Theme.of(context).colorScheme.primary,
              fallback: ApertureLogo(),
            ),
          ],
        ),
      ),
    );
  }
}
