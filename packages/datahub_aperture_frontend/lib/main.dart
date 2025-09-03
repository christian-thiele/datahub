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
import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
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

import 'aperture_app.dart';
import 'pages/resource_element_edit/resource_element_edit_page.dart';
import 'widgets/web_app_bar.dart';

void main() {
  initializeDateFormatting();
  findSystemLocale().then((locale) => Intl.systemLocale = locale);
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const Bootstrap(child: ApertureApp()));
}
