import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';

String filterDescription(FilterModel model) {
  final buffer = StringBuffer();
  buffer.write(model.field.name);
  buffer.write(switch (model.type) {
    ResourceFilterType.equals => ' = ',
    ResourceFilterType.notEquals => ' ≠ ',
    ResourceFilterType.greaterThan => ' > ',
    ResourceFilterType.lessThan => ' <',
    ResourceFilterType.contains => ' ≈ ',
  });
  buffer.write(model.value.toString());
  return buffer.toString();
}

ResourceFilter buildFilter(
  ResourceRelationFilter relationFilter,
  ResourceData data,
) {
  final value = relationFilter.valueFieldId != null
      ? data.fieldData[relationFilter.valueFieldId]
      : relationFilter.value;

  return ResourceFilter(
    and: [
      for (final child in relationFilter.and ?? []) buildFilter(child, data),
    ],
    or: [for (final child in relationFilter.or ?? []) buildFilter(child, data)],
    type: value != null ? relationFilter.type : null,
    fieldId: value != null ? relationFilter.fieldId : null,
    value: value?.toString(),
  );
}

bool filterMatches(ResourceData e, ResourceFilter? filter) {
  if (filter == null) {
    return true;
  }

  if (filter case ResourceFilter(:final type?, :final fieldId?, :final value)) {
    final fieldValue = e.fieldData[fieldId];
    switch (type) {
      case ResourceFilterType.equals:
        if (fieldValue.toString() != value.toString()) {
          return false;
        }
      case ResourceFilterType.notEquals:
        if (fieldValue.toString() == value.toString()) {
          return false;
        }
      case ResourceFilterType.greaterThan:
        throw UnimplementedError();
      case ResourceFilterType.lessThan:
        throw UnimplementedError();
      case ResourceFilterType.contains:
        if (value == null) {
          return false;
        }
        if (!fieldValue.toString().contains(value)) {
          return false;
        }
    }
  }

  if ((filter.and?.isNotEmpty ?? false) &&
      filter.and!.any((f) => !filterMatches(e, f))) {
    return false;
  }

  if ((filter.or?.isNotEmpty ?? false) &&
      filter.or!.every((f) => !filterMatches(e, f))) {
    return false;
  }

  return true;
}

String? validateFieldValue(ResourceField field, dynamic value) {
  if (field.readOnly) {
    return null;
  }

  if (value == null || value.toString().isEmpty) {
    if (field.nullable) {
      return null;
    } else {
      return S.current.validationRequired;
    }
  }

  if (field.length case final length?) {
    if (value.toString().length > length) {
      return S.current.validationMaxLength(length);
    }
  }

  if (field.validation case final expression?) {
    if (!RegExp(expression).hasMatch(value.toString())) {
      return S.current.validationPattern(expression);
    }
  }

  return null;
}
