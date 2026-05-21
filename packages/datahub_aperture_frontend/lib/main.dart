import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

import 'aperture_app.dart';

void main() {
  usePathUrlStrategy();
  initializeDateFormatting();
  findSystemLocale().then((locale) => Intl.systemLocale = locale);
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const Bootstrap(child: ApertureApp()));
}
