import 'package:datahub/datahub.dart';

import 'aperture_theme.dart';

part 'aperture_bootstrap.g.dart';

@Data()
class ApertureBootstrap extends _ApertureBootstrap {
  final String title;

  final ApertureTheme theme;

  // TODO auth and stuff

  const ApertureBootstrap({
    required this.title,
    required this.theme,
  });

  static DataBean<ApertureBootstrap> get bean => _ApertureBootstrap.bean;
}
