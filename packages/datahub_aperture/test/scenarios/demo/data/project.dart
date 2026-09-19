import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/data/meta/aperture_meta.dart';

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
class Project extends $Project {
  const Project({
    this.id = 0,
    required this.code,
    required this.name,
    this.description,
    required this.clientId,
    this.projectLeadId,
    this.status = ProjectStatus.planned,
    this.priority = Priority.normal,
    required this.billingType,
    required this.startDate,
    this.endDate,
    required this.budget,
    this.estimatedHours,
    this.technologies = const [],
    this.links = const {},
  });

  @Id(auto: true)
  final int id;

  @ApertureField(isDisplayField: true, readOnly: true)
  @RegExpConstraint(expression: r'^P-\d{4}-\d{3}$')
  final String code;

  @ApertureField(isDisplayField: true)
  @MaxLengthConstraint(length: 120)
  final String name;

  @ApertureField(allowFilter: false, allowSort: false)
  @MaxLengthConstraint(length: 4000)
  final String? description;

  @Meta(name: 'Client')
  @RelationId<Client>()
  final int clientId;

  @Meta(name: 'Project lead')
  @RelationId<Employee>()
  final int? projectLeadId;

  @ApertureField(isDisplayField: true)
  final ProjectStatus status;

  final Priority priority;

  @Meta(name: 'Billing')
  final BillingType billingType;

  @Meta(name: 'Start')
  final DateTime startDate;

  @Meta(name: 'End', description: 'Planned or actual end date.')
  final DateTime? endDate;

  @Meta(description: 'Total budget in client currency (net).')
  @RangeConstraint(min: 0, max: 100000000)
  final double budget;

  @Meta(name: 'Estimated hours')
  @RangeConstraint(min: 0, max: 100000)
  final int? estimatedHours;

  @Meta(name: 'Tech stack')
  final List<String> technologies;

  @ApertureField(allowFilter: false, allowSearch: false, allowSort: false)
  @Meta(description: 'External links, e.g. repository, board, staging.')
  final Map<String, dynamic> links;
}
