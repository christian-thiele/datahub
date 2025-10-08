import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/blocs/bootstrap/bootstrap_cubit.dart';
import 'package:datahub_aperture_frontend/repositories/bootstrap_repository/api_bootstrap_repository.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Bootstrap extends StatelessWidget {
  final Widget child;

  const Bootstrap({super.key, required this.child});

  static ApertureBootstrap of(BuildContext context) =>
      (context.read<BootstrapCubit>().state as BootstrapSuccess).bootstrap;

  @override
  Widget build(BuildContext context) {
    final baseUri = switch (const String.fromEnvironment('API')) {
      String value when value.isNotEmpty => Uri.parse(value),
      _ when kIsWeb => Uri.base.replace(path: '/'),
      _ => Uri(scheme: 'http', host: 'localhost', port: 8080),
    };

    return BlocProvider(
      create: (context) =>
          BootstrapCubit(ApiBootstrapRepository(baseUri)..initialize()),
      child: BlocBuilder<BootstrapCubit, BootstrapState>(
        builder: (context, state) {
          return switch (state) {
            BootstrapSuccess() => child,
            BootstrapLoading() => _SingleWidgetApp(
              child: LoadingView(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            BootstrapError(:final message) => _SingleWidgetApp(
              child: ErrorView(
                message: message,
                onRetryPressed: () => context.read<BootstrapCubit>().update(),
              ),
            ),
          };
        },
      ),
    );
  }
}

class _SingleWidgetApp extends StatelessWidget {
  final Widget child;

  const _SingleWidgetApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      builder: (context, _) => Theme(
        data: ApertureThemeData.defaultTheme,
        child: Material(child: Scaffold(body: child)),
      ),
      color: ApertureThemeData.defaultTheme.colorScheme.primary,
    );
  }
}
