import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/auth_callback_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

ApertureBootstrap _bootstrap({Uint8List? logo}) => ApertureBootstrap(
  title: 'Admin <Panel>',
  theme: ApertureTheme(logo: logo),
  environment: Environment.prod,
  oidcIssuer: 'http://localhost',
  oidcScopes: [],
  oidcClientId: null,
  oidcClientSecret: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => S.load(const Locale('en')));

  test('renders success page with Aperture logo', () async {
    final page = await renderAuthCallbackPage(_bootstrap(), success: true);

    expect(page, isNot(contains('{{')));
    expect(page, contains('<body class="success">'));
    expect(page, contains('Signed in successfully'));
    expect(page, contains('return to Admin &lt;Panel&gt;.'));
    expect(page, contains('--logo-width: auto;'));
  });

  test('renders error page with provisioned logo', () async {
    final logo = utf8.encode('<svg xmlns="http://www.w3.org/2000/svg"/>');
    final page = await renderAuthCallbackPage(
      _bootstrap(logo: logo),
      success: false,
    );

    expect(page, contains('<body class="error">'));
    expect(page, contains('Sign-in failed'));
    expect(page, contains('data:image/svg+xml;base64,${base64Encode(logo)}'));
    expect(page, contains('--logo-width: 128px;'));
  });
}
