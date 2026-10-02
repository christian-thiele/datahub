import 'dart:async';

import 'package:datahub_redis/datahub_redis.dart';
import 'package:datahub_redis/src/protocol/redis_socket_connection.dart';
import 'package:test/test.dart';

import '../utils/fake_redis_server.dart';

void main() {
  late FakeRedisServer server;

  Future<RedisSocketConnection> connect({
    Duration commandTimeout = const Duration(seconds: 5),
    String? password,
    String? username,
    int database = 0,
    String? clientName,
  }) => RedisSocketConnection.connect(
    host: '127.0.0.1',
    port: server.port,
    commandTimeout: commandTimeout,
    password: password,
    username: username,
    database: database,
    clientName: clientName,
  );

  tearDown(() => server.close());

  group('RedisSocketConnection', () {
    test('pipelines concurrent commands in a single write', () async {
      final pending = <FakeClient>[];
      server = await FakeRedisServer.start((command, client) {
        // respond only when all three commands arrived
        pending.add(client);
        if (pending.length == 3) {
          client.write(':1\r\n:2\r\n:3\r\n');
        }
        return null;
      });
      final connection = await connect();

      final results = await Future.wait([
        connection.incr('a'),
        connection.incr('b'),
        connection.incr('c'),
      ]);

      expect(results, equals([1, 2, 3]));
      expect(server.clients.single.chunks, equals(1));
      expect(
        server.commands,
        equals([
          ['INCR', 'a'],
          ['INCR', 'b'],
          ['INCR', 'c'],
        ]),
      );
      await connection.close();
    });

    test('a timed out command closes the connection', () async {
      server = await FakeRedisServer.start((command, client) => null);
      final connection = await connect(
        commandTimeout: const Duration(milliseconds: 100),
      );

      final first = connection.get('a');
      final second = connection.get('b');

      await expectLater(first, throwsA(isA<TimeoutException>()));
      await expectLater(second, throwsA(isA<RedisConnectionException>()));
      expect(connection.isOpen, isFalse);
      await expectLater(
        connection.get('c'),
        throwsA(isA<RedisConnectionException>()),
      );
    });

    test('a late reply after a timeout is never matched', () async {
      late FakeClient lateClient;
      server = await FakeRedisServer.start((command, client) {
        lateClient = client;
        return null;
      });
      final connection = await connect(
        commandTimeout: const Duration(milliseconds: 50),
      );

      await expectLater(connection.get('a'), throwsA(isA<TimeoutException>()));
      lateClient.write('\$5\r\nlate!\r\n');
      await expectLater(
        connection.get('b'),
        throwsA(isA<RedisConnectionException>()),
      );
    });

    test('per-command timeouts override the default', () async {
      server = await FakeRedisServer.start((command, client) {
        Timer(
          const Duration(milliseconds: 200),
          () => client.write('\$1\r\nx\r\n'),
        );
        return null;
      });
      final connection = await connect(
        commandTimeout: const Duration(milliseconds: 50),
      );

      final reply = await connection.execute([
        'BLPOP',
        'queue',
        '1',
      ], timeout: const Duration(seconds: 2));

      expect(reply.asString, equals('x'));
      expect(connection.isOpen, isTrue);
      await connection.close();
    });

    test('pending commands fail when the server closes', () async {
      server = await FakeRedisServer.start((command, client) {
        client.socket.destroy();
        return null;
      });
      final connection = await connect();

      await expectLater(
        connection.get('a'),
        throwsA(isA<RedisConnectionException>()),
      );
      await connection.closed;
      expect(connection.isOpen, isFalse);
    });

    test('a reply without command closes the connection', () async {
      server = await FakeRedisServer.start(okHandler);
      final connection = await connect();
      (await server.firstClient()).write('+unexpected\r\n');

      await connection.closed.timeout(const Duration(seconds: 2));
      expect(connection.isOpen, isFalse);
    });

    test('a protocol violation closes the connection', () async {
      server = await FakeRedisServer.start((command, client) => '%1\r\n');
      final connection = await connect();

      await expectLater(
        connection.get('a'),
        throwsA(
          isA<RedisConnectionException>().having(
            (e) => e.message,
            'message',
            contains('Protocol'),
          ),
        ),
      );
      expect(connection.isOpen, isFalse);
    });

    test('server errors keep the connection usable', () async {
      server = await FakeRedisServer.start(
        (command, client) => switch (command.first) {
          'GET' => '-WRONGTYPE Operation against a key\r\n',
          _ => '+PONG\r\n',
        },
      );
      final connection = await connect();

      await expectLater(
        connection.get('a'),
        throwsA(
          isA<RedisServerException>().having(
            (e) => e.code,
            'code',
            'WRONGTYPE',
          ),
        ),
      );
      expect(await connection.ping(), equals('PONG'));
      await connection.close();
    });

    test('invalid arguments are rejected before anything is sent', () async {
      server = await FakeRedisServer.start(okHandler);
      final connection = await connect();

      await expectLater(
        connection.execute(['SET', 'a', true]),
        throwsArgumentError,
      );
      await expectLater(
        connection.execute(['SUBSCRIBE', 'channel']),
        throwsUnsupportedError,
      );
      await expectLater(
        connection.execute(['client', 'reply', 'off']),
        throwsUnsupportedError,
      );
      expect(await connection.ping(), equals('PONG'));
      expect(
        server.commands,
        equals([
          ['PING'],
        ]),
      );
      await connection.close();
    });

    test('authenticates and selects the database in one round trip', () async {
      server = await FakeRedisServer.start(okHandler);
      final connection = await connect(
        username: 'app',
        password: 'secret',
        database: 3,
        clientName: 'my-app',
      );

      expect(
        server.commands,
        equals([
          ['AUTH', 'app', 'secret'],
          ['CLIENT', 'SETNAME', 'my-app'],
          ['SELECT', '3'],
        ]),
      );
      expect(server.clients.single.chunks, equals(1));
      await connection.close();
    });

    test('authentication errors fail the connect', () async {
      server = await FakeRedisServer.start(
        (command, client) => switch (command.first) {
          'AUTH' => '-WRONGPASS invalid username-password pair\r\n',
          _ => '-NOAUTH Authentication required.\r\n',
        },
      );

      await expectLater(
        connect(password: 'wrong', database: 1),
        throwsA(
          isA<RedisServerException>().having(
            (e) => e.code,
            'code',
            'WRONGPASS',
          ),
        ),
      );
    });

    test('ignores CLIENT SETNAME errors', () async {
      server = await FakeRedisServer.start(
        (command, client) => switch (command.first) {
          'CLIENT' => '-ERR unknown command\r\n',
          _ => '+OK\r\n',
        },
      );

      final connection = await connect(clientName: 'proxy-test');
      expect(connection.isOpen, isTrue);
      await connection.close();
    });

    test('a TLS handshake with a silent server times out', () async {
      server = await FakeRedisServer.start((command, client) => null);
      final watch = Stopwatch()..start();

      await expectLater(
        RedisSocketConnection.connect(
          host: '127.0.0.1',
          port: server.port,
          useTls: true,
          connectTimeout: const Duration(milliseconds: 300),
        ),
        throwsA(isA<RedisConnectionException>()),
      );
      expect(watch.elapsed, lessThan(const Duration(seconds: 3)));
    });

    test('connection refused fails with a connection exception', () async {
      server = await FakeRedisServer.start(okHandler);
      final port = server.port;
      await server.close();

      await expectLater(
        RedisSocketConnection.connect(host: '127.0.0.1', port: port),
        throwsA(isA<RedisConnectionException>()),
      );
    });

    test('commands queued in a transaction fail without hanging', () async {
      server = await FakeRedisServer.start(
        (command, client) => switch (command.first) {
          'MULTI' => '+OK\r\n',
          'NOPE' => '-ERR unknown command \'NOPE\'\r\n',
          'EXEC' =>
            '-EXECABORT Transaction discarded because of previous errors.\r\n',
          _ => '+QUEUED\r\n',
        },
      );
      final connection = await connect();

      late Future<bool> set;
      late Future<RedisReply> invalid;
      await expectLater(
        connection.transaction((tx) {
          set = tx.set('a', '1');
          invalid = tx.execute(['NOPE']);
        }),
        throwsA(
          isA<RedisServerException>().having(
            (e) => e.code,
            'code',
            'EXECABORT',
          ),
        ),
      );

      await expectLater(
        set,
        throwsA(
          isA<RedisServerException>().having(
            (e) => e.code,
            'code',
            'EXECABORT',
          ),
        ),
      );
      await expectLater(
        invalid,
        throwsA(
          isA<RedisServerException>().having((e) => e.code, 'code', 'ERR'),
        ),
      );
      await connection.close();
    });
  });
}
