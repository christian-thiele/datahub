import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'blocs/auth_cubit.dart';
import 'generated/l10n.dart';
import 'pages/auth_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/resource_element_create/resource_element_create_page.dart';
import 'pages/resource_element_edit/resource_element_edit_page.dart';
import 'pages/resource_page/resource_page.dart';
import 'repositories.dart';
import 'repositories/auth_repository/auth_repository.dart';
import 'repositories/storage_repository/storage_repository.dart';
import 'utils/bloc_listenable.dart';
import 'utils/bootstrap.dart';
import 'utils/theme.dart';
import 'widgets/error_view.dart';
import 'widgets/side_bar_page.dart';
import 'widgets/web_app_bar.dart';

class ApertureApp extends StatefulWidget {
  const ApertureApp({super.key});

  @override
  State<ApertureApp> createState() => _ApertureAppState();
}

class _ApertureAppState extends State<ApertureApp> {
  GoRouter? router;

  GoRouter buildRouter(BuildContext context) => GoRouter(
    refreshListenable: BlocListenable(context.read<AuthCubit>()),
    routes: [
      GoRoute(
        path: '/error',
        builder: (context, state) {
          return Scaffold(
            body: Center(
              child: ErrorView(
                message: switch (state.extra) {
                  {'error': final String message} => message,
                  _ => null,
                },
                onRetryPressed: () => context.go('/'),
              ),
            ),
          );
        },
      ),
      ShellRoute(
        routes: [
          GoRoute(
            path: '/auth',
            builder: (context, state) => AuthPage(),
            redirect: (context, state) {
              if (state.uri.queryParameters['code'] case final code?) {
                context.read<AuthCubit>().receiveAuthorizationCode(code);
              }

              return null;
            },
          ),
          ShellRoute(
            redirect: (context, state) {
              if (context.read<AuthCubit>().state is AuthStateUnauthorized) {
                return '/auth';
              }

              return null;
            },
            builder: (context, state, child) => NavBarPage(child: child),
            routes: [
              GoRoute(path: '/', builder: (context, state) => DashboardPage()),
              GoRoute(
                path: '/resources/:resourceId',
                pageBuilder: (context, state) => MaterialPage(
                  key: ValueKey(state.matchedLocation),
                  child: ResourcePage(state),
                ),
                routes: [
                  GoRoute(
                    path: 'create',
                    pageBuilder: (context, state) => MaterialPage(
                      key: ValueKey(state.matchedLocation),
                      child: ResourceElementCreatePage(state),
                    ),
                  ),
                  GoRoute(
                    path: 'view/:elementId',
                    pageBuilder: (context, state) => MaterialPage(
                      key: ValueKey(state.matchedLocation),
                      child: ResourceElementEditPage(state),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
        builder: (context, state, page) =>
            Scaffold(appBar: WebAppBar(), body: page),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Repositories(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              context.read<StorageRepository>(),
              context.read<AuthRepository>(),
            ),
          ),
        ],

        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              title: Bootstrap.of(context).title,
              theme: ApertureThemeData.buildWithSeedColor(
                Color(Bootstrap.of(context).theme.color),
              ),
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              routerConfig: router ??= buildRouter(context),
            );
          },
        ),
      ),
    );
  }
}
