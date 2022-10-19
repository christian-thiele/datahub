import 'dart:async';

import 'package:test/scaffolding.dart';

abstract class TestCase {
  final String description;
  final Timeout timeout;
  final bool skip;

  TestCase(
    this.description, {
    this.timeout = const Timeout(Duration(minutes: 1)),
    this.skip = false,
  });

  Future<void> execute();
}
