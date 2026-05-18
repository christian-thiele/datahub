---
title: Authentication & Access Control
index: 106
---

DataHub's authentication system is built on **API middleware** and **zone-bound sessions**. Middleware extracts credentials from the request, validates them and attaches a typed `Session` to the `Context`. Downstream handlers then retrieve the session to enforce access rules.

## Sessions

A `Session` is an interface representing an authenticated principal:

```dart
abstract interface class Session {
  String get debugName;   // for logging
  String get identity;    // unique user/account identifier
}
```

Define your own session type to carry application-specific claims:

```dart
class UserSession implements Session {
  final String userId;
  final String email;
  final List<String> roles;

  UserSession({required this.userId, required this.email, required this.roles});

  @override
  String get debugName => 'user:$email';

  @override
  String get identity => userId;
}
```

### Reading the Session

Inside a request handler retrieve the session from the current zone context:

```dart
// Required — throws ApiRequestException.unauthorized() if not present
final session = Context.zoneSession<UserSession>();

// Optional — returns null if not present
final session = Context.zoneSession<UserSession?>();
```

---

## Authentication Middleware

Middleware subclasses intercept requests before they reach endpoints. They:
1. Extract credentials from the request
2. Call `authenticate()` and receive a `Session?`
3. If a session is returned, attach it to the context and call `next(request)`
4. If no session is returned and `requireSession` is `true`, throw `401 Unauthorized`

### JWT Middleware

`JwtAuthMiddleware` validates `Authorization: Bearer <token>` headers using JWKS from an OIDC issuer:

```dart
ApiService(
  routes: [
    JwtAuthMiddleware(
      issuer: const Config('auth.issuer'),
      audience: const Config('auth.audience'),
      routes: [
        // protected endpoints go here
        ResourceEndpoint(
          matcher: RoutePattern('/api/profile'),
          get: (request) async {
            final session = Context.zoneSession<UserSession>();
            return {'userId': session.userId};
          },
        ),
      ],
    ),
  ],
)
```

The middleware verifies the JWT signature by fetching the issuer's public keys automatically. Provide a `JwtAuthProvider` service to translate raw JWT claims into your own `Session` type:

```dart
class MyJwtProvider implements Service, JwtAuthProvider {
  @override
  ServiceInstance<MyJwtProvider> createInstance() => _MyJwtProviderInstance();
}

class _MyJwtProviderInstance extends ServiceInstance<MyJwtProvider>
    implements JwtAuthProvider {

  @override
  Future<Session> authenticateJwt(Jwt jwt) async {
    final userId = jwt.claims['sub'] as String;
    final email  = jwt.claims['email'] as String;
    final roles  = List<String>.from(jwt.claims['roles'] ?? []);
    return UserSession(userId: userId, email: email, roles: roles);
  }
}
```

Configuration:

```yaml
auth:
  issuer: https://auth.example.com/
  audience: my-api
  jwtAuth:
    prefix: "Bearer "
```

### Basic Auth Middleware

`BasicAuthMiddleware` handles `Authorization: Basic <base64>`:

```dart
BasicAuthMiddleware(
  routes: [adminEndpoints],
)
```

Provide a `BasicAuthProvider`:

```dart
class _MyBasicAuthProvider implements BasicAuthProvider {
  @override
  Future<Session> authenticateBasic(BasicAuth credentials) async {
    final user = await verifyPassword(credentials.username, credentials.password);
    if (user == null) throw ApiRequestException.unauthorized();
    return UserSession(userId: user.id, email: user.email, roles: user.roles);
  }
}
```

### Token Middleware

`TokenAuthMiddleware` parses a custom token from the `Authorization` header:

```dart
TokenAuthMiddleware(
  routes: [apiKeyEndpoints],
)
```

Implement `TokenAuthProvider` to validate the token string.

### Skipping Authentication

Set `requireSession: false` to allow unauthenticated requests through — useful when you want to enrich context with a session when present but not require it:

```dart
JwtAuthMiddleware(
  routes: [publicEndpointWithOptionalSession],
  requireSession: false,
)
```

---

## Spawning a Session Context

Outside the normal HTTP request path (e.g. in background jobs) you can run code with a specific session attached:

```dart
final jobSession = ServiceAccountSession(id: 'scheduler');
Context.ofZone().withSession(jobSession, () async {
  await processJob(job);
});
```

---

## Repository-Based Access Control

A common pattern is to override repository methods in a service instance and filter results by the current session:

```dart
class _SecureUserRepoInstance extends ServiceInstance<UserRepoService>
    with PostgresqlDataRepository<UserRepoService, User>
    implements DataRepository<User> {

  @override
  Future<List<User>> readAll({Filter filter = Filter.empty, ...}) async {
    final session = Context.zoneSession<UserSession?>();

    // Non-admin users can only see their own record
    final accessFilter = (session != null && !session.roles.contains('admin'))
        ? User.idField.equals(session.userId).and(filter)
        : filter;

    return super.readAll(filter: accessFilter, ...);
  }
}
```

This "shift-back" pattern enforces access rules inside the data layer itself, so they cannot be bypassed no matter which endpoint or code path reaches the repository.

---

## OIDC / OAuth2

The `datahub_aperture` administration UI supports full OIDC login flows. Configure the OIDC provider in the `ApertureApi`:

```dart
ApertureApi(
  configDelegate: myConfig,
  oidcIssuer:       const Config('aperture.oidcIssuer'),
  oidcClientId:     const Config('aperture.oidcClientId'),
  oidcClientSecret: const Config('aperture.oidcClientSecret'),
  oidcAudience:     const Config('aperture.oidcAudience'),
  oidcScopes:       const Config('aperture.oidcScopes', defaultValue: ['openid', 'email']),
  oidcIdentityField: const Config('aperture.oidcIdentityField', defaultValue: 'sub'),
  oidcUsernameField: const Config('aperture.oidcUsernameField', defaultValue: 'email'),
)
```

```yaml
aperture:
  oidcIssuer:       https://auth.example.com/
  oidcClientId:     my-app
  oidcClientSecret: supersecret
  oidcAudience:     my-api
  oidcScopes:       [openid, email, profile]
```

The Aperture frontend handles the code-exchange flow and stores the access token in session storage. All Aperture API calls then carry the JWT as a `Bearer` token.
