import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

import 'billing_type.dart';
import 'client.dart';
import 'employee.dart';
import 'invoice.dart';
import 'priority.dart';
import 'project_status.dart';
import 'support_ticket.dart';
import 'time_entry.dart';

part 'project.g.dart';

@Data()
@Meta(namePlural: 'Projects', icon: Icons.work)
@ApertureMeta(titleTemplate: '{{ code }} · {{ name }}')
@ApertureRelation<TimeEntry>()
@ApertureRelation<Invoice>()
@ApertureRelation<SupportTicket>()
class const Project({
  @Id(auto: true) final int id = 0,
  @ApertureField(isDisplayField: true, readOnly: true)
  @RegExpConstraint(expression: r'^P-\d{4}-\d{3}$')
  required final String code,
  @ApertureField(isDisplayField: true)
  @MaxLengthConstraint(length: 120)
  required final String name,
  @ApertureField(allowFilter: false, allowSort: false)
  @MaxLengthConstraint(length: 4000)
  final String? description,
  @Meta(name: 'Client') @RelationId<Client>() required final int clientId,
  @Meta(name: 'Project lead') @RelationId<Employee>() final int? projectLeadId,
  @ApertureField(isDisplayField: true)
  final ProjectStatus status = ProjectStatus.planned,
  final Priority priority = Priority.normal,
  @Meta(name: 'Billing') required final BillingType billingType,
  @Meta(name: 'Start') required final DateTime startDate,
  @Meta(name: 'End', description: 'Planned or actual end date.')
  final DateTime? endDate,
  @Meta(description: 'Total budget in client currency (net).')
  @RangeConstraint(min: 0, max: 100000000)
  required final double budget,
  @Meta(name: 'Estimated hours')
  @RangeConstraint(min: 0, max: 100000)
  final int? estimatedHours,
  @Meta(name: 'Tech stack') final List<String> technologies = const [],
  @ApertureField(allowFilter: false, allowSearch: false, allowSort: false)
  @Meta(description: 'External links, e.g. repository, board, staging.')
  final Map<String, dynamic> links = const {},
}) extends $Project;
