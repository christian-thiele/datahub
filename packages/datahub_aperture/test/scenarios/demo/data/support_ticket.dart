import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/data/meta/aperture_meta.dart';

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
class SupportTicket extends $SupportTicket {
  const SupportTicket({
    this.id = 0,
    required this.ticketNumber,
    required this.subject,
    required this.body,
    required this.clientId,
    this.contactId,
    this.projectId,
    this.assigneeId,
    this.status = TicketStatus.open,
    this.priority = Priority.normal,
    this.channel = TicketChannel.email,
    required this.createdAt,
    this.firstResponseAt,
    this.resolvedAt,
    this.resolution,
    this.labels = const [],
    this.slaBreached = false,
    this.satisfaction,
  });

  @Id(auto: true)
  final int id;

  @ApertureField(isDisplayField: true, readOnly: true)
  @Meta(name: 'Ticket No.')
  @RegExpConstraint(expression: r'^#\d{5}$')
  final String ticketNumber;

  @ApertureField(isDisplayField: true)
  @MaxLengthConstraint(length: 160)
  final String subject;

  @ApertureField(allowFilter: false, allowSort: false)
  @Meta(name: 'Message')
  final String body;

  @Meta(name: 'Client')
  @RelationId<Client>()
  final int clientId;

  @Meta(name: 'Reported by')
  @RelationId<Contact>()
  final int? contactId;

  @Meta(name: 'Project')
  @RelationId<Project>()
  final int? projectId;

  @Meta(name: 'Assignee')
  @RelationId<Employee>()
  final int? assigneeId;

  @ApertureField(isDisplayField: true)
  final TicketStatus status;

  @ApertureField(isDisplayField: true)
  final Priority priority;

  final TicketChannel channel;

  @Meta(name: 'Created')
  final DateTime createdAt;

  @Meta(name: 'First response')
  final DateTime? firstResponseAt;

  @Meta(name: 'Resolved')
  final DateTime? resolvedAt;

  @ApertureField(allowFilter: false, allowSort: false)
  final String? resolution;

  @ElementConstraint(constraint: RegExpConstraint(expression: r'^[a-z0-9-]+$'))
  final List<String> labels;

  @Meta(name: 'SLA breached')
  final bool slaBreached;

  @Meta(description: 'Customer rating from 1 (poor) to 5 (excellent).')
  @RangeConstraint(min: 1, max: 5)
  final int? satisfaction;
}
