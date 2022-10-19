import 'dart:async';

import 'test_case.dart';

/// Simple unit test.
class Test extends TestCase {
  final FutureOr<void> Function() delegate;

  Test(
    super.description,
    this.delegate, {
    super.skip,
    super.timeout,
  });

  @override
  Future<void> execute() async => await delegate();
}
