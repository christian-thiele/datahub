import 'dart:typed_data';

import 'package:datahub/data.dart';

part 'aperture_theme.g.dart';

@Data()
class ApertureTheme extends $ApertureTheme {
  final int color;
  final Uint8List? logo;

  const ApertureTheme({
    this.color = 0xff295bf0,
    this.logo,
  });
}
