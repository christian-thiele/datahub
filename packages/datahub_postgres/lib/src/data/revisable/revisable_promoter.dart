import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/services.dart';
import 'package:postgres/postgres.dart' as pg;

import 'revisable_statements.dart';

/// Applies scheduled revisions to the current state once they become due.
///
/// A timer is armed for the next due schedule entry (at most [pollInterval]
/// ahead). Scheduling a revision notifies the promoters of all instances via
/// `pg_notify`, so they re-arm immediately. Promotion runs in transactions of
/// its own and never waits for element locks, so it cannot deadlock with
/// writers; locked elements are retried shortly after.
class RevisablePromoter {
  static const _busyDelay = Duration(milliseconds: 250);
  static const _errorDelay = Duration(seconds: 5);
  static const _slack = Duration(milliseconds: 5);

  final Postgresql postgresql;
  final RevisableStatements statements;
  final Duration pollInterval;
  final int batchSize;

  /// Runs callbacks in the context of the owning service.
  final R Function<R>(R Function() body) runInContext;

  Timer? _timer;
  Future<void>? _running;
  StreamSubscription<String>? _subscription;
  var _rerun = false;
  var _disposed = false;

  RevisablePromoter({
    required this.postgresql,
    required this.statements,
    required this.pollInterval,
    required this.batchSize,
    required this.runInContext,
  });

  String get _key => statements.layout.key;

  /// Promotes due revisions and starts listening for scheduled revisions.
  Future<void> start() async {
    _subscription = postgresql
        .listen(RevisableStatements.notificationChannel)
        .where((payload) => payload.isEmpty || payload == _key)
        .listen((_) => wake());

    wake();
    await _running;
  }

  /// Runs a promotion round as soon as possible.
  void wake() {
    if (_disposed) {
      return;
    }

    if (_running != null) {
      _rerun = true;
      return;
    }

    _timer?.cancel();
    _timer = null;
    _running = _scheduledRound().whenComplete(() {
      _running = null;
      if (_rerun) {
        _rerun = false;
        wake();
      }
    });
  }

  /// Promotes all due revisions now and returns the number of elements
  /// whose current state changed.
  ///
  /// Uses separate transactions. Elements locked by other transactions are
  /// skipped.
  Future<int> promoteDue() async => (await _round()).promoted;

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    await _subscription?.cancel();
    await _running;
  }

  Future<void> _scheduledRound() async {
    Duration delay;
    try {
      delay = (await _round()).delay;
    } catch (e, stack) {
      log.error(
        'Could not promote scheduled revisions of "$_key".',
        error: e,
        stack: stack,
      );
      delay = _min(_errorDelay, pollInterval);
    }

    if (!_disposed) {
      _timer?.cancel();
      _timer = runInContext(() => Timer(delay, wake));
    }
  }

  Future<({int promoted, Duration delay})> _round() async {
    var promoted = 0;
    while (true) {
      var ids = const <Object>[];
      final _Batch batch;
      try {
        batch = await postgresql.runDetachedTransaction((db) async {
          final relationLock = await db.execute(
            statements.tryLockRelationShared(),
          );
          if (relationLock.first.first != true) {
            // bulk write in progress
            return const _Batch.busy();
          }

          ids = [
            for (final row in await db.execute(statements.dueIds(batchSize)))
              row.first as Object,
          ];

          final count = ids.isEmpty
              ? 0
              : (await db.execute(statements.promote(ids))).first.first as int;

          if (ids.length >= batchSize) {
            return _Batch(promoted: count, more: true);
          }

          final next = (await db.execute(statements.nextDue())).first;
          return _Batch(
            promoted: count,
            next: next[0] as DateTime?,
            now: next[1] as DateTime,
          );
        });
      } catch (e, stack) {
        if (ids.isEmpty) {
          rethrow;
        }

        log.warn(
          'Promoting ${ids.length} scheduled revisions of "$_key" failed. '
          'Retrying one by one.',
          error: e,
          stack: stack,
        );
        promoted += await _promoteOneByOne(ids);
        return (promoted: promoted, delay: _min(_busyDelay, pollInterval));
      }

      promoted += batch.promoted;
      if (batch.busy) {
        return (promoted: promoted, delay: _min(_busyDelay, pollInterval));
      }

      if (!batch.more) {
        return (promoted: promoted, delay: _delayUntil(batch.next, batch.now!));
      }
    }
  }

  /// Promotes elements in separate transactions, so one failing revision
  /// (e.g. violating a unique index) does not block others. Schedule entries
  /// failing permanently are marked and skipped until superseded by a later
  /// revision. Other errors (connection loss, deadlocks, ...) are rethrown,
  /// the entries are retried later.
  Future<int> _promoteOneByOne(List<Object> ids) async {
    var promoted = 0;
    for (final id in ids) {
      try {
        promoted += await postgresql.runDetachedTransaction((db) async {
          if (!await _tryLock(db, id)) {
            return 0;
          }

          return (await db.execute(statements.promote([id]))).first.first
              as int;
        });
      } on pg.ServerException catch (e, stack) {
        if (!_isPermanent(e)) {
          rethrow;
        }

        log.error(
          'Could not apply scheduled revision of "$_key" with id "$id". It is '
          'skipped until superseded by a later revision.',
          error: e,
          stack: stack,
        );

        try {
          await postgresql.runDetachedTransaction((db) async {
            if (await _tryLock(db, id)) {
              await db.execute(statements.markFailed(id, e.toString()));
            }
          });
        } catch (e, stack) {
          log.error(
            'Could not mark scheduled revision of "$_key" with id "$id" as '
            'failed.',
            error: e,
            stack: stack,
          );
        }
      }
    }
    return promoted;
  }

  /// Data exceptions (class 22) and integrity constraint violations
  /// (class 23) fail again on every attempt.
  static bool _isPermanent(pg.ServerException e) =>
      e.code?.startsWith('22') == true || e.code?.startsWith('23') == true;

  Future<bool> _tryLock(PostgresqlContext db, Object id) async {
    final relation = await db.execute(statements.tryLockRelationShared());
    if (relation.first.first != true) {
      return false;
    }

    final element = await db.execute(statements.tryLockElement(id));
    return element.first.first == true;
  }

  Duration _delayUntil(DateTime? next, DateTime now) {
    if (next == null) {
      return pollInterval;
    }

    final delay = next.difference(now);
    if (delay <= Duration.zero) {
      // due, but locked by a writer
      return _min(_busyDelay, pollInterval);
    }

    return _min(delay + _slack, pollInterval);
  }

  static Duration _min(Duration a, Duration b) => a < b ? a : b;
}

class _Batch {
  final int promoted;
  final bool busy;
  final bool more;
  final DateTime? next;
  final DateTime? now;

  const _Batch({required this.promoted, this.more = false, this.next, this.now})
    : busy = false;

  const _Batch.busy()
    : promoted = 0,
      busy = true,
      more = false,
      next = null,
      now = null;
}
