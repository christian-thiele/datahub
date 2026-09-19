import 'package:datahub_aperture_frontend/blocs/auth_cubit/auth_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/brand_logo.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: colors.canvas,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.9, -1.1),
            radius: 1.4,
            colors: [scheme.primary.withAlpha(28), scheme.primary.withAlpha(0)],
          ),
        ),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthStateAuthorized) {
              context.go(switch (GoRouter.of(
                context,
              ).state.uri.queryParameters) {
                {'redirect': final redirect} => redirect,
                _ => '/',
              });
            }
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state case AuthStateLoading() || AuthStateAuthorized()) {
                return LoadingView();
              }
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 12,
                      shadowColor: scheme.shadow,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: BrandLogo(height: 40),
                            ),
                            SizedBox(height: 32),
                            Text(
                              S.of(context).signInTitle,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 6),
                            Text(
                              S.of(context).signInSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.textMuted),
                            ),
                            SizedBox(height: 28),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                minimumSize: Size.fromHeight(44),
                              ),
                              onPressed: () =>
                                  context.read<AuthCubit>().loginAuthCode(),
                              icon: Icon(Icons.login),
                              label: Text(S.of(context).loginAuthcode),
                            ),
                            if (state case AuthStateError(:final message))
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.dangerSubtle,
                                  borderRadius: BorderRadius.circular(
                                    ApertureThemeData.radius,
                                  ),
                                ),
                                child: IconText(
                                  Icons.error_outline,
                                  iconColor: colors.danger,
                                  message ?? S.of(context).error,
                                  style: TextStyle(color: colors.danger),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
