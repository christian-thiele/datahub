import 'dart:convert';
import 'dart:io' as io;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:pointycastle/export.dart';

/// A minimal OpenID Connect provider for local testing.
///
/// Every authorization request is answered immediately with a
/// redirect back to the app, as if the demo account had just signed in.
///
/// Supports the authorization code flow with PKCE (S256), refresh tokens,
/// discovery, JWKS and userinfo. Signing keys are generated on startup, so
/// tokens do not survive a restart.
class DemoAuthService implements Service {
  /// Issuer url. The service listens on the port of this url and serves
  /// all endpoints below its path.
  final Config<String> issuer;

  /// Client id the app has to use. Accepts any client id when null.
  final Config<String?> clientId;

  final String subject;
  final String username;
  final String email;
  final String givenName;
  final String familyName;

  final Duration accessTokenLifetime;
  final Duration refreshTokenLifetime;

  const DemoAuthService({
    this.issuer = const Config.value('http://localhost:8081/realms/local-oidc'),
    this.clientId = const Config.value(null),
    this.subject = 'b2f4c8a6-1d3e-4f5a-9b7c-0e2d4f6a8c01',
    this.username = 'demo',
    this.email = 'demo@example.com',
    this.givenName = 'Demo',
    this.familyName = 'User',
    this.accessTokenLifetime = const Duration(minutes: 5),
    this.refreshTokenLifetime = const Duration(hours: 8),
  });

  @override
  ServiceInstance<DemoAuthService> createInstance() =>
      _DemoAuthServiceInstance();
}

typedef _AuthorizationCode = ({
  String? clientId,
  String redirectUri,
  String? codeChallenge,
  String? nonce,
  String scope,
  DateTime expires,
});

class _DemoAuthServiceInstance extends ServiceInstance<DemoAuthService> {
  static const _codeLifetime = Duration(minutes: 1);

  late final Uri _issuer;
  late final String? _clientId;
  late final String _keyId;
  late final RSAPublicKey _publicKey;
  late final RSAPrivateKey _privateKey;
  late final HttpServer _server;

  final _codes = <String, _AuthorizationCode>{};

  String get _issuerString => _issuer.toString();

  String get _basePath =>
      _issuer.path.endsWith('/') ? _issuer.path : '${_issuer.path}/';

  @override
  Future<void> initialize() async {
    await super.initialize();
    _issuer = Uri.parse(read(service.issuer));
    _clientId = read(service.clientId);
    _keyId = uuid();
    final (publicKey, privateKey) = _generateKeyPair();
    _publicKey = publicKey;
    _privateKey = privateKey;

    final socket = await io.ServerSocket.bind(
      io.InternetAddress.loopbackIPv4,
      _issuer.port,
    );

    _server = HttpServer(
      socket,
      _handleRequest,
      (e, s) => log.warn('Socket error.', error: e, stack: s),
      (e, s) => log.warn('Protocol error.', error: e, stack: s),
      (e, s) => log.warn('Stream error.', error: e, stack: s),
    );

    log.info(
      'Demo auth provider listening on $_issuerString '
      '(user: ${service.username} / ${service.email}).',
    );
  }

  @override
  Future<void> dispose() async {
    await _server.close(force: true);
    await super.dispose();
  }

  Future<HttpResponse> _handleRequest(HttpRequest request) async {
    ApiResponse response;
    try {
      if (request.method == HttpRequestMethod.options) {
        response = EmptyResponse(statusCode: 204);
      } else {
        response = switch ((request.method, _endpointOf(request))) {
          (HttpRequestMethod.get, '.well-known/openid-configuration') =>
            _discovery(),
          (HttpRequestMethod.get, 'protocol/openid-connect/certs') => _jwks(),
          (HttpRequestMethod.get, 'protocol/openid-connect/auth') => _authorize(
            request,
          ),
          (HttpRequestMethod.post, 'protocol/openid-connect/token') =>
            await _token(request),
          (
            HttpRequestMethod.get || HttpRequestMethod.post,
            'protocol/openid-connect/userinfo',
          ) =>
            await _userInfo(request),
          (HttpRequestMethod.get, 'protocol/openid-connect/logout') => _logout(
            request,
          ),
          _ => TextResponse.plain('Not found.', statusCode: 404),
        };
      }
    } on _OAuthError catch (e) {
      response = JsonResponse({
        'error': e.error,
        'error_description': e.description,
      }, statusCode: e.statusCode);
    } catch (e, stack) {
      log.error('Demo auth request failed.', error: e, stack: stack);
      response = JsonResponse({
        'error': 'server_error',
        'error_description': e.toString(),
      }, statusCode: 500);
    }

    return HttpResponse(request.requestUri, response.statusCode, {
      ...response.getHeaders(),
      'access-control-allow-origin': ['*'],
      'access-control-allow-methods': ['GET, POST, OPTIONS'],
      'access-control-allow-headers': ['authorization, content-type'],
      'cache-control': ['no-store'],
    }, response.getData());
  }

