import 'package:datahub_aperture_frontend/blocs/auth_cubit/auth_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatelessWidget {
  final String? state;
  final String? code;

  const AuthPage({super.key, this.state, this.code});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthStateAuthorized) {
            context.go('/');
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
