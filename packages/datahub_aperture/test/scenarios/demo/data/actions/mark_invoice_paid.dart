import 'package:datahub/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'mark_invoice_paid.g.dart';

@Data()
@Meta(name: 'Mark as paid', icon: Icons.payments)
class MarkInvoicePaid extends $MarkInvoicePaid {
  const MarkInvoicePaid({required this.paidAt, this.paymentReference});

  @Meta(name: 'Payment received')
  final DateTime paidAt;

  @Meta(
    name: 'Payment reference',
    description: 'Bank transfer reference, if available.',
  )
  final String? paymentReference;
}
