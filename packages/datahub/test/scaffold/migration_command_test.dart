import 'package:datahub/scaffold.dart';
import 'package:test/test.dart';

void main() {
  group('MigrationCommand.tryParse', () {
    test('ignores anything that is not a migrate invocation', () {
      expect(MigrationCommand.tryParse([]), isNull);
      expect(MigrationCommand.tryParse(['-c', 'a=b']), isNull);
      expect(MigrationCommand.tryParse(['serve', 'migrate']), isNull);
    });

    test('reads the command and its argument', () {
      final command = MigrationCommand.tryParse([
        'migrate',
        'new',
        'add_email',
      ])!;
      expect(command.name, equals('new'));
      expect(command.argument, equals('add_email'));
      expect(command.flags, isEmpty);
    });

    test('defaults to status', () {
      expect(MigrationCommand.tryParse(['migrate'])!.name, equals('status'));
    });

    test('reads flags', () {
      final command = MigrationCommand.tryParse([
        'migrate',
        'apply',
        '--dry-run',
        '--allow-destructive',
      ])!;
      expect(command.name, equals('apply'));
      expect(command.has('dry-run'), isTrue);
      expect(command.has('allow-destructive'), isTrue);
      expect(command.has('empty'), isFalse);
    });

    test('does not mistake a config value for the argument', () {
      final command = MigrationCommand.tryParse([
        'migrate',
        'apply',
        '-c',
        'postgres.host=db',
        '-f',
        'config.yaml',
      ])!;
      expect(command.name, equals('apply'));
      expect(command.argument, isNull);
    });

    test('knows which commands need a database', () {
      for (final name in ['new', 'plan']) {
        expect(
          MigrationCommand.tryParse(['migrate', name])!.needsDatabase,
          isFalse,
          reason: '$name has to work without a database',
        );
      }
      for (final name in ['status', 'apply', 'verify', 'baseline']) {
        expect(
          MigrationCommand.tryParse(['migrate', name])!.needsDatabase,
          isTrue,
        );
      }
    });
  });
}
