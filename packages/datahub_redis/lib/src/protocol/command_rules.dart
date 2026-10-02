/// Commands that switch a connection into a mode in which replies no longer
/// match commands one to one, or that end or reset the connection.
const _unsupportedCommands = {
  'SUBSCRIBE': 'Use Redis.subscribe() instead.',
  'PSUBSCRIBE': 'Use Redis.psubscribe() instead.',
  'SSUBSCRIBE': 'Sharded Pub/Sub is not supported.',
  'MONITOR': 'MONITOR blocks the connection.',
  'SYNC': 'Replication commands block the connection.',
  'PSYNC': 'Replication commands block the connection.',
  'HELLO': 'Only RESP2 is supported.',
  'RESET': 'RESET drops the authentication of the connection.',
  'QUIT': 'Connections are closed by the connection pool.',
};

/// Commands that control transactions, which are managed by
/// `transaction()` and cannot be queued inside one.
const _transactionCommands = {'MULTI', 'EXEC', 'DISCARD', 'WATCH', 'UNWATCH'};

/// Commands that change connection state in a way that cannot be reset
/// cheaply when they are queued in a transaction.
const _stateCommands = {'SELECT', 'AUTH', 'SWAPDB'};

/// The upper case command name of [command], or null if it is not a string.
String? commandName(List<Object> command) =>
    switch (command.isEmpty ? null : command.first) {
      final String name => name.toUpperCase(),
      _ => null,
    };

/// Throws an [UnsupportedError] if [command] would break the
/// request / reply matching of a connection.
void checkSupportedCommand(String? name, List<Object> command) {
  if (name == null) {
    return;
  }

  if (_unsupportedCommands[name] case final hint?) {
    throw UnsupportedError('Redis command $name is not supported. $hint');
  }

  if (name == 'CLIENT' && command.length > 1) {
    if (command[1] case final String subcommand
        when subcommand.toUpperCase() == 'REPLY') {
      throw UnsupportedError(
        'Redis command CLIENT REPLY is not supported. '
        'Replies are required to match commands.',
      );
    }
  }
}

/// Throws if [command] cannot be queued in a transaction.
void checkTransactionCommand(String? name, List<Object> command) {
  checkSupportedCommand(name, command);
  if (_transactionCommands.contains(name)) {
    throw UnsupportedError(
      'Redis command $name cannot be queued in a transaction.',
    );
  }
}

/// Whether [name] changes connection state when executed in a transaction.
bool changesConnectionState(String? name) => _stateCommands.contains(name);

/// Label values of [commandClass].
const commandClasses = ['read', 'write', 'script', 'other'];

const _readCommands = {
  'GET',
  'MGET',
  'EXISTS',
  'TTL',
  'PTTL',
  'TYPE',
  'STRLEN',
  'GETRANGE',
  'HGET',
  'HMGET',
  'HGETALL',
  'HEXISTS',
  'HKEYS',
  'HVALS',
  'HLEN',
  'LRANGE',
  'LLEN',
  'LINDEX',
  'SMEMBERS',
  'SISMEMBER',
  'SCARD',
  'SRANDMEMBER',
  'ZRANGE',
  'ZRANGEBYSCORE',
  'ZREVRANGE',
  'ZSCORE',
  'ZCARD',
  'ZRANK',
  'ZCOUNT',
  'KEYS',
  'SCAN',
  'HSCAN',
  'SSCAN',
  'ZSCAN',
  'DBSIZE',
  'PING',
  'INFO',
  'XRANGE',
  'XREVRANGE',
  'XLEN',
  'XREAD',
  'GETBIT',
  'BITCOUNT',
};

const _scriptCommands = {'EVAL', 'EVALSHA', 'FCALL', 'FCALL_RO', 'SCRIPT'};

const _otherCommands = {
  'MULTI',
  'EXEC',
  'DISCARD',
  'WATCH',
  'UNWATCH',
  'AUTH',
  'SELECT',
  'CLIENT',
  'CONFIG',
  'FLUSHDB',
  'FLUSHALL',
  'SAVE',
  'BGSAVE',
  'SWAPDB',
  'WAIT',
};

/// A low cardinality classification of [name] for use as metric label.
///
/// Anything that is not known to read or script is treated as write, unless
/// it is a known administrative command.
String commandClass(String? name) {
  if (name == null) {
    return 'other';
  }
  if (_readCommands.contains(name)) {
    return 'read';
  }
  if (_scriptCommands.contains(name)) {
    return 'script';
  }
  if (_otherCommands.contains(name)) {
    return 'other';
  }
  return 'write';
}
