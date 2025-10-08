import 'package:datahub/datahub.dart';

import 'aperture_theme.dart';

part 'aperture_bootstrap.g.dart';

@Data()
class ApertureBootstrap extends $ApertureBootstrap {
  final String title;

  final ApertureTheme theme;

  final String baseUrl;

  final String oidcIssuer;
  final List<String> oidcScopes;
  final String? oidcClientId;
  final String? oidcClientSecret;

  const ApertureBootstrap({
    required this.title,
    required this.theme,
    required this.baseUrl,
    required this.oidcIssuer,
    required this.oidcScopes,
    required this.oidcClientId,
    required this.oidcClientSecret,
  });
}
