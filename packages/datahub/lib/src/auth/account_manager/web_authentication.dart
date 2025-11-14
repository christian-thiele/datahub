part of 'account_manager_service.dart';

mixin WebAuthentication on ServiceInstance<AccountManagerService> {
  DataRepository<AuthorizationCode> get authCodeRepository;

  DataRepository<Client> get clientRepository;

  Future<ApiResponse> authorizeRequest(ApiRequest request) async {
    return switch (request.method) {
      HttpRequestMethod.get => await _authPage(request),
      HttpRequestMethod.post => await _authPageSubmit(request),
      _ => throw ApiRequestException.methodNotAllowed(),
    };
  }
  
  Future<ApiRequest> tokenRequest(ApiRequest request) async {

  }

  Future<ApiResponse> _authPage(ApiRequest request) async {
    if (request.getParam<String>('response_type') != 'code') {
      throw ApiRequestException.badRequest('Invalid response_type.');
    }

    final clientId = request.getParam<String>('client_id');
    final clientSecret = request.getParam<String?>('client_secret');
    final Uri redirectUri;
    try {
      redirectUri = Uri.parse(request.getParam<String>('redirect_uri'));
    } catch (e) {
      throw ApiRequestException.badRequest('Malformed redirect_uri.');
    }

    // TODO scopes
    final scope = request.getParam<String?>('scope')?.split('+');
    final state = request.getParam<String>('state');
    final codeChallenge = request.getParam<String>('code_challenge');
    final codeChallengeMethod = request.getParam<String?>(
      'code_challenge_method',
    );

    final client =
        await clientRepository.readById(clientId) ??
        (throw ApiRequestException.badRequest('Invalid client_id.'));
    if (client.secret != clientSecret) {
      throw ApiRequestException.unauthorized('Invalid client_secret.');
    }

    if (!_checkRedirectUri(redirectUri, client.redirectUris)) {
      throw ApiRequestException.forbidden('Invalid redirect_uri');
    }

    if (codeChallengeMethod != null && codeChallengeMethod != 'S256') {
      throw ApiRequestException.badRequest('Invalid code_challenge_method.');
    }

    if (codeChallenge.isEmpty) {
      throw ApiRequestException.badRequest('Invalid code_challenge.');
    }

    if (state.isEmpty) {
      throw ApiRequestException.badRequest('Invalid state.');
    }

    return TextResponse.html(login_page.html);
  }

  Future<ApiResponse> _authPageSubmit(ApiRequest request) async {
    final clientId = request.getParam<String>('client_id');
    final clientSecret = request.getParam<String?>('client_secret');
    final Uri redirectUri;
    try {
      redirectUri = Uri.parse(request.getParam<String>('redirect_uri'));
    } catch (e) {
      throw ApiRequestException.badRequest('Malformed redirect_uri.');
    }
    // TODO scopes
    final scope = request.getParam<String?>('scope')?.split('+');
    final state = request.getParam<String>('state');
    final codeChallenge = request.getParam<String>('code_challenge');
    final codeChallengeMethod = request.getParam<String?>(
      'code_challenge_method',
    );

    final client =
        await clientRepository.readById(clientId) ??
        (throw ApiRequestException.badRequest('Invalid client_id.'));
    if (client.secret != clientSecret) {
      throw ApiRequestException.unauthorized('Invalid client_secret.');
    }

    if (!_checkRedirectUri(redirectUri, client.redirectUris)) {
      throw ApiRequestException.forbidden('Invalid redirect_uri');
    }

    if (codeChallengeMethod != null && codeChallengeMethod != 'S256') {
      throw ApiRequestException.badRequest('Invalid code_challenge_method.');
    }

    if (codeChallenge.isEmpty) {
      throw ApiRequestException.badRequest('Invalid code_challenge.');
    }

    if (state.isEmpty) {
      throw ApiRequestException.badRequest('Invalid state.');
    }

    final formData = HttpFormData.parse(await request.getTextBody());

    final email = switch (formData.data['email']) {
      final email? when email.isNotEmpty => email,
      _ => throw ApiRequestException.badRequest('Missing email.'),
    };

    final password = switch (formData.data['email']) {
      final password? when password.isNotEmpty => password,
      _ => throw ApiRequestException.badRequest('Missing password.'),
    };

    final account = await (this as AccountManager).signInPassword(
      email,
      password,
    );

    final secureRandom = FortunaRandom()
      ..seed(
        KeyParameter(Platform.instance.platformEntropySource().getBytes(32)),
      );

    final code = secureRandom.nextBytes(16).toHexString().toLowerCase();
    final authCode = AuthorizationCode(
      code: code,
      clientId: clientId,
      accountId: account.id,
      challenge: codeChallenge,
      state: state,
      issuedAt: DateTime.timestamp(),
      // TODO configurable
      validUntil: DateTime.timestamp().add(const Duration(minutes: 5)),
    );

    await authCodeRepository.create(authCode);

    return EmptyResponse(
      statusCode: 302,
      headers: {
        'Location': Uri(
          scheme: redirectUri.scheme,
          host: redirectUri.host,
          path: redirectUri.path,
          queryParameters: {
            ...redirectUri.queryParametersAll,
            'code': authCode.code,
            'state': authCode.state,
          },
        ).toString(),
      },
    );
  }

  bool _checkRedirectUri(Uri redirectUri, List<String> redirectUris) {
    final base = Uri(
      scheme: redirectUri.scheme,
      host: redirectUri.host,
      path: redirectUri.path,
    ).toString();
    return redirectUris.any((pattern) {
      if (pattern == base) {
        return true;
      } else if (pattern.endsWith('*') &&
          base.startsWith(pattern.substring(0, pattern.length - 1))) {
        return true;
      } else {
        return false;
      }
    });
  }
}
