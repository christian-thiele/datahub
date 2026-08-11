@TestOn('mac-os || linux')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'SIGTERM triggers graceful shutdown',
    timeout: const Timeout(Duration(minutes: 2)),
    () async {
      final process = await Process.start('dart', [
        'run',
        'test/scaffold/fixture/signal_app.dart',
      ]);

      final output = <String>[];
      final initialized = Completer<void>();
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            output.add(line);
            if (line.contains('MARKER_INITIALIZED') &&
                !initialized.isCompleted) {
              initialized.complete();
            }
          });
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(output.add);

      await initialized.future.timeout(const Duration(seconds: 60));
      // allow the host to finish initialization after the marker line
      await Future.delayed(const Duration(milliseconds: 500));

      process.kill(ProcessSignal.sigterm);
      final exitCode = await process.exitCode.timeout(
        const Duration(seconds: 30),
      );

      expect(exitCode, equals(0));
      expect(output, contains(contains('Shutting down application')));
      expect(output, contains(contains('MARKER_DISPOSED')));
      expect(output, contains(contains('MARKER_EXITED')));
    },
  );
}
