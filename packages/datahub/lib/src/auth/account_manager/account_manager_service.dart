import 'dart:async';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/auth.dart';
import 'package:datahub/config.dart';
import 'package:datahub/data.dart';
import 'package:datahub/http.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import 'package:pointycastle/export.dart';

import 'html/login_page.dart' as login_page;
import 'account.dart';
import 'authorization_code.dart';
import 'client.dart';

part 'key_management.dart';

part 'web_authentication.dart';

abstract interface class AccountManager {
  Future<Account?> getAccount(String id);

  Future<Account?> getAccountByEmail(String email);

  Future<Account> createAccount({
    required String email,
    String? password,
    bool allowSignIn = true,
  });

  Future<Account> signInPassword(String email, String password);

  List<Jwk> getKeySet();

  OidcConfiguration getOpenIdConfiguration();

  Future<ApiResponse> authorizeRequest(ApiRequest request);

  Future<ApiResponse> tokenRequest(ApiRequest request);
}

class AccountManagerService implements Service {
  final Find<DataRepository<Client>> clientRepository;
  final Find<DataRepository<Account>> accountRepository;
  final Find<DataRepository<AuthorizationCode>> authCodeRepository;
  final Config<String> issuer;
  final Config<Duration> keyRotationInterval;
  final Config<Duration> keyRetentionPeriod;
  final Config<Duration> accessTokenExpiration;

  const AccountManagerService({
    this.clientRepository = const Find(),
    this.accountRepository = const Find(),
    this.authCodeRepository = const Find(),
    this.issuer = const Config('accountManager.issuer'),
    this.keyRotationInterval = const Config(
      'accountManager.keyRotationInterval',
      defaultValue: Duration(days: 1),
    ),
    this.keyRetentionPeriod = const Config(
      'accountManager.keyRetentionPeriod',
      defaultValue: Duration(days: 2),
    ),
    this.accessTokenExpiration = const Config(
      'accountManager.accessTokenExpiration',
      defaultValue: Duration(minutes: 15),
    ),
  });

  @override
  ServiceInstance<Service> createInstance() => _AccountManagerServiceInstance();
}

class _AccountManagerServiceInstance
    extends ServiceInstance<AccountManagerService>
    with KeyManagement, WebAuthentication
    implements AccountManager {
  @override
  late final DataRepository<Client> clientRepository;
  late final DataRepository<Account> accountRepository;
  @override
  late final DataRepository<AuthorizationCode> authCodeRepository;

  @override
  Future<void> initialize() async {
    await super.initialize();
    clientRepository = find(service.clientRepository);
    accountRepository = find(service.accountRepository);
    authCodeRepository = find(service.authCodeRepository);
  }

  @override
  Future<Account?> getAccount(String id) async {
    return await accountRepository.readById(id);
  }

  @override
  Future<Account?> getAccountByEmail(String email) async {
    return await accountRepository.first(filter: $Account.$email.equals(email));
  }

  @override
  Future<Account> signInPassword(String email, String password) async {
    final account = await accountRepository.first(
      filter: Filter.andGroup([
        $Account.$email.equals(email),
        $Account.$allowSignIn.equals(true),
        $Account.$password.notEquals(null),
      ]),
    );

    if (account case Account(password: final hash?, allowSignIn: true)) {
      if (await Argon2Id.verify(password, hash)) {
        return account;
      }
    }

    throw ApiRequestException.unauthorized();
  }

  Future<Jwt> issueAccessToken(Account account) async {
    final keySet = currentKeySet;
    return Jwt.create(
      {'kid': keySet.id},
      {
        'sub': account.id,
        'email': account.email,
        'iat': DateTime.timestamp().secondsSinceEpoch,
        'exp': earliest(
          DateTime.timestamp().add(read(service.accessTokenExpiration)),
          keySet.validUntil,
        ).secondsSinceEpoch,
      },
      keySet.privateKey,
    );
  }

  Future<String> issueRefreshToken(Account account) async {
    final token = Token();

    return token.toString();
  }

  @override
  Future<Account> createAccount({
    required String email,
    String? password,
    bool allowSignIn = true,
  }) async {
    return await accountRepository.atomic(() async {
      final existing = await accountRepository.first(
        filter: $Account.$email.equals(email),
      );

      if (existing != null) {
        throw ApiRequestException.badRequest('Email already registered.');
      }

      return await accountRepository.create(
        Account(
          email: email,
          password: await password?.apply(Argon2Id.createEncodedHash),
          allowSignIn: allowSignIn,
          createdAt: DateTime.timestamp(),
        ),
      );
    });
  }

  @override
  OidcConfiguration getOpenIdConfiguration() {
    final issuer = read(service.issuer);
    return OidcConfiguration(
      issuer: read(service.issuer),
      jwksUri: '$issuer/oidc/jwks',
      authorizationEndpoint: '$issuer/oidc/auth',
      tokenEndpoint: '$issuer/oidc/token',
      scopesSupported: ['openid', 'scope', 'profile', 'email'],
      responseTypesSupported: ['code'],
      codeChallengeMethodsSupported: ['S256'],
      subjectTypesSupported: ['public'],
      idTokenSigningAlgValuesSupported: ['RS256'],
      authorizationSigningAlgValuesSupported: ['RS256'],
      tokenEndpointAuthSigningAlgValuesSupported: ['RS256'],
      grantTypesSupported: [
        'authorization_code',
        'client_credentials',
        'refresh_token',
      ],
      frontchannelLogoutSupported: true,
      frontchannelLogoutSessionSupported: true,
    );
  }
}
