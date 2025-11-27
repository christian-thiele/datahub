import 'package:datahub_aperture_frontend/blocs/auth_cubit/auth_cubit.dart';
import 'package:datahub_aperture_frontend/blocs/login_form/login_form_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatelessWidget {
  final void Function(String, String) onSubmit;

  const LoginForm({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormCubit(),
      child: BlocBuilder<LoginFormCubit, LoginFormState>(
        builder: (context, state) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 256),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.of(context).login,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: S.of(context).username,
                  ),
                  onChanged: (value) =>
                      context.read<LoginFormCubit>().setUsername(value),
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: S.of(context).password,
                  ),
                  obscureText: true,
                  onChanged: (value) =>
                      context.read<LoginFormCubit>().setPassword(value),
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
                SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isValid
                      ? () => onSubmit(state.username, state.password)
                      : null,
                  child: Text(S.of(context).login),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
