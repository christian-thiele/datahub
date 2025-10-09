import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _authStateKey = 'oidc-state';
  final _prefs = Lazy<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
  );

  static final instance = AuthService._();

  AuthService._();

  factory AuthService() => instance;

  final _controller = StreamController<bool>();

  Stream<bool> get stream => _controller.stream;
  final _lock = Semaphore();

  OidcClient? _oidcClient;
  OidcResponse? _currentAuth;

  Future<void> initialize(
    Uri issuerUrl, {
    String? clientId,
    String? clientSecret,
    String? audience,
  }) async {
    await _lock.runLocked(() async {
      _oidcClient = await OidcClient.discover(
        issuerUrl,
        clientId: clientId,
        clientSecret: clientSecret,
        audience: audience,
      );
      _controller.add(false);
    });
  }

  Future<Uri> createAuthUri(String redirectUrl) async {
    if (_oidcClient case final client?) {
      final prefs = await _prefs.get();
      final rng = Random.secure();
      final state = uuid();
      final verifier = Iterable.generate(
        64,
        (i) => rng.nextInt(36).toRadixString(36),
      ).join();
      final challenge = base64UrlEncode(
        SHA256Digest().process(utf8.encode(verifier)),
      ).replaceAll('=', '');

      final redirectUrl = Uri.base.toString();
      prefs.setStringList(_authStateKey, [state, verifier, redirectUrl]);

      return client.createAuthUri(redirectUrl, state, challenge);
    } else {
      throw Exception('OidcClient not initialized.');
    }
  }

  Future<void> signInAuthorizationCode(String state, String code) async {
    await _lock.runLocked(() async {
      final prefs = await _prefs.get();
      try {
        if (prefs.getStringList(_authStateKey) case [
          final sState,
          final verifier,
          final redirectUrl,
        ] when sState == state) {
          _currentAuth = await _oidcClient!.getToken(
            code,
            verifier,
            redirectUrl,
          );
          _controller.add(true);
        } else {
          throw Exception('Invalid authentication state.');
        }
      } finally {
        prefs.remove(_authStateKey);
      }
    });
  }

  Future<Jwt> getValidAccessToken() async {
    return await _lock.runLocked(() async {
      if (_currentAuth?.accessToken case final String token) {
        final accessToken = Jwt(token);
        if (accessToken.exp?.isAfter(DateTime.timestamp()) ?? true) {
          return accessToken;
        }
      }

      if (_oidcClient case final client?) {
        if (_currentAuth?.refreshToken case final refreshToken?) {
          try {
            final auth = await client.refreshToken(refreshToken);
            _currentAuth = auth;
            return Jwt(auth.accessToken);
          } on ApiRequestException catch (_) {
            _controller.add(false);
            rethrow;
          }
        } else {
          _currentAuth = null;
          _controller.add(false);
          throw Exception('Not signed in.');
        }
      } else {
        _controller.add(false);
        throw Exception('OidcClient not initialized.');
      }
    });
  }

  Future<void> signOut() async {
    await _lock.runLocked(() async {
      // TODO oidc signout
      _currentAuth = null;
      _controller.add(false);
    });
  }
}
