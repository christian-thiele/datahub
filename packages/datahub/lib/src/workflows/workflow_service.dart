import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:datahub/abstract.dart';
import 'package:datahub/config.dart';
import 'package:datahub/data.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

import 'retry_policy.dart';
import 'workflow.dart';
import 'workflow_description.dart';
import 'workflow_event.dart';
import 'workflow_history_entry.dart';
import 'workflow_signal.dart';
import 'workflow_step.dart';
import 'workflow_step_context.dart';

/// Runs the workflow of the element type [T], whose state is held by its field
/// of type [TState], and provides it as [Workflow].
///
/// ```dart
/// WorkflowService<Invoice, InvoiceState>(
///   steps: [
///     OnEnter(InvoiceState.created, generateInvoice),
///     OnEnter(InvoiceState.generated, requestPayment),
///     OnEnter(InvoiceState.paymentRequested, cancelInvoice,
///         after: Duration(days: 14)),
///     OnSignal($PaymentSignal.bean,
///         accept: [InvoiceState.paymentRequested],
///         target: (signal) => signal.invoiceId,
///         handle: markPaid),
///   ],
/// )
/// ```
///
/// Elements enter the workflow with [Workflow.start]. From then on, everything
/// that is to happen to an element is a [WorkflowEvent]: entering a state
/// (possibly delayed) and signals. The service handles the events that are due,
/// on any instance of the application.
///
/// ## Guarantees
///
/// - **One step at a time per element.** The element is locked with the
///   [lockProvider] while a step runs. This holds across instances as long as
///   they share the lock provider (a `MemoryLockService` is not shared).
/// - **Nothing is lost.** Events are stored before they are handled, and a
///   step that fails is retried according to its `RetryPolicy`.
/// - **At least once.** A step can run more than once for the same event (after
///   a failure or a crash). Use `StepContext.idempotencyKey` for calls that
///   must not be repeated.
/// - **No lost updates.** Only the fields a step changed are written, and only
///   if the element is still in the state the step started in.
///
/// ## Required components
///
/// - the [repository] of the elements
/// - an [eventRepository] (see [WorkflowEvent])
/// - a [lockProvider]
///
/// The history of the elements is written if a [historyRepository] is
/// available (see [WorkflowHistoryEntry]).
///
/// Every instance can start elements, send signals and read the history. Only
/// instances with [worker] enabled run steps, so steps can be kept away from
/// instances that serve requests, for example. While a step runs, its event
/// shows the worker, a heartbeat and what the step logged so far (see
/// [Workflow.events]).
///
/// Each step runs in a span that continues the trace of the code that caused
/// it (the request that sent a signal, or the step before). Metrics are
/// prefixed with [metricPrefix] and the element type, for example
/// `workflow_invoice_steps_total`. Spans and logs carry the attributes
/// `datahub.workflow.name`, `datahub.workflow.step`,
/// `datahub.workflow.element.id`, `datahub.workflow.event.id` and
/// `datahub.workflow.attempt`.
class WorkflowService<T extends DataObject, TState extends Enum>
    implements Service {
  final List<WorkflowStep<T, TState>> steps;

  /// The field that holds the state. When null, the only field of type
  /// [TState] of the element is used.
  final DataField<T, TState>? stateField;

  /// The session of the workflow engine, for the work it does on its own.
  ///
  /// What a caller asks for is done with the session of the caller, so the
  /// repositories decide whether it is allowed: [Workflow.start] creates the
  /// element, [Workflow.send] stores the signal, [Workflow.retry] and
  /// [Workflow.cancel] change the event.
  ///
  /// What the engine does internally uses this session: events, history, and
  /// running the steps. So a caller who may retry an event does not need the
  /// rights of its step.
  ///
  /// Without it, the engine works without a session, and the work done for
  /// a caller runs with the session of the caller.
  final Session? workerSession;

  /// The repository of the elements, defaults to the `DataRepository<T>`.
  final Find<DataRepository<T>>? repository;

  final Find<DataRepository<WorkflowEvent>> eventRepository;

  /// Lock provider for the elements. The lock of an element is named
  /// `workflow:<element type>:<element id>`.
  final Find<LockProvider<String>> lockProvider;

  /// Where the history is written. History is off if there is no such
  /// repository.
  final Find<DataRepository<WorkflowHistoryEntry>?> historyRepository;

  /// Time between two checks for due events.
  final Config<Duration> pollInterval;

  /// Number of events that are read from the repository at once.
  final Config<int> batchSize;

  /// Maximum number of elements this instance works on at the same time.
  final Config<int> concurrency;

  /// Whether this instance runs steps. Instances that are not workers only
  /// store events (when starting elements or sending signals).
  final Config<bool> worker;

  /// Identifies this instance in the events it handles. Defaults to
  /// `<host name>:<process id>`.
  final Config<String?> workerId;

  /// Interval in which a worker renews the heartbeat and the messages of the
  /// event it handles.
  final Config<Duration> heartbeatInterval;

  final Find<Telemetry> telemetry;
  final Config<bool> enableMetrics;
  final Config<bool> enableTracing;
  final Config<String> metricPrefix;

  const WorkflowService({
    required this.steps,
    this.stateField,
    this.repository,
    this.eventRepository = const Find(),
    this.lockProvider = const Find(),
    this.historyRepository = const Find(),
    this.pollInterval = const Config(
      'workflows.pollInterval',
      defaultValue: Duration(seconds: 5),
    ),
    this.batchSize = const Config('workflows.batchSize', defaultValue: 100),
    this.concurrency = const Config('workflows.concurrency', defaultValue: 4),
    this.worker = const Config('workflows.worker', defaultValue: true),
    this.workerId = const Config('workflows.workerId'),
    this.heartbeatInterval = const Config(
      'workflows.heartbeatInterval',
      defaultValue: Duration(seconds: 10),
    ),
    this.telemetry = const Find(),
    this.enableMetrics = const Config(
      'workflows.enableMetrics',
      defaultValue: true,
    ),
    this.enableTracing = const Config(
      'workflows.enableTracing',
      defaultValue: true,
    ),
    this.metricPrefix = const Config(
      'workflows.metricPrefix',
      defaultValue: 'workflow',
    ),
    this.workerSession,
  });

  /// Throws an [ApiError] when the steps are declared inconsistently.
  void validate(DataBean<T> bean) {
    final workflow = 'Workflow "${bean.name}"';
    if (steps.isEmpty) {
      throw ApiError('$workflow has no steps.');
    }

    final names = <String>{};
    final signals = <String>{};
    for (final step in steps) {
      final described = 'Step "${step.name}" of ${workflow.toLowerCase()}';
      if (!names.add(step.name)) {
        throw ApiError(
          '$workflow has multiple steps named "${step.name}". Give them '
          'different names.',
        );
      }

      if (step is OnEnter<T, TState>) {
        if (step.after.isNegative) {
          throw ApiError('$described has a negative delay.');
        }
        if (step.at != null && step.after != Duration.zero) {
          throw ApiError('$described has both a delay and a time (at).');
        }
        if (step.failureState == step.state) {
          throw ApiError('$described has its own state as failure state.');
        }
      } else if (step is OnSignal<T, TState, DataObject>) {
        if (!step.isSignalForElement) {
          throw ApiError(
            'The signal "${step.signalBean.name}" of step "${step.name}" is '
            'not a signal for ${bean.name}, so it could never be sent to this '
            'workflow. Let it implement WorkflowSignal<${bean.name}>.',
          );
        }
        if (!signals.add(step.signalBean.name)) {
          throw ApiError(
            '$workflow has multiple steps for signal '
            '"${step.signalBean.name}".',
          );
        }
        if (step.accept.isEmpty) {
          throw ApiError('$described does not accept its signal in any state.');
        }
        if (step.expireAfter <= Duration.zero) {
          throw ApiError('$described expires its signals immediately.');
        }
      }
    }
  }

  @override
  ServiceInstance<WorkflowService<T, TState>> createInstance() =>
      _WorkflowServiceInstance<T, TState>();
}

