import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

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
class const TimeEntry({
  @Id(auto: true) final int id = 0,
  @ApertureField(isDisplayField: true) required final DateTime date,
  @ApertureField(isDisplayField: true)
  @RangeConstraint(min: 0.25, max: 12)
  required final double hours,
  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 3)
  @MaxLengthConstraint(length: 500)
  required final String description,
  @Meta(name: 'Project') @RelationId<Project>() required final int projectId,
  @Meta(name: 'Employee') @RelationId<Employee>() required final int employeeId,
  @Meta(name: 'Service', description: 'Price agreement this time is billed on.')
  @RelationId<Product>()
  final String? productId,
  final bool billable = true,
  @Meta(description: 'Already included in an invoice.')
  final bool invoiced = false,
}) extends $TimeEntry;
