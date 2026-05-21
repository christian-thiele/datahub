import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:cryptography/cryptography.dart' as cryptography;

import 'api_exception.dart';

abstract class Argon2Id {
  const Argon2Id._();

  static Future<String> createEncodedHash(
    String password, {
    int p = 4,
    int m = 8192,
    int i = 3,
  }) async {
    final random = Random.secure();
    final algorithm = cryptography.Argon2id(
      parallelism: p,
      memory: m,
      iterations: i,
      hashLength: 32,
    );

    final salt = List.generate(8, (_) => random.nextInt(256)).asUint8List();
    final hash = await algorithm.deriveKey(
      secretKey: cryptography.SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    final newSecretKeyBytes = await hash.extractBytes();

    final phcParts = [
      'argon2id',
      'v=19',
      'm=${algorithm.memory},t=${algorithm.iterations},p=${algorithm.parallelism}',
      base64Encode(salt).replaceAll('=', ''),
      base64Encode(newSecretKeyBytes).replaceAll('=', ''),
    ];

    return '\$${phcParts.join('\$')}';
  }

  static Future<bool> verify(String password, String encodedHash) async {
    const prefix = '\$argon2id\$v=19\$';
    if (!encodedHash.startsWith(prefix)) {
      throw ApiException('Invalid argon2id hash: Invalid format.');
    }

    final parts = encodedHash.substring(prefix.length).split('\$');
    if (parts.length != 3) {
      throw ApiException('Invalid argon2id hash: Invalid format.');
    }

    final options = Map.fromEntries(
      parts.first.split(',').map((e) {
        final (key, value) = switch (e.split('=')) {
          [final String key, final String value]
              when int.tryParse(value) != null =>
            (key, int.parse(value)),
          _ => throw ApiException(
            'Invalid argon2id hash: Could not parse arguments.',
          ),
        };
        return MapEntry(key, value);
      }),
    );

    int findOption(String key) => switch (options[key]) {
      final int value => value,
      _ => throw ApiException(
        'Invalid argon2id hash: Missing or malformed argument "$key".',
      ),
    };

    final algorithm = cryptography.Argon2id(
      parallelism: findOption('p'),
      memory: findOption('m'),
      iterations: findOption('t'),
      hashLength: 32,
    );

    final Uint8List salt;
    try {
      salt = base64DecodeUnpadded(parts[1]);
    } catch (e) {
      throw ApiException('Invalid argon2id hash: Could not parse salt.');
    }

    final Uint8List hash;
    try {
      hash = base64DecodeUnpadded(parts[2]);
    } catch (e) {
      throw ApiException('Invalid argon2id hash: Could not parse hash.');
    }

    final result = await algorithm
        .deriveKey(
          secretKey: cryptography.SecretKey(utf8.encode(password)),
          nonce: salt,
        )
        .then((r) => r.extractBytes());

    return result.sequenceEquals(hash);
  }

  static Uint8List base64DecodeUnpadded(String base64) {
    final padded = base64 + ('=' * (-base64.length % 4));
    return base64Decode(padded);
  }
}