  String? _endpointOf(HttpRequest request) {
    final path = request.requestUri.path;
    if (!path.startsWith(_basePath)) {
      return null;
    }
    return path.substring(_basePath.length);
  }

  Uri _endpoint(String endpoint) =>
      _issuer.replace(path: '$_basePath$endpoint');

  ApiResponse _discovery() => JsonResponse({
    'issuer': _issuerString,
    'authorization_endpoint': _endpoint(
      'protocol/openid-connect/auth',
    ).toString(),
    'token_endpoint': _endpoint('protocol/openid-connect/token').toString(),
    'userinfo_endpoint': _endpoint(
      'protocol/openid-connect/userinfo',
    ).toString(),
    'end_session_endpoint': _endpoint(
      'protocol/openid-connect/logout',
    ).toString(),
    'jwks_uri': _endpoint('protocol/openid-connect/certs').toString(),
    'grant_types_supported': ['authorization_code', 'refresh_token'],
    'response_types_supported': ['code'],
    'response_modes_supported': ['query'],
    'subject_types_supported': ['public'],
    'id_token_signing_alg_values_supported': ['RS256'],
    'code_challenge_methods_supported': ['S256'],
    'token_endpoint_auth_methods_supported': [
      'none',
      'client_secret_post',
      'client_secret_basic',
    ],
    'scopes_supported': ['openid', 'profile', 'email', 'offline_access'],
    'claims_supported': [
      'sub',
      'iss',
      'aud',
      'exp',
      'iat',
      'name',
      'given_name',
      'family_name',
      'preferred_username',
      'email',
      'email_verified',
    ],
  });

  ApiResponse _jwks() => JsonResponse({
    'keys': [
      {
        'kty': 'RSA',
        'use': 'sig',
        'alg': 'RS256',
        'kid': _keyId,
        'n': base64UintEncode(_publicKey.modulus!),
        'e': base64UintEncode(_publicKey.publicExponent!),
      },
    ],
  });

  /// Skips any login page and redirects straight back to the app.
  ApiResponse _authorize(HttpRequest request) {
    final params = request.requestUri.queryParameters;

    final rawRedirectUri = params['redirect_uri'];
    final redirectUri = Uri.tryParse(rawRedirectUri ?? '');
    if (rawRedirectUri == null ||
        redirectUri == null ||
        !redirectUri.hasScheme) {
      return TextResponse.plain(
        'Missing or invalid redirect_uri.',
        statusCode: 400,
      );
    }

    if (params['response_type'] != 'code') {
      return _redirect(redirectUri, {
        'error': 'unsupported_response_type',
        'state': ?params['state'],
      });
    }

    final clientId = params['client_id'];
    if (_clientId != null && clientId != _clientId) {
      return _redirect(redirectUri, {
        'error': 'unauthorized_client',
        'error_description': 'Unknown client "$clientId".',
        'state': ?params['state'],
      });
    }

    final codeChallenge = params['code_challenge'];
    final challengeMethod = params['code_challenge_method'] ?? 'plain';
    if (codeChallenge != null && challengeMethod != 'S256') {
      return _redirect(redirectUri, {
        'error': 'invalid_request',
        'error_description': 'Only S256 code challenges are supported.',
        'state': ?params['state'],
      });
    }

    _codes.removeWhere((_, code) => code.expires.isBefore(DateTime.now()));
    final code = _randomToken();
    _codes[code] = (
      clientId: clientId,
      redirectUri: rawRedirectUri,
      codeChallenge: codeChallenge,
      nonce: params['nonce'],
      scope: params['scope'] ?? 'openid profile email',
      expires: DateTime.now().add(_codeLifetime),
    );

    log.info('Signed in demo user "${service.username}" for "$clientId".');

    return _redirect(redirectUri, {
      'code': code,
      'state': ?params['state'],
      'iss': _issuerString,
    });
  }

  ApiResponse _logout(HttpRequest request) {
    final params = request.requestUri.queryParameters;
    if (Uri.tryParse(params['post_logout_redirect_uri'] ?? '')
        case final redirectUri? when redirectUri.hasScheme) {
      return _redirect(redirectUri, {'state': ?params['state']});
    }
    return TextResponse.plain('Signed out.');
  }

