import 'package:boost/boost.dart';
import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/json_editor/model/json_value.dart';

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

  if (describeJsonError(S.current, value, root: field.jsonRoot)
      case final error?) {
    return error;
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

String getElementTitle(ResourceDescription resource, ResourceData element) {
  if (resource.titleTemplate case final template?) {
    return renderTemplate(resource, element, template);
  }

  if (resource.displayFields.firstOrNull case final field?) {
    return fieldValueToDisplayText(
      resource.fields.singleWhere((e) => e.id == field),
      element.fieldData[field],
    );
  }

  return element.id;
}

String renderTemplate(
  ResourceDescription resource,
  ResourceData element,
  String template,
) {
  return template.replaceAllMapped(RegExp('{{\\W*([a-zA-Z_]+)\\W*}}'), (match) {
    if (resource.fields.where((e) => e.id == match.group(1)!).singleOrNull
        case final field?) {
      return fieldValueToDisplayText(field, element.fieldData[field.id]);
    }

    return '???';
  });
}

String fieldValueToDisplayText(ResourceField field, dynamic data) {
  return switch (field) {
    ResourceField(type: ResourceFieldType.timestamp) when data is DateTime =>
      data.formatDateTime(),
    ResourceField(type: ResourceFieldType.bytes) when data is List<int> =>
      formatFileSize(data.length),
    ResourceField(
      type: ResourceFieldType.list,
      objectDescription: [final elementField],
    )
        when data is List =>
      data.map((e) => fieldValueToDisplayText(elementField, e)).join(', '),
    _ => data.toString(),
  };
}

/// Explains why [value] can not be saved from a JSON editor that has to hold
/// a [root] value, `null` if it can.
///
/// [value] may also be a map or list with JSON editor values in it, where the
/// editors are part of an object or list field.
String? describeJsonError(S s, dynamic value, {JsonRootType? root}) {
  if (findInvalidJson(value) case final invalid?) {
    if (invalid.error case final error?) {
      final (line, column) = error.positionIn(invalid.text);
      return s.validationJsonSyntax(line, column);
    }
    return s.validationJson;
  }

  if (root != null && value != null && !root.accepts(value)) {
    return switch (root) {
      JsonRootType.object => s.validationJsonObject,
      JsonRootType.array => s.validationJsonArray,
    };
  }

  return null;
}

/// Whether two field values are equal, comparing maps and lists by content.
bool fieldValueEquals(dynamic a, dynamic b) => switch ((a, b)) {
  (final Map a, final Map b) => a.equalsDeep(b),
  (final List a, final List b) => a.equalsDeep(b),
  _ => a == b,
};

/// The path of element [index] of the list at [path].
///
/// Paths name values like the backend names them in its errors: a field of a
/// resource by its id, and values nested in it with [elementPath] and
/// [memberPath], like `periods[0].start`.
String elementPath(String path, int index) => DataCodec.indexName(path, index)!;

/// The path of [member] of the object at [path], see [elementPath].
String memberPath(String path, String member) =>
    DataCodec.childName(path, member)!;

/// The id of the field the value at [path] belongs to, see [elementPath].
String fieldIdOf(String path) => path.split(_pathSeparator).first;

final _pathSeparator = RegExp(r'[.\[]');

/// Whether [path] is [parent] or the path of a value nested in it.
bool isPathWithin(String path, String parent) =>
    path == parent ||
    path.startsWith('$parent.') ||
    path.startsWith('$parent[');

/// Whether [errors] (by path) hold errors of values nested in the value at
/// [path].
bool hasNestedErrors(Map<String, String> errors, String path) =>
    errors.keys.any((e) => e != path && isPathWithin(e, path));

/// The field errors a request failed with, by the path of the value they
/// belong to (see [elementPath]).
///
/// Returns `null` if [error] is no such failure, or if it is about a value
/// that is not part of the editable [fields], as it can not be shown at a
/// field then.
Map<String, String>? editableFieldErrors(
  Object error,
  Iterable<ResourceField> fields,
) {
  if (error case ApiRequestException(
    data: {'fields': final Map<String, dynamic> errors},
  ) when errors.isNotEmpty) {
    final messages = <String, String>{};
    for (final (path, pathMessages) in errors.tuples) {
      final id = fieldIdOf(path);
      if (fields.where((e) => e.id == id).firstOrNull case ResourceField(
        readOnly: false,
      )) {
        messages[path] = switch (pathMessages) {
          [final message, ...] => message.toString(),
          _ => pathMessages.toString(),
        };
      } else {
        return null;
      }
    }
    return messages;
  }

  return null;
}

// dirty little hack
void decodeFieldData(ResourceDescription resource, ResourceData data) {
  final decoded = {
    for (final (key, value) in data.fieldData.tuples)
      key: _decodeField(
        resource.fields.where((e) => e.id == key).firstOrNull,
        value,
        name: key,
      ),
  };
  data.fieldData.addAll(decoded);
}

dynamic _decodeField(ResourceField? field, dynamic raw, {String? name}) {
  if (raw == null) {
    return null;
  }

  final codec = const JsonDataCodec();
  ResourceField? child(String id) =>
      field?.objectDescription?.where((e) => e.id == id).firstOrNull;

  return switch (field?.type) {
    ResourceFieldType.string => codec.decodeString(raw, name: name),
    ResourceFieldType.stringEnum => codec.decodeString(raw, name: name),
    ResourceFieldType.int => codec.decodeInt(raw, name: name),
    ResourceFieldType.double => codec.decodeDouble(raw, name: name),
    ResourceFieldType.bool => codec.decodeBool(raw, name: name),
    ResourceFieldType.timestamp => codec.decodeDateTime(raw, name: name),
    ResourceFieldType.bytes => codec.decodeUint8List(raw, name: name),
    ResourceFieldType.geometry => codec.decodeGeometry(raw, name: name),
    ResourceFieldType.object when raw is Map<String, dynamic> => {
      for (final (key, value) in raw.tuples)
        key: _decodeField(
          child(key),
          value,
          name: DataCodec.childName(name, key),
        ),
    },
    // Not decodeList, which returns a List<dynamic> as it is, without
    // decoding its elements.
    ResourceFieldType.list when raw is List => [
      for (final (index, element) in raw.indexed)
        _decodeField(
          child('element'),
          element,
          name: DataCodec.indexName(name, index),
        ),
    ],
    _ => codec.decodeDynamic(raw, name: name),
  };
}

extension ResourceDescriptionExtension on ResourceDescription {
  // ignore: unused_element
  ResourceField? _fieldOf(ResourceField? parent, String path) {
    final parts = path.split('.');
    final ResourceField? field;
    if (parent == null) {
      field = fields.where((e) => e.id == parts.first).firstOrNull;
    } else {
      field = parent.objectDescription
          ?.where((e) => e.id == parts.first)
          .firstOrNull;
    }

    if (parts.length > 1 && field != null) {
      return _fieldOf(field, parts.skip(1).join('.'));
    } else {
      return field;
    }
  }

  ResourceField getField(String id) => fields.firstWhere(
    (e) => e.id == fieldIdOf(id),
    orElse: () =>
        throw Exception('Could not find field $id on resource ${this.id}.'),
  );
}

extension ResourceFieldExtension on ResourceField {
  /// The kind of value a JSON field holds, `null` for other fields.
  JsonRootType? get jsonRoot => switch (type) {
    ResourceFieldType.jsonMap => JsonRootType.object,
    ResourceFieldType.jsonList => JsonRootType.array,
    _ => null,
  };
}
