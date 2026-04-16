import 'dart:async';
import 'package:datahub/api.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/aperture_app.dart';
import 'package:datahub_aperture_frontend/repositories/bootstrap_repository/bootstrap_repository.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/repositories/bootstrap_repository/bootstrap_repository.dart';
import 'package:datahub_aperture_frontend/services/auth_service.dart';
import 'package:datahub_aperture_frontend/utils/bootstrap.dart';
import 'package:datahub_aperture_frontend/widgets/side_bar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MockBootstrapRepository implements BootstrapRepository {
  final ApertureBootstrap bootstrap;
  MockBootstrapRepository(this.bootstrap);

  @override
  Future<ApertureBootstrap> fetch() async => bootstrap;
}

class MockResourcesRepository implements ResourcesRepository {
  @override
  Future<List<ResourceDescription>> getDescriptions() async => [];
  @override
  Future<List<ModuleDescription>> getModules() async => [];
  @override
  Future<ResourceDescription> getDescription(String id) async =>
      throw UnimplementedError();
  @override
  Future<ResourceElementsResponse> getResourceElements(
    String resourceId, {
    ResourceFilter? filter,
    int offset = 0,
    int limit = 25,
  }) async => throw UnimplementedError();
  @override
  Future<ResourceData> getResourceElement(
    String resourceId,
    String elementId, {
    int? version,
  }) async => throw UnimplementedError();
  @override
  Future<ResourceData> updateElement(
    String resourceId,
    String elementId,
    Map<String, dynamic> changes,
    DateTime? from,
  ) async => throw UnimplementedError();
  @override
  Future<ResourceData> createElement(
    String resourceId,
    Map<String, dynamic> changes,
    DateTime? from,
  ) async => throw UnimplementedError();
  @override
  Future<ResourceData?> deleteElement(
    String resourceId,
    String elementId,
    DateTime? from,
  ) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> startElementAction(
    String resourceId,
    String elementId,
    String actionId,
  ) async => throw UnimplementedError();
}

class MockAuthService implements AuthService {
  final _controller = StreamController<bool>.broadcast();
  bool _authenticated = false;

  @override
  Stream<bool> get stream => _controller.stream;

  @override
  Future<void> initialize(
    Uri issuerUrl, {
    String? clientId,
    String? clientSecret,
    String? audience,
  }) async {
    _controller.add(_authenticated);
  }

  @override
  Future<Uri> createAuthUri(String redirectUrl) async =>
      Uri.parse('https://example.com/auth');

  @override
  Future<void> signInAuthorizationCode(String state, String code) async {
    _authenticated = true;
    _controller.add(true);
  }

  @override
  Future<void> signOut() async {
    _authenticated = false;
    _controller.add(false);
  }

  @override
  Future<Jwt> getValidAccessToken() async => throw UnimplementedError();
}

void main() {
  late MockAuthService authService;
  late MockBootstrapRepository bootstrapRepository;
  late MockResourcesRepository resourcesRepository;

  final bootstrapData = ApertureBootstrap(
    baseUrl: 'http://localhost:8080',
    title: 'Test App',
    oidcIssuer: 'https://issuer.com',
    oidcClientId: 'client-id',
    oidcClientSecret: 'client-secret',
    oidcScopes: ['openid', 'profile'],
    theme: ApertureTheme(color: Colors.blue.value, logo: null),
  );

  setUp(() {
    authService = MockAuthService();
    bootstrapRepository = MockBootstrapRepository(bootstrapData);
    resourcesRepository = MockResourcesRepository();
  });

  Widget createTestWidget() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BootstrapRepository>(
          create: (_) => bootstrapRepository,
        ),
        RepositoryProvider<ResourcesRepository>(
          create: (_) => resourcesRepository,
        ),
        RepositoryProvider<AuthService>(create: (_) => authService),
      ],
      child: const ApertureApp(),
    );
  }

  testWidgets('Authentication flow test', (tester) async {
    // 1. Initial load -> Redirect to /auth -> Show AuthPage
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle(); // Settle navigation to /auth

    // Let's find by type FilledButton which is used in AuthPage
    final loginButton = find.byType(FilledButton);
    expect(loginButton, findsOneWidget);

    // 2. Click Login (Simulate OIDC flow)
    // Since we mocked AuthService, we can't easily test the browser redirection in a widget test,
    // but we can test the receiveAuthorizationCode flow which is what happens when returning from OIDC.

    // 3. Receive Auth Code -> Redirect to Dashboard
    // We can't easily trigger the GoRouter redirect from outside in this setup without accessing the Cubit.
    // However, we can simulate the AuthService emitting 'true' (authenticated).

    await authService.signInAuthorizationCode('state', 'code');
    await tester.pumpAndSettle();

    // Now we should be on the Dashboard
    expect(find.byType(NavBarPage), findsOneWidget);

    // 4. Logout
    final logoutButton = find.byIcon(Icons.logout);
    expect(logoutButton, findsOneWidget);

    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Should be back on AuthPage
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
