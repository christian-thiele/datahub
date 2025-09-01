import 'package:datahub_aperture_frontend/blocs/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WebAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const height = 84.0;
  final String? title;

  const WebAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.shadow, blurRadius: 2),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: height,
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 32),
                  SvgPicture.asset('assets/rd.svg', width: 128),
                  SizedBox(width: 64),
                  if (title != null)
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  Spacer(),
                  if (state is AuthStateAuthorized)
                    IconButton(
                      onPressed: () => context.read<AuthCubit>().logout(),
                      icon: Icon(Icons.logout),
                    ),
                  SizedBox(width: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, height);
}
