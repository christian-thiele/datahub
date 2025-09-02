import 'dart:async';

import 'package:boost/src/concurrency/cancellation_token.dart';

/// Describes the execution result of a function inside the
/// [runGuarded] function.
class GuardResult<T> {
  T? result;
  dynamic error;
  StackTrace? stackTrace;

  GuardResult({this.result, this.error, this.stackTrace});

  bool get success => error == null;
}

enum ExecutionMode { Serial, Concurrent }

/// Executes multiple async functions concurrent while
/// catching every result or error that is thrown.
///
/// The resulting list contains [GuardResult] objects which
/// describe the result of the execution of each function.
/// The list is created in the order of the termination of the
/// functions, not necessarily in the same order as the
/// actions iterable.
Future<List<GuardResult>> runGuarded(
    Iterable<Future Function(CancellationToken?)> actions,
    {ExecutionMode executionMode = ExecutionMode.Concurrent,
    CancellationToken? cancel}) async {
  final tasks = <Future>[];
  final results = <GuardResult>[];

  var skipResults = false;
  for (final action in actions) {
    try {
      final future = action(cancel);
      switch (executionMode) {
        case ExecutionMode.Serial:
          results.add(GuardResult(result: await future.cancelOn(cancel)));
          break;
        case ExecutionMode.Concurrent:
          tasks.add(future
              .then((value) => results.add(GuardResult(result: value)))
              .catchError((e, stack) =>
                  results.add(GuardResult(error: e, stackTrace: stack))));
          break;
      }
    } catch (e, stack) {
      results.add(GuardResult(error: e, stackTrace: stack));
    }
  }

  if (!skipResults) {
    await Future.wait(tasks).cancelOn(cancel);
  }

  return results;
}