  Future<ApiResponse> _token(HttpRequest request) async {
    final form = Uri.splitQueryString(
      utf8.decode(await request.bodyData.expand((e) => e).toList()),
    );

    final clientId = form['client_id'] ?? _basicAuthClientId(request);
    if (_clientId != null && clientId != _clientId) {
      throw _OAuthError('invalid_client', 'Unknown client "$clientId".', 401);
    }

    switch (form['grant_type']) {
      case 'authorization_code':
        final code = _codes.remove(form['code']);
        if (code == null || code.expires.isBefore(DateTime.now())) {
          throw _OAuthError('invalid_grant', 'Invalid or expired code.');
        }
        if (code.clientId != null && code.clientId != clientId) {
          throw _OAuthError('invalid_grant', 'Client id mismatch.');
        }
        if (code.redirectUri != form['redirect_uri']) {
          throw _OAuthError('invalid_grant', 'Redirect uri mismatch.');
        }
        if (code.codeChallenge case final challenge?) {
          final verifier = form['code_verifier'];
          if (verifier == null || _s256(verifier) != challenge) {
            throw _OAuthError('invalid_grant', 'PKCE verification failed.');
          }
        }
        return _issueTokens(clientId, code.scope, code.nonce);

      case 'refresh_token':
        final Jwt refreshToken;
        try {
          refreshToken = Jwt(form['refresh_token'] ?? '');
          await refreshToken.verify(
            issuer: _issuerString,
            publicKey: _publicKey,
          );
        } catch (_) {
          throw _OAuthError('invalid_grant', 'Invalid refresh token.');
        }
        if (refreshToken.payload['typ'] != 'Refresh' ||
            refreshToken.payload['azp'] != clientId) {
          throw _OAuthError('invalid_grant', 'Invalid refresh token.');
        }
        return _issueTokens(
          clientId,
          refreshToken.payload['scope'] as String? ?? 'openid',
          null,
        );

      case final grantType:
        throw _OAuthError(
          'unsupported_grant_type',
          'Grant type "$grantType" is not supported.',
        );
    }
  }

  Future<ApiResponse> _userInfo(HttpRequest request) async {
    final token = Jwt.fromRequest(request.headers);
    try {
      await token?.verify(issuer: _issuerString, publicKey: _publicKey);
    } catch (_) {
      throw _OAuthError('invalid_token', 'Invalid access token.', 401);
    }
    if (token == null || token.payload['typ'] != 'Bearer') {
      throw _OAuthError('invalid_token', 'Missing access token.', 401);
    }
    return JsonResponse(_userClaims);
  }

  ApiResponse _issueTokens(String? clientId, String scope, String? nonce) {
    final now = DateTime.now();
    final iat = now.millisecondsSinceEpoch ~/ 1000;
    final sessionId = uuid();

    String sign(Map<String, dynamic> payload, Duration lifetime) => Jwt.create(
      {'kid': _keyId},
      {
        'exp': iat + lifetime.inSeconds,
        'iat': iat,
        'jti': uuid(),
        'iss': _issuerString,
        'sub': service.subject,
        'azp': ?clientId,
        'sid': sessionId,
        'scope': scope,
        ...payload,
      },
      _privateKey,
    ).token;

    return JsonResponse({
      'access_token': sign({
        'typ': 'Bearer',
        'aud': ?clientId,
        ..._userClaims,
      }, service.accessTokenLifetime),
      'token_type': 'Bearer',
      'expires_in': service.accessTokenLifetime.inSeconds,
      'refresh_token': sign({
        'typ': 'Refresh',
        'aud': _issuerString,
      }, service.refreshTokenLifetime),
      'refresh_expires_in': service.refreshTokenLifetime.inSeconds,
      'id_token': sign({
        'typ': 'ID',
        'aud': ?clientId,
        'nonce': ?nonce,
        ..._userClaims,
      }, service.accessTokenLifetime),
      'scope': scope,
    });
  }

  Map<String, dynamic> get _userClaims => {
    'sub': service.subject,
    'preferred_username': service.username,
    'email': service.email,
    'email_verified': true,
    'name': '${service.givenName} ${service.familyName}',
    'given_name': service.givenName,
    'family_name': service.familyName,
  };

  String? _basicAuthClientId(HttpRequest request) {
    final auth = request.headers['authorization']?.firstOrNull;
    if (auth == null || !auth.startsWith('Basic ')) {
      return null;
    }
    final decoded = utf8.decode(base64Decode(auth.substring(6)));
    return Uri.decodeComponent(decoded.split(':').first);
  }

  static ApiResponse _redirect(Uri target, Map<String, String> params) {
    final location = target.replace(
      queryParameters: {...target.queryParameters, ...params},
    );
    return EmptyResponse(
      statusCode: 302,
      headers: {
        'location': [location.toString()],
      },
    );
  }

  static String _s256(String verifier) => stripBase64Padding(
    base64UrlEncode(SHA256Digest().process(utf8.encode(verifier))),
  );

  static String _randomToken() {
    final rng = math.Random.secure();
    return stripBase64Padding(
      base64UrlEncode(List.generate(32, (_) => rng.nextInt(256))),
    );
  }

  static (RSAPublicKey, RSAPrivateKey) _generateKeyPair() {
    final rng = math.Random.secure();
    final random = FortunaRandom()
      ..seed(
        KeyParameter(
          Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256))),
        ),
      );

    final generator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          random,
        ),
      );

    final pair = generator.generateKeyPair();
    return (pair.publicKey, pair.privateKey);
  }
}

class _OAuthError implements Exception {
  final String error;
  final String description;
  final int statusCode;

  _OAuthError(this.error, this.description, [this.statusCode = 400]);
}
