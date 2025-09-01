import 'package:datahub_aperture_frontend/blocs/auth_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/pages/auth_page.dart';
import 'package:datahub_aperture_frontend/pages/dashboard_page.dart';
import 'package:datahub_aperture_frontend/pages/resource_element_create/resource_element_create_page.dart';
import 'package:datahub_aperture_frontend/pages/resource_page/resource_page.dart';
import 'package:datahub_aperture_frontend/repositories/auth_repository/auth_repository.dart';
import 'package:datahub_aperture_frontend/repositories/auth_repository/mock_auth_repository.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/api_resources_repository.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/repositories/storage_repository/shared_prefs_storage_repository.dart';
import 'package:datahub_aperture_frontend/repositories/storage_repository/storage_repository.dart';
import 'package:datahub_aperture_frontend/utils/bloc_listenable.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/side_bar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

import 'pages/resource_element_edit/resource_element_edit_page.dart';
import 'widgets/web_nav_bar.dart';

void main() {
  initializeDateFormatting();
  findSystemLocale().then((locale) => Intl.systemLocale = locale);
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageRepository>(
          create: (context) => SharedPrefsStorageRepository()..initialize(),
          dispose: (repository) => repository.close(),
          lazy: false,
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => MockAuthRepository()..initialize(),
          lazy: false,
          dispose: (repository) => repository.close(),
        ),
        RepositoryProvider<ResourcesRepository>(
          create: (context) => ApiResourcesRepository()..initialize(),
          lazy: false,
          dispose: (repository) => repository.close(),
        ),
      ],
      child: const ApertureApp(),
    ),
  );
}

class ApertureApp extends StatefulWidget {
  static final colors = ColorScheme.fromSeed(
    seedColor: Color(0xff295bf0),
    shadow: Color(0xA0000000),
    onSurface: Color(0xff404654),
  );

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
    return MultiBlocProvider(
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
            title: 'DataHub Aperture',
            theme: ThemeData(
              colorScheme: ApertureApp.colors,
              visualDensity: VisualDensity.compact,
              textTheme: GoogleFonts.poppinsTextTheme(
                TextTheme(
                  labelMedium: TextStyle(color: Colors.black54),
                  labelSmall: TextStyle(color: Colors.black54),
                  bodySmall: TextStyle(fontSize: 8),
                  bodyMedium: TextStyle(fontSize: 12),
                  bodyLarge: TextStyle(fontSize: 14),
                ),
              ),
              appBarTheme: AppBarTheme(leadingWidth: 128),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              cardTheme: CardThemeData(
                margin: EdgeInsetsGeometry.zero,
                color: ApertureApp.colors.surfaceBright,
              ),
              dialogTheme: DialogThemeData(barrierColor: Colors.white54),
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
                  TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
                  TargetPlatform.windows: ZoomPageTransitionsBuilder(),
                  TargetPlatform.linux: ZoomPageTransitionsBuilder(),
                },
              ),
              iconTheme: IconThemeData(size: 18),
              iconButtonTheme: IconButtonThemeData(
                style: ButtonStyle(
                  iconSize: WidgetStatePropertyAll(18),
                  visualDensity: VisualDensity.compact,
                ),
              ),
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
    );
  }
}
