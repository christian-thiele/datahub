import 'package:datahub_aperture_frontend/blocs/auth_cubit.dart';
import 'package:datahub_aperture_frontend/blocs/configuration_cubit.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
import 'package:datahub_aperture_frontend/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NavBarPage extends StatelessWidget {
  final Widget child;

  const NavBarPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConfigurationCubit(
        context.read<ResourcesRepository>(),
        (context.read<AuthCubit>().state as AuthStateAuthorized).auth,
      ),
      child: BlocConsumer<ConfigurationCubit, ConfigurationState>(
        listener: (context, state) {
          if (state case ConfigurationError(:final message)) {
            context.go('/error', extra: {'error': message});
          }
        },
        builder: (context, state) {
          return switch (state) {
            ConfigurationValue(:final resources) => Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SideBar(
                  entries: [
                    SideBarEntry(
                      icon: Icon(Icons.dashboard),
                      label: 'Dashboard',
                      path: '/',
                    ),
                    for (final resource in resources)
                      SideBarEntry(
                        icon: Icon(getIcon(resource.icon)),
                        label: resource.namePlural ?? resource.name,
                        path: '/resources/${Uri.encodeComponent(resource.id)}',
                      ),
                  ],
                  refreshPressed: () =>
                      context.read<ConfigurationCubit>().update(),
                ),

                Expanded(child: child),
              ],
            ),
            _ => Center(child: ApertureSpinner()),
          };
        },
      ),
    );
  }
}
