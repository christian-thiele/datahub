import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/data/meta/aperture_meta.dart';

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
class Employee extends $Employee {
  const Employee({
    this.id = 0,
    required this.personnelNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.jobTitle,
    required this.department,
    required this.hiredAt,
    required this.hourlyCostRate,
    this.weeklyHours = 40,
    this.skills = const [],
    this.languages = const ['en'],
    this.managerId,
    this.remote = false,
    this.active = true,
  });

  @Id(auto: true)
  final int id;

  @ApertureField(isDisplayField: true, readOnly: true)
  @Meta(name: 'Personnel No.')
  @RegExpConstraint(expression: r'^E\d{4}$')
  final String personnelNumber;

  @ApertureField(isDisplayField: true)
  @MaxLengthConstraint(length: 50)
  final String firstName;

  @ApertureField(isDisplayField: true)
  @MaxLengthConstraint(length: 50)
  final String lastName;

  @Meta(name: 'E-mail')
  @RegExpConstraint(expression: r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$')
  final String email;

  @ApertureField(isDisplayField: true)
  @Meta(name: 'Job title')
  final String jobTitle;

  final Department department;

  @Meta(name: 'Hired')
  final DateTime hiredAt;

  @Meta(
    name: 'Hourly cost rate',
    description: 'Internal cost per hour in EUR, used for margin reports.',
  )
  @RangeConstraint(min: 0, max: 500)
  final double hourlyCostRate;

  @Meta(name: 'Weekly hours')
  @RangeConstraint(min: 0, max: 48)
  final int weeklyHours;

  final List<String> skills;

  @Meta(description: 'Spoken languages (ISO 639-1).')
  @ElementConstraint(constraint: RegExpConstraint(expression: r'^[a-z]{2}$'))
  final List<String> languages;

  @Meta(name: 'Reports to')
  @RelationId<Employee>()
  final int? managerId;

  @Meta(name: 'Fully remote')
  final bool remote;

  final bool active;
}
