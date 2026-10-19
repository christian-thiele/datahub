import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

import 'client.dart';
import 'department.dart';
import 'project.dart';
import 'support_ticket.dart';
import 'time_entry.dart';

part 'employee.g.dart';

@Data()
@Meta(namePlural: 'Employees', icon: Icons.badge, description: 'Our own staff.')
@ApertureMeta(titleTemplate: '{{ firstName }} {{ lastName }}')
@ApertureRelation<Employee>()
@ApertureRelation<Client>()
@ApertureRelation<Project>()
@ApertureRelation<TimeEntry>()
@ApertureRelation<SupportTicket>()
class const Employee({
  @Id(auto: true) final int id = 0,
  @ApertureField(isDisplayField: true, readOnly: true)
  @Meta(name: 'Personnel No.')
  @RegExpConstraint(expression: r'^E\d{4}$')
  required final String personnelNumber,
  @ApertureField(isDisplayField: true)
  @MaxLengthConstraint(length: 50)
  required final String firstName,
  @ApertureField(isDisplayField: true)
  @MaxLengthConstraint(length: 50)
  required final String lastName,
  @Meta(name: 'E-mail')
  @RegExpConstraint(expression: r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$')
  required final String email,
  @ApertureField(isDisplayField: true)
  @Meta(name: 'Job title')
  required final String jobTitle,
  required final Department department,
  @Meta(name: 'Hired') required final DateTime hiredAt,
  @Meta(
    name: 'Hourly cost rate',
    description: 'Internal cost per hour in EUR, used for margin reports.',
  )
  @RangeConstraint(min: 0, max: 500)
  required final double hourlyCostRate,
  @Meta(name: 'Weekly hours')
  @RangeConstraint(min: 0, max: 48)
  final int weeklyHours = 40,
  final List<String> skills = const [],
  @Meta(description: 'Spoken languages (ISO 639-1).')
  @ElementConstraint(constraint: RegExpConstraint(expression: r'^[a-z]{2}$'))
  final List<String> languages = const ['en'],
  @Meta(name: 'Reports to') @RelationId<Employee>() final int? managerId,
  @Meta(name: 'Fully remote') final bool remote = false,
  final bool active = true,
}) extends $Employee;
