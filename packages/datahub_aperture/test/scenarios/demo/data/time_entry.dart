import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/data/meta/aperture_meta.dart';

import 'employee.dart';
import 'product.dart';
import 'project.dart';

part 'time_entry.g.dart';

@Data()
@Meta(
  name: 'Time entry',
  namePlural: 'Timesheet',
  icon: Icons.timer,
  description: 'Booked working hours.',
)
@ApertureMeta(titleTemplate: '{{ hours }} h · {{ description }}')
class TimeEntry extends $TimeEntry {
  const TimeEntry({
    this.id = 0,
    required this.date,
    required this.hours,
    required this.description,
    required this.projectId,
    required this.employeeId,
    this.productId,
    this.billable = true,
    this.invoiced = false,
  });

  @Id(auto: true)
  final int id;

  @ApertureField(isDisplayField: true)
  final DateTime date;

  @ApertureField(isDisplayField: true)
  @RangeConstraint(min: 0.25, max: 12)
  final double hours;

  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 3)
  @MaxLengthConstraint(length: 500)
  final String description;

  @Meta(name: 'Project')
  @RelationId<Project>()
  final int projectId;

  @Meta(name: 'Employee')
  @RelationId<Employee>()
  final int employeeId;

  @Meta(name: 'Service', description: 'Price agreement this time is billed on.')
  @RelationId<Product>()
  final String? productId;

  final bool billable;

  @Meta(description: 'Already included in an invoice.')
  final bool invoiced;
}
