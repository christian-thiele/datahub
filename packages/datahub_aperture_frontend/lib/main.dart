import 'package:datahub_aperture_frontend/blocs/preferences_cubit.dart';
import 'package:datahub_aperture_frontend/repositories.dart';
import 'package:datahub_aperture_frontend/services/preferences_service.dart';
import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

import 'aperture_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  initializeDateFormatting();
  findSystemLocale().then((locale) => Intl.systemLocale = locale);
  GoogleFonts.config.allowRuntimeFetching = false;

  final preferencesService = PreferencesService();
  final preferences = await preferencesService.load();

  runApp(
    BlocProvider(
      create: (context) => PreferencesCubit(preferencesService, preferences),
      child: Bootstrap(child: Repositories(child: ApertureApp())),
    ),
  );
}
