import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/src/auth/account_manager/account.dart';
import 'package:datahub/src/auth/account_manager/account_endpoints.dart';
import 'package:datahub/src/auth/account_manager/account_manager_service.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

void main() => declareTest(
  'OIDC test',
  [
    MemoryRepositoryService(bean: $Account.bean),
    AccountManagerService(),
    ApiService(routes: [AccountEndpoints()]),
  ],
  () => Completer().future,
  config: {
    'port': 8090,
    'accountManager': {'issuer': 'http://localhost:8090'},
  },
  timeout: Timeout.none,
);
