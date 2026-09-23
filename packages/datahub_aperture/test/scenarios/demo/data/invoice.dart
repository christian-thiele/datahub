import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/data/meta/aperture_meta.dart';

import 'address.dart';
import 'client.dart';
import 'invoice_line.dart';
import 'invoice_status.dart';
import 'project.dart';

part 'invoice.g.dart';

@Data()
@Meta(namePlural: 'Invoices', icon: Icons.receipt_long)
@ApertureMeta(titleTemplate: '{{ invoiceNumber }}')
class Invoice extends $Invoice {
  const Invoice({
    this.id = 0,
    required this.invoiceNumber,
    required this.clientId,
    this.projectId,
    this.status = InvoiceStatus.draft,
    required this.issuedAt,
    required this.dueAt,
    this.paidAt,
    this.servicePeriodStart,
    this.servicePeriodEnd,
    required this.billingAddress,
    required this.lines,
    required this.netTotal,
    required this.taxTotal,
    required this.grossTotal,
    this.currency = 'EUR',
    this.paymentReference,
    this.remindersSent = 0,
    this.notes,
  });

  @Id(auto: true)
  final int id;

  @ApertureField(isDisplayField: true, readOnly: true)
  @Meta(name: 'Invoice No.')
  @RegExpConstraint(expression: r'^INV-\d{4}-\d{4}$')
  final String invoiceNumber;

  @Meta(name: 'Client')
  @RelationId<Client>()
  @ApertureField(readOnly: true)
  final int clientId;

  @Meta(name: 'Project')
  @RelationId<Project>()
  final int? projectId;

  @ApertureField(isDisplayField: true)
  final InvoiceStatus status;

  @ApertureField(isDisplayField: true)
  @Meta(name: 'Issued')
  final DateTime issuedAt;

  @Meta(name: 'Due')
  final DateTime dueAt;

  @Meta(name: 'Paid')
  final DateTime? paidAt;

  @Meta(name: 'Service period from')
  final DateTime? servicePeriodStart;

  @Meta(name: 'Service period until')
  final DateTime? servicePeriodEnd;

  @Meta(name: 'Billing address')
  final Address billingAddress;

  @Meta(name: 'Line items')
  final List<InvoiceLine> lines;

  @ApertureField(readOnly: true)
  @Meta(name: 'Net')
  final double netTotal;

  @ApertureField(readOnly: true)
  @Meta(name: 'Tax')
  final double taxTotal;

  @ApertureField(isDisplayField: true, readOnly: true)
  @Meta(name: 'Gross')
  final double grossTotal;

  @RegExpConstraint(expression: r'^[A-Z]{3}$')
  final String currency;

  @Meta(name: 'Payment reference')
  final String? paymentReference;

  @Meta(name: 'Reminders sent')
  @RangeConstraint(min: 0, max: 3)
  final int remindersSent;

  @ApertureField(allowFilter: false, allowSort: false)
  final String? notes;
}
