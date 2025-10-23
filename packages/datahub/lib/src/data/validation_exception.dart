import 'package:datahub/utils.dart';

import 'data_field.dart';
import 'meta/data_field_constraint.dart';

class ValidationException extends ApiRequestException {
  final Map<DataField, List<DataFieldConstraint>> violatedConstraints;

  ValidationException(this.violatedConstraints)
    : super(
        400,
        'Invalid values for fields: ${violatedConstraints.keys.map((e) => e.name).join(', ')}',
        data: {
          'fields': {
            for (final (field, constraints) in violatedConstraints.tuples)
              field.name: [
                for (final constraint in constraints) constraint.name,
              ],
          },
        },
      );
}
