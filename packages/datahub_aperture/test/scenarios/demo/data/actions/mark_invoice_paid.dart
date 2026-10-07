import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/icons.dart';

import '../invoice.dart';

part 'mark_invoice_paid.g.dart';

/// Tells the invoice workflow that a payment arrived.
@Data()
@Meta(name: 'Mark as paid', icon: Icons.payments)
class MarkInvoicePaid extends $MarkInvoicePaid
    implements WorkflowSignal<Invoice> {
  const MarkInvoicePaid({
    required this.invoiceId,
    required this.paidAt,
    this.paymentReference,
  });

  @Meta(name: 'Invoice')
  @RelationId<Invoice>()
  final int invoiceId;

  @Meta(name: 'Payment received')
  final DateTime paidAt;

  @Meta(
    name: 'Payment reference',
    description: 'Bank transfer reference, if available.',
  )
  final String? paymentReference;
}
