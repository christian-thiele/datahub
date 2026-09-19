import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/services.dart';
import 'package:test/test.dart';

import '../scenarios/demo/data/actions/resolve_ticket.dart';
import '../scenarios/demo/data/actions/send_payment_reminders.dart';

ApertureAction<T> _action<T extends DataObject>(DataBean<T> bean) =>
    ApertureAction<T>(bean: bean, handler: (_, _) async => null);

void main() {
  group('decodeParameters', () {
    test('decodes the parameters', () {
      final parameters = _action($ResolveTicket.bean).decodeParameters({
        'resolution': 'Replaced the router.',
        'closeImmediately': true,
      });

      expect(parameters.resolution, 'Replaced the router.');
      expect(parameters.closeImmediately, isTrue);
    });

    test('falls back to the defaults of missing parameters', () {
      final parameters = _action(
        $SendPaymentReminders.bean,
      ).decodeParameters(<String, dynamic>{});

      expect(parameters.minDaysOverdue, 7);
    });

    test('fails for missing required parameters', () {
      expect(
        () =>
            _action($ResolveTicket.bean).decodeParameters(<String, dynamic>{}),
        throwsA(
          isA<CodecException>().having((e) => e.name, 'name', 'resolution'),
        ),
      );
    });

    test('fails for parameters that violate constraints', () {
      expect(
        () => _action(
          $ResolveTicket.bean,
        ).decodeParameters({'resolution': 'Done.'}),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.violatedConstraints.keys.map((f) => f.name),
            'fields',
            ['resolution'],
          ),
        ),
      );
    });
  });
}
