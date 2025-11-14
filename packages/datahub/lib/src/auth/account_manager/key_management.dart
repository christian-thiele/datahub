part of 'account_manager_service.dart';

class KeyPair {
  final String id;
  final RSAPublicKey publicKey;
  final RSAPrivateKey privateKey;
  final DateTime createdAt;
  final DateTime validUntil;

  const KeyPair({
    required this.id,
    required this.publicKey,
    required this.privateKey,
    required this.createdAt,
    required this.validUntil,
  });

  bool get isValid => validUntil.isAfter(DateTime.timestamp());
}

mixin KeyManagement on ServiceInstance<AccountManagerService> {
  final _activeTimers = <Timer>[];

  final keyPairs = <String, KeyPair>{};

  KeyPair get currentKeySet =>
      keyPairs.values.max((keySet) => keySet.createdAt.millisecondsSinceEpoch);

  @override
  Future<void> initialize() async {
    await super.initialize();

    if (read(service.keyRetentionPeriod) < read(service.keyRotationInterval)) {
      log.warn(
        'AccountManager keyRetentionPeriod is smaller than keyRotationInterval. Consider updating configuration values.',
      );
    }

    rotateKey();
    // TODO replace with internal scheduling
    _activeTimers.add(
      Timer.periodic(read(service.keyRotationInterval), (_) => rotateKey()),
    );
  }

  @override
  Future<void> dispose() async {
    for (final timer in _activeTimers.where((e) => e.isActive)) {
      timer.cancel();
    }
    _activeTimers.clear();
    await super.dispose();
  }

  void rotateKey() {
    // TODO share key-pairs across instances
    log.debug('Rotating AccountManager key pair');
    keyPairs[_nextKeyId()] = generateKeyPair();
    _activeTimers.add(Timer(read(service.keyRetentionPeriod), cleanKeySets));
  }

  void cleanKeySets() {
    log.debug('Cleaning up AccountManager key sets');
    keyPairs.removeWhere((k, v) => !v.isValid);
    _activeTimers.removeWhere((t) => !t.isActive);
  }

  KeyPair generateKeyPair() {
    final secureRandom = FortunaRandom()
      ..seed(
        KeyParameter(Platform.instance.platformEntropySource().getBytes(32)),
      );

    final keyGen = RSAKeyGenerator();
    keyGen.init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        secureRandom,
      ),
    );

    final keyPair = keyGen.generateKeyPair();
    return KeyPair(
      id: _nextKeyId(),
      publicKey: keyPair.publicKey,
      privateKey: keyPair.privateKey,
      createdAt: DateTime.timestamp(),
      validUntil: DateTime.timestamp().add(read(service.keyRetentionPeriod)),
    );
  }

  List<Jwk> getKeySet() {
    return [
      for (final keySet in keyPairs.values)
        Jwk(
          keyType: 'RSA',
          keyId: keySet.id,
          publicKeyUse: 'sig',
          algorithm: 'RS256',
          rsaExponent: base64UintEncode(
            keySet.publicKey.exponent ?? BigInt.zero,
          ),
          rsaModulus: base64UintEncode(keySet.publicKey.modulus ?? BigInt.zero),
        ),
    ];
  }

  String _nextKeyId() {
    final r = Random();
    while (true) {
      final keyId = Iterable.generate(
        8,
        (_) => r.nextInt(36).toRadixString(36),
      ).join();
      if (!keyPairs.containsKey(keyId)) {
        return keyId;
      }
    }
  }
}
