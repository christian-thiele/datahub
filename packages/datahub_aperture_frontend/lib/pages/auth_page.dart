import 'package:datahub_aperture_frontend/blocs/auth_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
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
                spacing: 16,
                children: [
                  Text(
                    S.of(context).login,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  FilledButton(
                    onPressed: () => context.go('/auth?code=12345'),
                    child: Text('Guest'),
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