class _WorkflowServiceInstance<T extends DataObject, TState extends Enum>
    extends ServiceInstance<WorkflowService<T, TState>>
    implements Workflow<T> {
  late final DataRepository<T> _repository;
  late final DataRepository<WorkflowEvent> _events;
  late final LockProvider<String> _locks;
  late final DataRepository<WorkflowHistoryEntry>? _history;
  late final DataField<T, dynamic> _idField;
  late final DataField<T, TState> _stateField;

  /// Name of the element type, which identifies the workflow in events, locks
  /// and logs.
  late final String _name;

  late final Map<String, WorkflowStep<T, TState>> _steps;
  late final Map<TState, List<OnEnter<T, TState>>> _enterSteps;
  late final List<OnSignal<T, TState, DataObject>> _signalSteps;

  late final Duration _pollInterval;
  late final int _batchSize;
  late final int _concurrency;
  late final bool _worker;
  late final String _workerId;
  late final Duration _heartbeatInterval;
  late final Telemetry _telemetry;
  late final bool _tracing;
  late final _WorkflowMetrics? _metrics;

  /// The zone [initialize] ran in, background work is attributed to it.
  late final Zone _zone;

  Timer? _timer;
  Future<void>? _activeTick;
  bool _wakeRequested = false;
  bool _started = false;
  bool _disposed = false;

  @override
  Future<void> initialize() async {
    await super.initialize();
    _zone = Zone.current;

    _repository = find(service.repository ?? Find<DataRepository<T>>());
    _events = find(service.eventRepository);
    _locks = find(service.lockProvider);
    _history = find(service.historyRepository);
    _idField = _repository.bean.requireIdField;
    _stateField = service.stateField ?? _detectStateField();
    _name = _repository.bean.name;

    service.validate(_repository.bean);
    _steps = {for (final step in service.steps) step.name: step};
    _enterSteps = service.steps.whereType<OnEnter<T, TState>>().groupListsBy(
      (step) => step.state,
    );
    _signalSteps = service.steps
        .whereType<OnSignal<T, TState, DataObject>>()
        .toList();

    _pollInterval = read(service.pollInterval);
    _batchSize = math.max(1, read(service.batchSize));
    _concurrency = math.max(1, read(service.concurrency));
    _worker = read(service.worker);
    _workerId = read(service.workerId) ?? '${Platform.localHostname}:$pid';
    _heartbeatInterval = read(service.heartbeatInterval);

    _telemetry = find(service.telemetry);
    _tracing = read(service.enableTracing);
    _metrics = read(service.enableMetrics)
        ? _WorkflowMetrics(
            _telemetry,
            '${read(service.metricPrefix)}_'
            '${NamingConvention.lowerSnakeCase.convert(_name)}',
            steps: _steps.keys.toList(),
            signals: [for (final step in _signalSteps) step.name],
          )
        : null;

    if (_worker) {
      registry.registerPostInitializationCallback(() {
        _started = true;
        _schedule(Duration.zero);
      });
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    await _activeTick;
    await super.dispose();
  }

  DataField<T, TState> _detectStateField() {
    final candidates = _repository.bean.fields
        .whereType<DataField<T, TState>>()
        .toList();
    if (candidates.length != 1) {
      throw ApiError(
        'Workflow "${_repository.bean.name}" could not determine its state '
        'field: it has ${candidates.length} fields of type $TState. Set '
        'WorkflowService.stateField explicitly.',
      );
    }
    return candidates.single;
  }

  @override
  Future<T> start(T element) async {
    _ensureNotDisposed();

    // The element is read and created by the caller.
    final id = _idField.valueOf(element);
    if (await _repository.readById(id) case final stored?) {
      return await _runAsWorker(() => _startAgain(stored, element));
    }

    final T created;
    try {
      created = await _repository.create(element);
    } catch (_) {
      // Another start of the same element may have been faster.
      final stored = await _repository.readById(id);
      if (stored == null) {
        rethrow;
      }
      return await _runAsWorker(() => _startAgain(stored, element));
    }

    await _runAsWorker(() => _begin(created, WorkflowHistoryKind.started));
    return created;
  }

  /// Handles the start of an element that is stored already: it is only
  /// started if its first start was interrupted, see [Workflow.start].
  Future<T> _startAgain(T stored, T requested) async {
    final state = _stateOf(stored);
    if (state == _stateOf(requested) &&
        (_enterSteps[state]?.isNotEmpty ?? false)) {
      final events = await _events.readAll(
        filter: Filter.andGroup([
          $WorkflowEvent.$workflow.equals(_name),
          $WorkflowEvent.$elementId.equals(_idOf(stored).toString()),
        ]),
        limit: 1,
      );
      if (events.isEmpty) {
        await _begin(stored, WorkflowHistoryKind.started);
      }
    }
    return stored;
  }

  @override
  Future<void> resume(Object id) async {
    _ensureNotDisposed();
    final element =
        await _repository.readById(id) ??
        (throw ApiRequestException.notFound('Element $id does not exist.'));
    await _runAsWorker(() async {
      await _cancelEntered(_idOf(element));
      await _begin(element, WorkflowHistoryKind.resumed);
    });
  }

  /// Cancels the pending events of all [OnEnter] steps of the element, except
  /// running ones.
  ///
  /// Resuming replaces them: the steps of a state the element left (outside of
  /// the workflow) do not wait until they are dropped, and the steps of the
  /// current state do not run twice.
  Future<void> _cancelEntered(Object id) async {
    final names = [
      for (final step in _enterSteps.values.expand((steps) => steps)) step.name,
    ];
    if (names.isEmpty) {
      return;
    }

    final pending = await _events.readAll(
      filter: Filter.andGroup([
        $WorkflowEvent.$workflow.equals(_name),
        $WorkflowEvent.$elementId.equals(id.toString()),
        $WorkflowEvent.$step.isIn(names),
        $WorkflowEvent.$status.equals(WorkflowEventStatus.pending),
      ]),
    );
    for (final event in pending.where((event) => !_isRunning(event))) {
      await _events.deleteById(event.id);
      final step = _steps[event.step];
      await _record(
        WorkflowHistoryKind.cancelled,
        id,
        step: step,
        event: event,
        state: step is OnEnter<T, TState> ? step.state : null,
      );
    }
  }

  /// Lets [element] enter its current state.
  Future<void> _begin(T element, WorkflowHistoryKind kind) async {
    final at = DateTime.timestamp();
    await _enter(element, _stateOf(element));
    await _record(kind, _idOf(element), at: at, state: _stateOf(element));
    _wake();
  }

  @override
  Future<void> send(WorkflowSignal<T> signal) async {
    _ensureNotDisposed();
    final step = _signalSteps.firstWhereOrNull((step) => step.accepts(signal));
    if (step == null) {
      log.warn(
        'Workflow "$_name" has no step for signal ${signal.runtimeType}, '
        'dropping it.',
        labels: _labels(),
      );
      return;
    }

    final now = DateTime.timestamp();
    final event = await _events.create(
      WorkflowEvent(
        workflow: _name,
        elementId: step.targetOf(signal).toString(),
        step: step.name,
        payload: step.encode(signal),
        createdAt: now,
        dueAt: now,
        expiresAt: now.add(step.expireAfter),
        traceId: _currentSpan?.traceId.hexId,
        spanId: _currentSpan?.spanId.hexId,
      ),
    );
    _metrics?.signals.inc({'signal': step.name});
    log.debug(
      'Workflow signal stored.',
      labels: _labels(step: step, id: event.elementId, event: event.id),
    );
    await _record(
      WorkflowHistoryKind.signalReceived,
      event.elementId,
      at: now,
      step: step,
      event: event,
      signal: event.payload,
    );
    _wake();
  }

  @override
  Future<List<WorkflowHistoryEntry>> history(
    Object id, {
    int offset = 0,
    int limit = 100,
    bool newestFirst = false,
  }) async {
    final history =
        _history ??
        (throw ApiException(
          'The history of workflow "$_name" is not written, there is no '
          'DataRepository<WorkflowHistoryEntry>.',
        ));
    return await history.readAll(
      filter: Filter.andGroup([
        $WorkflowHistoryEntry.$workflow.equals(_name),
        $WorkflowHistoryEntry.$elementId.equals(id.toString()),
      ]),
      sort: $WorkflowHistoryEntry.$timestamp.sort(!newestFirst),
      offset: offset,
      limit: limit,
    );
  }

  @override
  WorkflowDescription describe() => WorkflowDescription(
    name: _name,
    stateField: _stateField.name,
    writesHistory: _history != null,
    steps: [
      for (final step in service.steps)
        if (step is OnEnter<T, TState>)
          WorkflowStepDescription(
            name: step.name,
            kind: WorkflowStepKind.enter,
            state: step.state.name,
            after: step.after,
            scheduled: step.at != null,
            failureState: step.failureState?.name,
          )
        else if (step is OnSignal<T, TState, DataObject>)
          WorkflowStepDescription(
            name: step.name,
            kind: WorkflowStepKind.signal,
            accept: [for (final state in step.accept) state.name],
            signalBean: step.signalBean,
            failureState: step.failureState?.name,
          ),
    ],
    states: {
      for (final step in service.steps) ...[
        if (step is OnEnter<T, TState>) step.state.name,
        if (step is OnSignal<T, TState, DataObject>)
          for (final state in step.accept) state.name,
        if (step.failureState case final failureState?) failureState.name,
      ],
    }.toList(),
  );

  @override
  Future<List<WorkflowEvent>> events({
    Object? elementId,
    WorkflowEventStatus? status,
    int offset = 0,
    int limit = 100,
  }) async {
    return await _events.readAll(
      filter: Filter.andGroup([
        $WorkflowEvent.$workflow.equals(_name),
        if (elementId != null)
          $WorkflowEvent.$elementId.equals(elementId.toString()),
        if (status != null) $WorkflowEvent.$status.equals(status),
      ]),
      sort: $WorkflowEvent.$createdAt.asc(),
      offset: offset,
      limit: limit,
    );
  }

  @override
  Future<void> retry(String eventId) async {
    _ensureNotDisposed();
    final event = await _event(eventId);
    if (event.status == WorkflowEventStatus.pending) {
      throw ApiRequestException(409, 'The workflow event is not parked.');
    }

    final step = _steps[event.step];
    final now = DateTime.timestamp();
    await _events.updateById(
      event.copyWith(
        status: WorkflowEventStatus.pending,
        attempts: 0,
        dueAt: now,
        expiresAt: step is OnSignal<T, TState, DataObject>
            ? now.add(step.expireAfter)
            : event.expiresAt,
        nullLastError: true,
        nullStartedAt: true,
        nullHeartbeatAt: true,
        nullWorker: true,
        messages: const [],
      ),
    );
    await _record(
      WorkflowHistoryKind.retried,
      event.elementId,
      step: step,
      event: event,
    );
    _wake();
  }

  @override
  Future<void> cancel(String eventId) async {
    _ensureNotDisposed();
    final event = await _event(eventId);
    if (_isRunning(event)) {
      throw ApiRequestException(409, 'The workflow event is being handled.');
    }

    await _events.deleteById(event.id);
    await _record(
      WorkflowHistoryKind.cancelled,
      event.elementId,
      step: _steps[event.step],
      event: event,
    );
  }

  @override
  bool isRunning(WorkflowEvent event) => _isRunning(event);

  @override
  Future<void> sendJson(
    String signal,
    Map<String, dynamic> payload, {
    Object? elementId,
  }) async {
    final step =
        _signalSteps.firstWhereOrNull(
          (step) => step.signalBean.name == signal,
        ) ??
        (throw ApiRequestException.notFound(
          'Workflow "$_name" has no step for signal "$signal".',
        ));

    final DataObject decoded;
    try {
      decoded = step.signalBean.fromJson(payload);
    } on CodecException catch (error) {
      throw ApiRequestException(
        400,
        'Invalid signal: ${error.message}',
        data: {
          if (error.name case final name?)
            'fields': {
              name: [error.message],
            },
        },
      );
    }
    step.signalBean.validateConstraints(decoded);

    if (elementId != null &&
        step.targetOf(decoded).toString() != elementId.toString()) {
      throw ApiRequestException.badRequest(
        'The signal is meant for element ${step.targetOf(decoded)}, '
        'not for $elementId.',
      );
    }
    await send(decoded as WorkflowSignal<T>);
  }

  /// The event [id] of this workflow.
  Future<WorkflowEvent> _event(String id) async {
    final event = await _events.readById(id);
    if (event == null || event.workflow != _name) {
      throw ApiRequestException.notFound('Workflow event $id does not exist.');
    }
    return event;
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw ApiException('The workflow service is shut down.');
    }
  }

  /// Stores the events of the steps that run when [element] enters [state].
  Future<List<WorkflowEvent>> _enter(T element, TState state) async {
    final now = DateTime.timestamp();
    final id = _idOf(element).toString();
    return [
      for (final step in _enterSteps[state] ?? <OnEnter<T, TState>>[])
        await _events.create(
          WorkflowEvent(
            workflow: _name,
            elementId: id,
            step: step.name,
            createdAt: now,
            dueAt: step.dueAt(element, now),
            traceId: _currentSpan?.traceId.hexId,
            spanId: _currentSpan?.spanId.hexId,
          ),
        ),
    ];
  }

  void _wake() {
    if (!_started || _disposed) {
      return;
    }

    if (_activeTick != null) {
      _wakeRequested = true;
    } else {
      _schedule(Duration.zero);
    }
  }

  void _schedule(Duration delay) {
    if (_disposed) {
      return;
    }

    _timer?.cancel();
    _timer = _zone.createTimer(delay, () {
      _activeTick = _runAsWorker(
        _runTick,
      ).whenComplete(() => _activeTick = null);
    });
  }

  Future<void> _runTick() async {
    final startedAt = DateTime.timestamp();
    var progressed = false;
    try {
      progressed = await _processEvents();
    } catch (error, stack) {
      log.error(
        'Workflow update failed.',
        error: error,
        stack: stack,
        labels: _labels(),
      );
    }

    if (_disposed) {
      return;
    }

    // A step that ran might have made other events due, so go on without
    // waiting as long as there is progress.
    var delay = progressed || _wakeRequested
        ? Duration.zero
        : await _idleDelay(startedAt);
    if (_wakeRequested) {
      delay = Duration.zero;
    }
    _wakeRequested = false;
    _schedule(delay);
  }

  /// The time until the next poll: the poll interval, or less if an event is
  /// due earlier.
  ///
  /// Events that became due while the poll that [since] started ran were not
  /// handled by it, so they count as well (and make the next poll start right
  /// away). Events that were due before were handled or wait for something.
  Future<Duration> _idleDelay(DateTime since) async {
    final poll = _pollInterval.jitter(_pollInterval ~/ 10);
    try {
      final now = DateTime.timestamp();
      final next = await _events.readAll(
        filter: Filter.andGroup([
          $WorkflowEvent.$workflow.equals(_name),
          $WorkflowEvent.$status.equals(WorkflowEventStatus.pending),
          $WorkflowEvent.$dueAt.greaterThan(since),
        ]),
        sort: $WorkflowEvent.$dueAt.asc(),
        limit: 1,
      );
      if (next.firstOrNull?.dueAt.difference(now) case final untilDue?
          when untilDue < poll) {
        return untilDue.isNegative ? Duration.zero : untilDue;
      }
    } catch (error, stack) {
      log.warn(
        'Could not find the next due workflow event.',
        error: error,
        stack: stack,
        labels: _labels(),
      );
    }
    return poll;
  }

  /// Handles the due events. Returns true if at least one step ran.
  Future<bool> _processEvents() async {
    var progressed = false;
    final seen = <String>{};
    DateTime? cursor;

    while (!_disposed) {
      // Signals that wait for their element stay due, so pages are walked by
      // due time and the events of earlier pages are skipped.
      final page = await _events.readAll(
        filter: Filter.andGroup([
          $WorkflowEvent.$workflow.equals(_name),
          $WorkflowEvent.$status.equals(WorkflowEventStatus.pending),
          $WorkflowEvent.$dueAt.lessOrEqual(DateTime.timestamp()),
          if (cursor != null) $WorkflowEvent.$dueAt.greaterOrEqual(cursor),
        ]),
        sort: $WorkflowEvent.$dueAt.asc(),
        limit: _batchSize,
      );

      final fresh = [
        for (final event in page)
          if (seen.add(event.id)) event,
      ];
      if (fresh.isEmpty) {
        break;
      }
      cursor = page.last.dueAt;

      final byElement = fresh.groupListsBy((event) => event.elementId);
      final results = await _runConcurrently([
        for (final MapEntry(key: elementId, value: events) in byElement.entries)
          () => _processElement(elementId, events),
      ]);
      progressed = results.contains(true) || progressed;

      if (page.length < _batchSize) {
        break;
      }
    }

    _metrics?.due.set(seen.length);
    return progressed;
  }

  Future<List<bool>> _runConcurrently(
    List<Future<bool> Function()> jobs,
  ) async {
    final results = List.filled(jobs.length, false);
    var next = 0;

    Future<void> worker() async {
      while (next < jobs.length) {
        final index = next++;
        results[index] = await jobs[index]();
      }
    }

    await Future.wait([
      for (var i = 0; i < math.min(_concurrency, jobs.length); i++) worker(),
    ]);
    return results;
  }

  /// Handles the [events] of one element in order, while holding its lock.
  Future<bool> _processElement(
    String elementId,
    List<WorkflowEvent> events,
  ) async {
    final handle = await _locks.tryAcquireLock(_lockKey(elementId));
    if (handle == null) {
      // Busy, the events stay due.
      return false;
    }

    var progressed = false;
    try {
      for (final event in events) {
        if (_disposed) {
          break;
        }
        try {
          progressed = await _processEvent(event, handle) || progressed;
        } catch (error, stack) {
          log.error(
            'Workflow event could not be handled.',
            error: error,
            stack: stack,
            labels: _labels(id: elementId, event: event.id),
          );
        }
      }
    } finally {
      await _release(handle, elementId);
    }
    return progressed;
  }

  /// Returns true if a step ran.
  Future<bool> _processEvent(WorkflowEvent event, LockHandle handle) async {
    final step = _steps[event.step];
    if (step == null) {
      await _park(
        event,
        WorkflowEventStatus.failed,
        'The workflow has no step "${event.step}".',
      );
      return false;
    }

    // Another instance may have handled the event in the meantime.
    final current = await _events.readById(event.id);
    if (current == null || current.status != WorkflowEventStatus.pending) {
      return false;
    }

    final element = await _repository.readById(current.elementId);
    final state = element == null ? null : _stateOf(element);

    if (step is OnEnter<T, TState> && state != step.state) {
      // The element left the state (or is gone), nothing to do anymore.
      await _delete(current);
      return false;
    }

    if (step is OnSignal<T, TState, DataObject>) {
      if (current.expiresAt case final expiresAt?
          when !DateTime.timestamp().isBefore(expiresAt)) {
        await _park(
          current,
          WorkflowEventStatus.expired,
          'The signal was not applied within ${step.expireAfter}.',
        );
        return false;
      }
      if (element == null || !step.accept.contains(state)) {
        // Wait for the element to get there.
        return false;
      }
    }

    return await _run(step, current, element!, state!, handle);
  }

  /// Runs [step] for [element] and handles its result. Returns true if the
  /// step succeeded.
  Future<bool> _run(
    WorkflowStep<T, TState> step,
    WorkflowEvent event,
    T element,
    TState state,
    LockHandle handle,
  ) async {
    final metrics = _metrics;
    final stepLabels = {'step': step.name};
    final delay = DateTime.timestamp().difference(event.dueAt);
    metrics?.delay.observeDuration(
      delay.isNegative ? Duration.zero : delay,
      stepLabels,
    );

    final stopwatch = Stopwatch()..start();
    Future<bool> run(LocalSpan? span) async {
      final succeeded = await _runStep(
        step,
        event,
        element,
        state,
        handle,
        span,
      );
      metrics?.duration.observeDuration(stopwatch.elapsed, stepLabels);
      metrics?.steps.inc({
        ...stepLabels,
        'outcome': succeeded ? 'succeeded' : 'failed',
      });
      return succeeded;
    }

    if (!_tracing) {
      return await run(null);
    }

    // Continue the trace of the code that created the event.
    return await _telemetry.trace(
      'Workflow step ${step.name}',
      type: SpanType.consumer,
      parent: _spanOf(event),
      attributes: {
        'datahub.workflow.name': _name,
        'datahub.workflow.step': step.name,
        'datahub.workflow.element.id': event.elementId,
        'datahub.workflow.event.id': event.id,
        'datahub.workflow.attempt': event.attempts + 1,
      },
      run,
    );
  }

  Future<bool> _runStep(
    WorkflowStep<T, TState> step,
    WorkflowEvent event,
    T element,
    TState state,
    LockHandle handle,
    LocalSpan? span,
  ) async {
    final id = _idOf(element);
    final attempt = event.attempts + 1;
    final labels = _labels(
      step: step,
      id: id,
      attempt: attempt,
      event: event.id,
    );
    log.debug('Running workflow step.', labels: labels);

    final messages = <String>[];
    final stopHeartbeat = await _markRunning(event, messages);
    final TState newState;
    final Map<DataField<T, dynamic>, dynamic> changes;
    try {
      try {
        final result = await _captureLog(
          messages,
          () => _invoke(
            step,
            event,
            element,
            attempt,
            handle,
          ).timeout(step.timeout),
        );
        newState = _stateOf(result);
        changes = _changes(element, result);
        await _apply(
          element,
          state,
          newState,
          changes,
          handle,
          except: event.id,
          next: result,
        );
      } finally {
        stopHeartbeat();
      }
    } catch (error, stack) {
      span?.recordException(error, stack: stack);
      log.error(
        'Workflow step failed.',
        error: error,
        stack: stack,
        labels: labels,
      );
      await _fail(step, event, element, state, error, handle, messages);
      return false;
    }

    await _record(
      WorkflowHistoryKind.stepSucceeded,
      id,
      step: step,
      event: event,
      attempt: attempt,
      state: state,
      newState: newState,
      changes: changes,
      messages: messages,
    );
    await _delete(event);
    log.debug(
      'Workflow step finished.',
      labels: {...labels, 'datahub.workflow.state': newState.name},
    );
    return true;
  }

  Future<T> _invoke(
    WorkflowStep<T, TState> step,
    WorkflowEvent event,
    T element,
    int attempt,
    LockHandle handle,
  ) {
    if (step is OnSignal<T, TState, DataObject>) {
      return step.run(
        event.payload ?? const {},
        element: element,
        attempt: attempt,
        idempotencyKey: event.id,
        lockExpired: handle.expired,
        workflow: this,
      );
    } else if (step is OnEnter<T, TState>) {
      return step.handle(
        StepContext<T>(
          element: element,
          attempt: attempt,
          idempotencyKey: event.id,
          lockExpired: handle.expired,
          workflow: this,
        ),
      );
    }
    throw StateError('Unknown step type ${step.runtimeType}.');
  }

  /// Handles a failed attempt of [step], with the rules of its [RetryPolicy]:
  /// retry later, move the element to the failure state or give up.
  Future<void> _fail(
    WorkflowStep<T, TState> step,
    WorkflowEvent event,
    T element,
    TState state,
    Object error,
    LockHandle handle,
    List<String> messages,
  ) async {
    final attempts = event.attempts + 1;
    final labels = _labels(
      step: step,
      id: _idOf(element),
      attempt: attempts,
      event: event.id,
    );
    if (!handle.isValid) {
      // Somebody else may have taken over, leave the bookkeeping to them.
      log.warn('Lost the lock of the element, not recording the failure.');
      return;
    }

    final lastError = _truncate(error.toString());
    Future<void> record({DateTime? nextAttemptAt, TState? newState}) => _record(
      WorkflowHistoryKind.stepFailed,
      _idOf(element),
      step: step,
      event: event,
      attempt: attempts,
      state: state,
      newState: newState,
      error: lastError,
      nextAttemptAt: nextAttemptAt,
      messages: messages,
    );

    try {
      if (step.retry.allowsRetryAfter(attempts)) {
        final delay = step.retry.delayAfter(attempts);
        final nextAttemptAt = DateTime.timestamp().add(delay);
        await _events.updateById(
          event.copyWith(
            attempts: attempts,
            dueAt: nextAttemptAt,
            lastError: lastError,
            nullStartedAt: true,
            nullHeartbeatAt: true,
            nullWorker: true,
            messages: const [],
          ),
        );
        await record(nextAttemptAt: nextAttemptAt);
        log.info(
          'Retrying workflow step in ${delay.inMilliseconds}ms.',
          labels: labels,
        );
      } else if (step.failureState case final failureState?) {
        await _apply(
          element,
          state,
          failureState,
          {_stateField: failureState},
          handle,
          except: event.id,
        );
        await record(newState: failureState);
        await _delete(event);
        log.error(
          'Workflow step failed ${step.retry.maxAttempts} times, moved the '
          'element to state ${failureState.name}.',
          labels: labels,
        );
      } else {
        await record();
        await _park(
          event,
          WorkflowEventStatus.failed,
          lastError,
          attempts: attempts,
        );
      }
    } catch (e, s) {
      log.error(
        'Could not record the failure of a workflow step.',
        error: e,
        stack: s,
        labels: labels,
      );
    }
  }

  /// The fields that [result] changed compared to [original].
  Map<DataField<T, dynamic>, dynamic> _changes(T original, T result) {
    if (_idOf(result) != _idOf(original)) {
      throw ApiError('A workflow step must not change the id of the element.');
    }
    return _repository.bean.diff(original, result);
  }

  /// Writes [changes] to [element], which is in state [from], and moves it to
  /// state [to].
  ///
  /// Only the changed fields are written, and only if the element is still in
  /// [from]. The events of the new state are stored before the write, so that
  /// a crash can not lose them (if the write does not happen, they do not
  /// match the element and are dropped). The pending events of the old state
  /// are cancelled after the write.
  Future<void> _apply(
    T element,
    TState from,
    TState to,
    Map<DataField<T, dynamic>, dynamic> changes,
    LockHandle handle, {
    String? except,
    T? next,
  }) async {
    if (!handle.isValid) {
      throw ApiException('The lock of the element expired, result discarded.');
    }

    final id = _idOf(element);
    // The steps of the new state see the element as the step left it (for
    // `OnEnter.at`), or as it was when it is moved to the failure state.
    final ahead = to == from
        ? const <WorkflowEvent>[]
        : await _enter(next ?? element, to);
    try {
      if (changes.isNotEmpty) {
        final affected = await _repository.updateAll(
          filter: Filter.andGroup([
            _idField.equals(id),
            _stateField.equals(from),
          ]),
          values: changes,
        );
        if (affected == 0) {
          throw ApiException(
            'The element was changed or removed in the meantime, result '
            'discarded.',
          );
        }
      }
    } catch (_) {
      for (final event in ahead) {
        await _delete(event);
      }
      rethrow;
    }

    if (to != from) {
      await _cancel(id, from, except: except);
    }
  }

  /// Cancels the pending events of the steps of [state] for the element,
  /// except the event [except] that is being handled.
  Future<void> _cancel(Object id, TState state, {String? except}) async {
    final names = [
      for (final step in _enterSteps[state] ?? <OnEnter<T, TState>>[])
        step.name,
    ];
    if (names.isEmpty) {
      return;
    }

    try {
      final pending = await _events.readAll(
        filter: Filter.andGroup([
          $WorkflowEvent.$workflow.equals(_name),
          $WorkflowEvent.$elementId.equals(id.toString()),
          $WorkflowEvent.$step.isIn(names),
          $WorkflowEvent.$status.equals(WorkflowEventStatus.pending),
          if (except != null) $WorkflowEvent.$id.notEquals(except),
        ]),
      );
      if (pending.isEmpty) {
        return;
      }

      await _events.deleteAll(
        filter: $WorkflowEvent.$id.isIn([for (final e in pending) e.id]),
      );
      for (final event in pending) {
        await _record(
          WorkflowHistoryKind.cancelled,
          id,
          step: _steps[event.step],
          event: event,
          state: state,
        );
      }
    } catch (error, stack) {
      // They do not match the element anymore and are dropped when due.
      log.warn(
        'Could not cancel the events of the previous state.',
        error: error,
        stack: stack,
        labels: _labels(id: id),
      );
    }
  }

  Future<void> _delete(WorkflowEvent event) async {
    try {
      await _events.deleteById(event.id);
    } catch (error, stack) {
      log.error(
        'Could not remove a handled workflow event, it may be handled again.',
        error: error,
        stack: stack,
        labels: _labels(id: event.elementId, event: event.id),
      );
    }
  }

  /// Gives up on an event. It is kept so that it can be inspected.
  Future<void> _park(
    WorkflowEvent event,
    WorkflowEventStatus status,
    String reason, {
    int? attempts,
  }) async {
    log.error(
      'Workflow event ${status.name}: $reason It is not handled anymore, '
      'its record "${event.id}" was kept.',
      labels: _labels(id: event.elementId, event: event.id),
    );
    _metrics?.parked.inc({'status': status.name});
    await _record(
      WorkflowHistoryKind.parked,
      event.elementId,
      step: _steps[event.step],
      event: event,
      error: _truncate(reason),
    );

    try {
      await _events.updateById(
        event.copyWith(
          status: status,
          attempts: attempts ?? event.attempts,
          lastError: _truncate(reason),
          nullStartedAt: true,
          nullHeartbeatAt: true,
          nullWorker: true,
        ),
      );
    } catch (error, stack) {
      log.error(
        'Could not park a workflow event.',
        error: error,
        stack: stack,
        labels: _labels(id: event.elementId, event: event.id),
      );
    }
  }

  Future<void> _release(LockHandle handle, Object id) async {
    try {
      await handle.release();
    } catch (error, stack) {
      log.error(
        'Could not release lock.',
        error: error,
        stack: stack,
        labels: _labels(id: id),
      );
    }
  }

  /// Writes a history entry, if the history is on. Never throws: the history
  /// must not get in the way of the workflow.
  Future<void> _record(
    WorkflowHistoryKind kind,
    Object id, {
    DateTime? at,
    WorkflowStep<T, TState>? step,
    WorkflowEvent? event,
    int? attempt,
    TState? state,
    TState? newState,
    Map<DataField<T, dynamic>, dynamic>? changes,
    Map<String, dynamic>? signal,
    String? error,
    DateTime? nextAttemptAt,
    List<String> messages = const [],
  }) async {
    final history = _history;
    if (history == null) {
      return;
    }

    try {
      // The history is the bookkeeping of the engine, also for callers.
      await _runAsWorker(
        () => history.create(
          WorkflowHistoryEntry(
            workflow: _name,
            elementId: id.toString(),
            timestamp: at ?? DateTime.timestamp(),
            kind: kind,
            step: step?.name ?? event?.step,
            eventId: event?.id,
            attempt: attempt,
            state: state?.name,
            newState: newState?.name,
            changes: changes == null
                ? null
                : {
                    for (final MapEntry(key: field, :value) in changes.entries)
                      field.name: field.toJson(value),
                  },
            signal: signal,
            error: error,
            nextAttemptAt: nextAttemptAt,
            messages: messages,
          ),
        ),
      );
    } catch (e, stack) {
      log.warn(
        'Could not write the workflow history.',
        error: e,
        stack: stack,
        labels: _labels(id: id, event: event?.id),
      );
    }
  }

  /// Runs [body] and adds what it logs to [messages] (the last
  /// [_maxMessages] lines).
  Future<R> _captureLog<R>(List<String> messages, Future<R> Function() body) {
    return LogListener(
      onPublish: (message) {
        if (message.level.severityNumber > SeverityLevel.trace.severityNumber) {
          if (messages.length >= _maxMessages) {
            messages.removeAt(0);
          }
          messages.add(message.toJsonLine());
        }
      },
    ).run(body);
  }

  static const _maxMessages = 1000;

  /// Marks [event] as being handled by this worker, and keeps its heartbeat and
  /// [messages] up to date until the returned function is called.
  Future<void Function()> _markRunning(
    WorkflowEvent event,
    List<String> messages,
  ) async {
    final startedAt = DateTime.timestamp();
    await _updateEvent(event, {
      $WorkflowEvent.$startedAt: startedAt,
      $WorkflowEvent.$heartbeatAt: startedAt,
      $WorkflowEvent.$worker: _workerId,
      $WorkflowEvent.$messages: <String>[],
    });

    var writing = false;
    final timer = _zone.createPeriodicTimer(_heartbeatInterval, (_) async {
      if (writing) {
        return;
      }
      writing = true;
      try {
        // Timers of the zone of the service do not run in the session of the
        // step.
        await _runAsWorker(
          () => _updateEvent(event, {
            $WorkflowEvent.$heartbeatAt: DateTime.timestamp(),
            $WorkflowEvent.$messages: List.of(messages),
          }),
        );
      } finally {
        writing = false;
      }
    });
    return timer.cancel;
  }

  /// Writes some fields of [event], without overwriting the others.
  Future<void> _updateEvent(
    WorkflowEvent event,
    Map<DataField<WorkflowEvent, dynamic>, dynamic> values,
  ) async {
    try {
      await _events.updateAll(
        filter: $WorkflowEvent.$id.equals(event.id),
        values: values,
      );
    } catch (error, stack) {
      log.warn(
        'Could not update a running workflow event.',
        error: error,
        stack: stack,
        labels: _labels(id: event.elementId, event: event.id),
      );
    }
  }

  /// Runs [body] as the engine, with [WorkflowService.workerSession] as the
  /// only session (unless it runs as the engine already).
  Future<R> _runAsWorker<R>(Future<R> Function() body) =>
      switch (service.workerSession) {
        final session? when Zone.current[#datahub.workflow.worker] != this =>
          context.withSession(
            session,
            () => runZoned(body, zoneValues: {#datahub.workflow.worker: this}),
          ),
        _ => body(),
      };

  bool _isRunning(WorkflowEvent event) =>
      event.startedAt != null &&
      event.heartbeatAt != null &&
      DateTime.timestamp().difference(event.heartbeatAt!) <
          _heartbeatInterval * 3;

  Span? get _currentSpan =>
      _tracing ? _telemetry.getDefaultTracer().findParentSpan() : null;

  /// The span of the code that created [event], if it was traced.
  static Span? _spanOf(WorkflowEvent event) => switch ((
    TraceId.tryParse(event.traceId),
    SpanId.tryParse(event.spanId),
  )) {
    (final traceId?, final spanId?) => Span.remote(
      traceId: traceId,
      spanId: spanId,
    ),
    _ => null,
  };

  Object _idOf(T element) => _idField.valueOf(element) as Object;

  TState _stateOf(T element) => _stateField.valueOf(element);

  String _lockKey(Object id) => 'workflow:$_name:$id';

  String _truncate(String text) =>
      text.length <= 1000 ? text : '${text.substring(0, 1000)}...';

  Map<String, String> _labels({
    WorkflowStep<T, TState>? step,
    Object? id,
    int? attempt,
    String? event,
  }) => {
    'datahub.workflow.name': _name,
    if (step != null) 'datahub.workflow.step': step.name,
    if (id != null) 'datahub.workflow.element.id': id.toString(),
    if (attempt != null) 'datahub.workflow.attempt': attempt.toString(),
    'datahub.workflow.event.id': ?event,
  };
}

class _WorkflowMetrics {
  final CounterMetric steps;
  final HistogramMetric duration;
  final HistogramMetric delay;
  final CounterMetric signals;
  final CounterMetric parked;
  final GaugeMetric due;

  _WorkflowMetrics(
    Telemetry telemetry,
    String prefix, {
    required List<String> steps,
    required List<String> signals,
  }) : steps = telemetry.counter(
         '${prefix}_steps_total',
         labels: {
           'step': steps,
           'outcome': ['succeeded', 'failed'],
         },
         help: 'Number of step attempts by outcome.',
       ),
       duration = telemetry.exponentialHistogram(
         '${prefix}_step_duration_seconds',
         start: 0.005,
         factor: 2,
         count: 16,
         labels: {'step': steps},
         help: 'Time a step took, including writing its result.',
       ),
       delay = telemetry.exponentialHistogram(
         '${prefix}_step_delay_seconds',
         start: 0.005,
         factor: 2,
         count: 16,
         labels: {'step': steps},
         help: 'Time between a step being due and it starting.',
       ),
       signals = telemetry.counter(
         '${prefix}_signals_total',
         labels: {
           'signal': signals.isEmpty ? [''] : signals,
         },
         help: 'Number of signals sent.',
       ),
       parked = telemetry.counter(
         '${prefix}_events_parked_total',
         labels: {
           'status': [
             WorkflowEventStatus.failed.name,
             WorkflowEventStatus.expired.name,
           ],
         },
         help: 'Number of events that were given up.',
       ),
       due = telemetry.gauge(
         '${prefix}_events_due',
         help: 'Number of events that were due in the last poll.',
       );
}
