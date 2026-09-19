import 'dart:math' as math;

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

import '../../_utils/test_auth_provider.dart';
import 'data/actions/mark_invoice_paid.dart';
import 'data/actions/resolve_ticket.dart';
import 'data/actions/send_payment_reminders.dart';
import 'data/client.dart';
import 'data/contact.dart';
import 'data/employee.dart';
import 'data/invoice.dart';
import 'data/invoice_status.dart';
import 'data/product.dart';
import 'data/project.dart';
import 'data/support_ticket.dart';
import 'data/ticket_status.dart';
import 'data/time_entry.dart';
import 'demo_auth_service.dart';
import 'demo_seed.dart';

/// A realistic backoffice for "Brightline Digital", a fictional software
/// agency: clients, contacts, projects, timesheets, invoices, support tickets.
void main(List<String> args) => runApp([
  KeyService(),
  MemoryRepositoryService(bean: $Employee.bean),
  MemoryRepositoryService(bean: $Client.bean),
  MemoryRepositoryService(bean: $Contact.bean),
  MemoryRepositoryService(bean: $Product.bean),
  MemoryRepositoryService(bean: $Project.bean),
  MemoryRepositoryService(bean: $TimeEntry.bean),
  MemoryRepositoryService(bean: $Invoice.bean),
  MemoryRepositoryService(bean: $SupportTicket.bean),
  DemoAuthService(),
  TestAuthProvider(),
  ApiService(
    routes: [
      ApertureApi(
        title: const Config.value('Brightline Backoffice'),
        theme: const ApertureTheme(color: 0xff0f766e),
        oidcIssuer: const Config.value(
          'http://localhost:8081/realms/local-oidc',
        ),
        oidcClientId: const Config.value('aperture'),
        resources: [
          ApertureResource(repository: Find<DataRepository<Client>>()),
          ApertureResource(repository: Find<DataRepository<Contact>>()),
          ApertureResource(repository: Find<DataRepository<Project>>()),
          ApertureResource(repository: Find<DataRepository<TimeEntry>>()),
          ApertureResource(
            repository: Find<DataRepository<Invoice>>(),
            actions: [
              ApertureAction<MarkInvoicePaid>(
                bean: $MarkInvoicePaid.bean,
                handler: _markInvoicePaid,
              ),
            ],
          ),
          ApertureResource(
            repository: Find<DataRepository<SupportTicket>>(),
            actions: [
              ApertureAction<ResolveTicket>(
                bean: $ResolveTicket.bean,
                handler: _resolveTicket,
              ),
            ],
          ),
          ApertureResource(repository: Find<DataRepository<Product>>()),
          ApertureResource(repository: Find<DataRepository<Employee>>()),
        ],
        actions: [
          ApertureAction<SendPaymentReminders>(
            bean: $SendPaymentReminders.bean,
            handler: _sendPaymentReminders,
          ),
        ],
      ),
    ],
  ),
  ServiceDelegate(initialize: seedDemoData),
], arguments: args);

Future<String?> _markInvoicePaid(
  String? invoiceId,
  MarkInvoicePaid params,
) async {
  final repo = Find<DataRepository<Invoice>>().find();
  final invoice = await repo.readById(invoiceId);
  if (invoice == null) {
    throw ApiRequestException.notFound('Invoice not found.');
  }
  if (invoice.status == InvoiceStatus.draft ||
      invoice.status == InvoiceStatus.cancelled) {
    throw ApiRequestException.badRequest(
      'Only sent or overdue invoices can be marked as paid.',
    );
  }

  await repo.updateById(
    invoice.copyWith(
      status: InvoiceStatus.paid,
      paidAt: params.paidAt,
      paymentReference: params.paymentReference,
    ),
  );
  return null;
}

Future<String?> _resolveTicket(String? ticketId, ResolveTicket params) async {
  final repo = Find<DataRepository<SupportTicket>>().find();
  final ticket = await repo.readById(ticketId);
  if (ticket == null) {
    throw ApiRequestException.notFound('Ticket not found.');
  }

  final now = DateTime.now().toUtc();
  await repo.updateById(
    ticket.copyWith(
      status: params.closeImmediately
          ? TicketStatus.closed
          : TicketStatus.resolved,
      resolution: params.resolution,
      resolvedAt: now,
      firstResponseAt: ticket.firstResponseAt ?? now,
    ),
  );
  return null;
}

Future<String?> _sendPaymentReminders(
  String? _,
  SendPaymentReminders params,
) async {
  final repo = Find<DataRepository<Invoice>>().find();
  final cutoff = DateTime.now().toUtc().subtract(
    Duration(days: params.minDaysOverdue),
  );
  final invoices = await repo.readAll(
    filter: Filter.orGroup([
      $Invoice.$status.equals(InvoiceStatus.sent),
      $Invoice.$status.equals(InvoiceStatus.overdue),
    ]).and($Invoice.$dueAt.lessThan(cutoff)),
  );

  for (final invoice in invoices) {
    await repo.updateById(
      invoice.copyWith(
        status: InvoiceStatus.overdue,
        remindersSent: math.min(3, invoice.remindersSent + 1),
      ),
    );
  }
  return null;
}
