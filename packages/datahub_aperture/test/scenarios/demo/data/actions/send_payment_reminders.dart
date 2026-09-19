import 'package:datahub/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'send_payment_reminders.g.dart';

@Data()
@Meta(name: 'Send payment reminders', icon: Icons.notifications_active)
class SendPaymentReminders extends $SendPaymentReminders {
  const SendPaymentReminders({this.minDaysOverdue = 7});

  @Meta(
    name: 'Minimum days overdue',
    description: 'Only remind invoices that are at least this late.',
  )
  @RangeConstraint(min: 0, max: 365)
  final int minDaysOverdue;
}
