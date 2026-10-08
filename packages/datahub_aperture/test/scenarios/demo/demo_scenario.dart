import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

import '../../_utils/test_auth_provider.dart';
import 'data/actions/mark_invoice_paid.dart';
import 'data/actions/renew_price_agreement.dart';
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

/// A realistic backoffice for "ACME Digital", a fictional software
/// agency: clients, contacts, projects, timesheets, invoices, support tickets.
///
/// Invoices move through a workflow (see [_invoiceSteps]), which Aperture
/// shows on the invoices.
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
  MemoryRepositoryService(bean: $WorkflowEvent.bean),
  MemoryRepositoryService(bean: $WorkflowHistoryEntry.bean),
  MemoryLockService<String>(),
  WorkflowService<Invoice, InvoiceStatus>(steps: _invoiceSteps),
  DemoAuthService(),
  TestAuthProvider(),
  ApiService(
    routes: [
      // The frontend is served from another origin during development.
      CorsMiddleware(
        routes: [
          ApertureApi(
            title: const Config.value('ACME Backoffice'),
            theme: ApertureTheme(color: 0xff0f766e),
            oidcIssuer: const Config.value(
              'http://localhost:8081/realms/local-oidc',
            ),
            oidcClientId: const Config.value('aperture'),
            resources: [
              ApertureResource(repository: Find<DataRepository<Client>>()),
              ApertureResource(repository: Find<DataRepository<Contact>>()),
              ApertureResource(repository: Find<DataRepository<Project>>()),
              ApertureResource(repository: Find<DataRepository<TimeEntry>>()),
              ApertureResource(repository: Find<DataRepository<Invoice>>()),
              ApertureResource(
                repository: Find<DataRepository<SupportTicket>>(),
                actions: [
                  ApertureAction<ResolveTicket>(
                    bean: $ResolveTicket.bean,
                    handler: _resolveTicket,
                  ),
                ],
              ),
              ApertureResource(
                repository: Find<DataRepository<Product>>(),
                actions: [
                  ApertureAction<RenewPriceAgreement>(
                    bean: $RenewPriceAgreement.bean,
                    handler: _renewPriceAgreement,
                  ),
                ],
              ),
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
    ],
  ),
  ServiceDelegate(initialize: seedDemoData),
], arguments: args);

/// A sent invoice becomes overdue at its due date, which sends a payment
/// reminder. A [MarkInvoicePaid] signal marks it as paid.
final _invoiceSteps = <WorkflowStep<Invoice, InvoiceStatus>>[
  OnEnter(
    name: 'Mark Overdue',
    InvoiceStatus.sent,
    _markOverdue,
    at: (invoice) => invoice.dueAt,
  ),
  OnEnter(
    name: 'Send Reminder',
    InvoiceStatus.overdue,
    _sendReminder,
    retry: RetryPolicy.none(),
  ),
  OnSignal(
    name: 'Mark Paid',
    $MarkInvoicePaid.bean,
    accept: [InvoiceStatus.sent, InvoiceStatus.overdue],
    target: (signal) => signal.invoiceId,
    handle: (step) async => step.element.copyWith(
      status: InvoiceStatus.paid,
      paidAt: step.signal.paidAt,
      paymentReference: step.signal.paymentReference,
    ),
  ),
];

Future<Invoice> _markOverdue(StepContext<Invoice> step) async {
  log.info('Invoice ${step.element.invoiceNumber} is overdue.');
  return step.element.copyWith(status: InvoiceStatus.overdue);
}

/// Invoices whose reminder bounced, see [_sendReminder].
final _bounced = <int>{};

Future<Invoice> _sendReminder(StepContext<Invoice> step) async {
  final invoice = step.element;
  if (invoice.remindersSent >= 3) {
    log.info('Reminded three times already, waiting for the payment.');
    return invoice;
  }

  log.info('Sending a payment reminder for ${invoice.invoiceNumber}.');
  // The first reminder of each invoice bounces, to show failed steps (and
  // retrying them) in Aperture.
  if (_bounced.add(invoice.id)) {
    throw ApiException('The mail server rejected the reminder.');
  }
  return invoice.copyWith(remindersSent: invoice.remindersSent + 1);
}

Future<BaseActionResult> _resolveTicket(
  String? ticketId,
  ResolveTicket params,
) async {
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

  return ActionResult(
    message: params.closeImmediately
        ? 'The ticket was closed.'
        : 'The ticket was resolved and waits for the customer to confirm.',
  );
}

/// Sends another reminder for overdue invoices. Invoices become overdue in
/// their workflow.
Future<BaseActionResult> _sendPaymentReminders(
  String? _,
  SendPaymentReminders params,
) async {
  final repo = Find<DataRepository<Invoice>>().find();
  final cutoff = DateTime.now().toUtc().subtract(
    Duration(days: params.minDaysOverdue),
  );
  final invoices = await repo.readAll(
    filter: $Invoice.$status
        .equals(InvoiceStatus.overdue)
        .and($Invoice.$dueAt.lessThan(cutoff)),
  );

  // At most three reminders are sent, the rest is left to collection.
  final reminded = invoices.where((invoice) => invoice.remindersSent < 3);
  for (final invoice in reminded) {
    await repo.updateById(
      invoice.copyWith(remindersSent: invoice.remindersSent + 1),
    );
  }

  final skipped = invoices.length - reminded.length;
  return ActionResult(
    success: skipped == 0,
    message: skipped == 0
        ? 'Sent ${reminded.length} payment reminders.'
        : 'Sent ${reminded.length} payment reminders, $skipped invoices '
              'already got three reminders.',
    data: {
      'reminded': [for (final invoice in reminded) invoice.invoiceNumber],
      if (skipped > 0)
        'skipped': [
          for (final invoice in invoices.where((i) => i.remindersSent >= 3))
            invoice.invoiceNumber,
        ],
    },
  );
}

/// Ends a price agreement and starts a new one with another price, which is
/// shown instead.
Future<BaseActionResult> _renewPriceAgreement(
  String? productId,
  RenewPriceAgreement params,
) async {
  final repo = Find<DataRepository<Product>>().find();
  final product = await repo.readById(productId);
  if (product == null) {
    throw ApiRequestException.notFound('Price agreement not found.');
  }

  if (!params.validFrom.isAfter(product.validFrom)) {
    throw ApiRequestException(
      400,
      'The renewal must start after the current agreement.',
      data: {
        'fields': {
          'validFrom': ['Must be after ${product.validFrom}.'],
        },
      },
    );
  }

  await repo.updateById(
    product.copyWith(validUntil: params.validFrom, active: false),
  );
  final renewed = await repo.create(
    product.copyWith(
      id: '',
      price: params.price,
      validFrom: params.validFrom,
      nullValidUntil: true,
      active: true,
    ),
  );

  return RedirectActionResult(bean: $Product.bean, id: renewed.id);
}
