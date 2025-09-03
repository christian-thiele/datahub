import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/blocs/bootstrap/bootstrap_cubit.dart';
import 'package:datahub_aperture_frontend/repositories/bootstrap_repository/api_bootstrap_repository.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Bootstrap extends StatelessWidget {
  final Widget child;

  const Bootstrap({super.key, required this.child});

  static ApertureBootstrap of(BuildContext context) =>
      (context.read<BootstrapCubit>().state as BootstrapSuccess).bootstrap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BootstrapCubit(ApiBootstrapRepository()..initialize()),
      child: BlocBuilder<BootstrapCubit, BootstrapState>(
        builder: (context, state) {
          return switch (state) {
            BootstrapSuccess() => child,
            BootstrapLoading() => MaterialApp(
              theme: ApertureThemeData.defaultTheme,
              home: Scaffold(
                body: LoadingView(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            BootstrapError(:final message) => MaterialApp(
              theme: ApertureThemeData.defaultTheme,
              home: Scaffold(
                body: ErrorView(
                  message: message,
                  onRetryPressed: () => context.read<BootstrapCubit>().update(),
                ),
              ),
            ),
          };
        },
      ),
    );
  }
}
