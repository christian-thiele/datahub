import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

import 'client.dart';
import 'contact.dart';
import 'employee.dart';
import 'priority.dart';
import 'project.dart';
import 'ticket_channel.dart';
import 'ticket_status.dart';

part 'support_ticket.g.dart';

@Data()
@Meta(name: 'Ticket', namePlural: 'Support tickets', icon: Icons.support_agent)
@ApertureMeta(titleTemplate: '{{ ticketNumber }} {{ subject }}')
class const SupportTicket({
  @Id(auto: true) final int id = 0,
  @ApertureField(isDisplayField: true, readOnly: true)
  @Meta(name: 'Ticket No.')
  @RegExpConstraint(expression: r'^#\d{5}$')
  required final String ticketNumber,
  @ApertureField(isDisplayField: true)
  @MaxLengthConstraint(length: 160)
  required final String subject,
  @ApertureField(allowFilter: false, allowSort: false)
  @Meta(name: 'Message')
  required final String body,
  @Meta(name: 'Client') @RelationId<Client>() required final int clientId,
  @Meta(name: 'Reported by') @RelationId<Contact>() final int? contactId,
  @Meta(name: 'Project') @RelationId<Project>() final int? projectId,
  @Meta(name: 'Assignee') @RelationId<Employee>() final int? assigneeId,
  @ApertureField(isDisplayField: true)
  final TicketStatus status = TicketStatus.open,
  @ApertureField(isDisplayField: true)
  final Priority priority = Priority.normal,
  final TicketChannel channel = TicketChannel.email,
  @Meta(name: 'Created') required final DateTime createdAt,
  @Meta(name: 'First response') final DateTime? firstResponseAt,
  @Meta(name: 'Resolved') final DateTime? resolvedAt,
  @ApertureField(allowFilter: false, allowSort: false) final String? resolution,
  @ElementConstraint(constraint: RegExpConstraint(expression: r'^[a-z0-9-]+$'))
  final List<String> labels = const [],
  @Meta(name: 'SLA breached') final bool slaBreached = false,
  @Meta(description: 'Customer rating from 1 (poor) to 5 (excellent).')
  @RangeConstraint(min: 1, max: 5)
  final int? satisfaction,
}) extends $SupportTicket;
