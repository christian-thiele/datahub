import 'dart:ui';

import 'package:datahub_aperture/api.dart';

import 'bootstrap_repository.dart';

class MockBootstrapRepository implements BootstrapRepository {
  @override
  Future<void> initialize() async {}

  @override
  Future<ApertureBootstrap> fetch() async {
    await Future.delayed(const Duration(seconds: 5));
    return ApertureBootstrap(
      title: 'Datahub Aperture',
      theme: ApertureTheme(color: 0xFFFF0000),
    );
  }

  @override
  Future<void> close() async {}
}
