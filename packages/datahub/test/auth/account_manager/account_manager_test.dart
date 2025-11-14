import 'package:datahub/datahub.dart';
import 'package:datahub/src/auth/account_manager/account.dart';
import 'package:datahub/src/auth/account_manager/account_manager_service.dart';
import 'package:datahub/test.dart';
import 'package:test/expect.dart';

void main() {
  declareTest(
    'Create Account',
    [MemoryRepositoryService(bean: $Account.bean), AccountManagerService()],
    () async {
      final accountManager = Find<AccountManager>().find();
      final account = await accountManager.createAccount(
        email: 'test@example.com',
        password: 'secretpassword',
        allowSignIn: true,
      );

      expect(account.allowSignIn, isTrue);

      final account2 = await accountManager.createAccount(
        email: 'other@example.com',
        allowSignIn: true,
      );

      expect(account2.allowSignIn, isTrue);
      expect(account2.password, isNull);

      await expectLater(
        () => accountManager.signInPassword('other@example.com', 'password'),
        throwsApiRequestException(hasStatusCode(equals(401))),
        reason: 'Sign in should fail when no password is set.',
      );

      final account3 = await accountManager.createAccount(
        email: 'other2@example.com',
        password: 'secretpassword',
        allowSignIn: false,
      );

      expect(account3.allowSignIn, isFalse);
      expect(account3.password, isNotNull);

      await expectLater(
        () => accountManager.signInPassword(
          'other2@example.com',
          'secretpassword',
        ),
        throwsApiRequestException(hasStatusCode(equals(401))),
        reason: 'Sign in should fail when allowSignIn is false.',
      );

      await expectLater(
        () => accountManager.createAccount(
          email: 'other@example.com',
          password: 'secretpassword',
        ),
        throwsApiRequestException(hasStatusCode(equals(400))),
        reason: 'Account creation should fail when email already exists.',
      );
    },
  );

  declareTest(
    'Sign-In',
    [MemoryRepositoryService(bean: $Account.bean), AccountManagerService()],
    () async {
      final accountManager = Find<AccountManager>().find();
      await accountManager.createAccount(
        email: 'test@example.com',
        password: 'secretpassword',
      );

      final (account, jwt) = await accountManager.signInPassword(
        'test@example.com',
        'secretpassword',
      );
      expect(
        account.email,
        equals('test@example.com'),
        reason: 'Email should match the one used when creating the account.',
      );
      expect(
        account.password,
        isNot('secretpassword'),
        reason: 'Password should not be stored in plain text.',
      );
      expect(jwt.kid, isNotNull, reason: 'JWT should contain key id.');
      expect(
        jwt.sub,
        equals(account.id),
        reason: 'JWT should contain account id as subject.',
      );
      expect(jwt.iat, isNotNull, reason: 'JWT should contain iat claim.');
      expect(jwt.exp, isNotNull, reason: 'JWT should contain exp claim.');
      expect(
        account.createdAt.millisecondsSinceEpoch,
        lessThan(DateTime.timestamp().millisecondsSinceEpoch),
        reason: 'CreatedAt timestamp should be before now.',
      );
      await expectLater(
        () => accountManager.signInPassword('wrong@email.com', 'password'),
        throwsApiRequestException(hasStatusCode(equals(401))),
        reason: 'Sign in should fail with unknown email address.',
      );
      await expectLater(
        () => accountManager.signInPassword('test@example.com', 'password'),
        throwsApiRequestException(hasStatusCode(equals(401))),
        reason: 'Sign in should fail with invalid password.',
      );
    },
  );
}
