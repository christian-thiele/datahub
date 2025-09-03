import 'dart:typed_data';

import 'package:datahub/data.dart';

part 'aperture_theme.g.dart';

@Data()
class ApertureTheme extends _ApertureTheme {
  final int color;
  final Uint8List? logo;

  const ApertureTheme({
    this.color = 0xff295bf0,
    this.logo,
  });

  static DataBean<ApertureTheme> get bean => _ApertureTheme.bean;
}
