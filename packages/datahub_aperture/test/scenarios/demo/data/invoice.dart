import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

import 'address.dart';
import 'client.dart';
import 'invoice_line.dart';
import 'invoice_status.dart';
import 'project.dart';

part 'invoice.g.dart';

@Data()
@Meta(namePlural: 'Invoices', icon: Icons.receipt_long)
@ApertureMeta(titleTemplate: '{{ invoiceNumber }}')
class const Invoice({
  @Id(auto: true) final int id = 0,
  @ApertureField(isDisplayField: true, readOnly: true)
  @Meta(name: 'Invoice No.')
  @RegExpConstraint(expression: r'^INV-\d{4}-\d{4}$')
  required final String invoiceNumber,
  @Meta(name: 'Client')
  @RelationId<Client>()
  @ApertureField(readOnly: true)
  required final int clientId,
  @Meta(name: 'Project') @RelationId<Project>() final int? projectId,
  @ApertureField(isDisplayField: true)
  final InvoiceStatus status = InvoiceStatus.draft,
  @ApertureField(isDisplayField: true)
  @Meta(name: 'Issued')
  required final DateTime issuedAt,
  @Meta(name: 'Due') required final DateTime dueAt,
  @Meta(name: 'Paid') final DateTime? paidAt,
  @Meta(name: 'Service period from') final DateTime? servicePeriodStart,
  @Meta(name: 'Service period until') final DateTime? servicePeriodEnd,
  @Meta(name: 'Billing address') required final Address billingAddress,
  @Meta(name: 'Line items') required final List<InvoiceLine> lines,
  @ApertureField(readOnly: true)
  @Meta(name: 'Net')
  required final double netTotal,
  @ApertureField(readOnly: true)
  @Meta(name: 'Tax')
  required final double taxTotal,
  @ApertureField(isDisplayField: true, readOnly: true)
  @Meta(name: 'Gross')
  required final double grossTotal,
  @RegExpConstraint(expression: r'^[A-Z]{3}$') final String currency = 'EUR',
  @Meta(name: 'Payment reference') final String? paymentReference,
  @Meta(name: 'Reminders sent')
  @RangeConstraint(min: 0, max: 3)
  final int remindersSent = 0,
  @ApertureField(allowFilter: false, allowSort: false) final String? notes,
}) extends $Invoice;
