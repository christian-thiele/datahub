import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';
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

// dirty little hack
void decodeFieldData(ResourceDescription resource, ResourceData data) {
  final decoded = {
    for (final (key, value) in data.fieldData.tuples)
      key: _decodeField(
        resource.fields.where((e) => e.id == key).firstOrNull,
        null,
        value,
        name: key,
      ),
  };
  data.fieldData.addAll(decoded);
}

dynamic _decodeField(
  ResourceField? field,
  ResourceFieldType? type,
  dynamic raw, {
  String? name,
}) {
  final codec = const JsonDataCodec();
  final elementField = field?.objectDescription
      ?.where((e) => e.id == '\$element')
      .firstOrNull;

  return switch (type ?? field?.type) {
    ResourceFieldType.string => codec.decodeString(raw, name: name),
    ResourceFieldType.stringEnum => codec.decodeString(raw, name: name),
    ResourceFieldType.int => codec.decodeInt(raw, name: name),
    ResourceFieldType.double => codec.decodeDouble(raw, name: name),
    ResourceFieldType.bool => codec.decodeBool(raw, name: name),
    ResourceFieldType.timestamp => codec.decodeDateTime(raw, name: name),
    ResourceFieldType.bytes => codec.decodeUint8List(raw, name: name),
    ResourceFieldType.geometry => codec.decodeGeometry(raw, name: name),
    ResourceFieldType.object => codec.decodeDynamic(raw, name: name),
    ResourceFieldType.list =>
      elementField != null
          ? codec.decodeList(
              raw,
              (e, {String? name}) =>
                  _decodeField(field, elementField.type, e, name: name),
            )
          : codec.decodeDynamic(raw, name: name),
    _ => codec.decodeDynamic(raw, name: name),
  };
}

extension ResourceDescriptionExtension on ResourceDescription {
  ResourceField getField(String id) => fields.firstWhere(
    (e) => e.id == id,
    orElse: () =>
        throw Exception('Could not find field $id on resource ${this.id}.'),
  );
}
