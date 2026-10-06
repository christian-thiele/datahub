import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:boost/boost.dart';
import 'package:datahub/utils.dart';
import 'package:meta/meta.dart';

import '../logs/log_helper.dart';
import '../telemetry_internal.dart';

/// Buffers items and exports them to an OpenTelemetry collector in batches.
///
/// Every [exportInterval] (plus up to [exportIntervalJitter]), the items
/// buffered at that time are exported in batches of at most [maxBatchSize].
/// A batch that fails is put back and retried with the next interval. When
/// more than [maxBufferSize] items are buffered, the oldest are dropped.
/// Failures are logged once until exporting succeeds again, and only to
/// stdout (see [TelemetryInternal]).
abstract class OtlpBatchExporter<T> {
  /// Name of the signal for diagnostics, e.g. `traces`.
  final String signal;
  final Duration exportInterval;
  final Duration exportIntervalJitter;
  final Duration exportTimeout;
  final int maxBatchSize;
  final int maxBufferSize;

  final _buffer = ListQueue<T>();
  final _semaphore = Semaphore();
  Timer? _timer;
  bool _failing = false;
  bool _dropping = false;
  bool _stopped = false;

  OtlpBatchExporter({
    required this.signal,
    required this.exportInterval,
    required this.exportIntervalJitter,
    this.exportTimeout = const Duration(seconds: 30),
    this.maxBatchSize = 512,
    this.maxBufferSize = 100000,
  }) : assert(maxBatchSize > 0, 'maxBatchSize must be > 0'),
       assert(
         maxBufferSize >= maxBatchSize,
         'maxBufferSize must be >= maxBatchSize',
       ),
       assert(
         exportInterval > Duration.zero,
         'exportInterval must be > Duration.zero',
       );

  /// Number of buffered items.
  int get buffered => _buffer.length;

  /// Exports [batch], throws if it could not be exported.
  @protected
  Future<void> export(List<T> batch);

  /// The items of a failed [batch] that are put back into the buffer.
  @protected
  Iterable<T> retryable(List<T> batch) => batch;

  /// Starts exporting periodically.
  void start() => TelemetryInternal.run(_schedule);

  /// Adds [item] to the buffer.
  void enqueue(T item) {
    if (_stopped) {
      return;
    }

    _buffer.addLast(item);
    if (_buffer.length > maxBufferSize) {
      _buffer.removeFirst();
      if (!_dropping) {
        _dropping = true;
        TelemetryInternal.run(
          () => log.warn(
            'OpenTelemetry $signal buffer is full, dropping the oldest '
            'items until the collector catches up.',
          ),
        );
      }
    }
  }

  /// Exports all buffered items now. Returns false if a batch failed.
  Future<bool> flush() =>
      TelemetryInternal.run(() => _semaphore.runLocked(_exportBuffered));

  /// Stops exporting periodically and exports the remaining items, giving
  /// up after [timeout].
  Future<void> shutdown({Duration timeout = const Duration(seconds: 10)}) {
    _stopped = true;
    _timer?.cancel();
    return TelemetryInternal.run(() async {
      try {
        await flush().timeout(timeout);
      } on TimeoutException {
        log.warn(
          'Could not export ${_buffer.length} OpenTelemetry $signal items '
          'before shutdown.',
        );
      }
    });
  }

  void _schedule() {
    if (!_stopped) {
      _timer = Timer(exportInterval.jitter(exportIntervalJitter), _tick);
    }
  }

  Future<void> _tick() async {
    try {
      await _semaphore.throttle(_exportBuffered);
    } catch (e, stack) {
      log.error(
        'Unexpected error while exporting OpenTelemetry $signal.',
        error: e,
        stack: stack,
      );
    } finally {
      _schedule();
    }
  }

  /// Exports the items buffered when called, so a constant stream of new
  /// items does not keep it busy.
  Future<bool> _exportBuffered() async {
    var remaining = _buffer.length;
    while (remaining > 0 && _buffer.isNotEmpty) {
      final size = math.min(maxBatchSize, _buffer.length);
      final batch = [for (var i = 0; i < size; i++) _buffer.removeFirst()];
      remaining -= batch.length;

      try {
        await export(batch).timeout(exportTimeout);
      } catch (e, stack) {
        for (final item in retryable(batch).toList().reversed) {
          _buffer.addFirst(item);
        }
        while (_buffer.length > maxBufferSize) {
          _buffer.removeFirst();
        }

        if (!_failing) {
          _failing = true;
          log.warn(
            'Could not export OpenTelemetry $signal, retrying.',
            error: e,
            stack: stack,
          );
        }
        return false;
      }

      if (_failing) {
        _failing = false;
        log.info('Exporting OpenTelemetry $signal recovered.');
      }
      if (_dropping && _buffer.length < maxBufferSize) {
        _dropping = false;
      }
    }
    return true;
  }
}
