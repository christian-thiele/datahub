import 'package:datahub_aperture_frontend/blocs/auth_cubit/auth_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthStateAuthorized) {
            context.go(switch (GoRouter.of(context).state.uri.queryParameters) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () => context.read<AuthCubit>().loginAuthCode(),
                    child: Text(S.of(context).loginAuthcode),
                  ),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return switch (state) {
                        AuthStateError(:final message) => Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: IconText(
                            Icons.error_outline,
                            iconColor: Theme.of(context).colorScheme.error,
                            message ?? S.of(context).error,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        _ => SizedBox(),
                      };
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
