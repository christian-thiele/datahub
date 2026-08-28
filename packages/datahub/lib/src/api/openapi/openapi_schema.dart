import 'dart:typed_data';

import 'package:boost/boost.dart';

import 'package:datahub/data.dart';

/// Collects OpenAPI schemas derived from [DataBean]s for the
/// `components/schemas` section of an OpenAPI document.
class OpenApiSchemaRegistry {
  final Map<String, Map<String, dynamic>> _schemas = {};

  /// All registered schemas, keyed by bean name.
  Map<String, Map<String, dynamic>> get schemas => Map.unmodifiable(_schemas);

  /// Registers [bean] (transitively including nested beans) and returns a
  /// `$ref` object pointing to its schema.
  Map<String, dynamic> referenceBean(DataBean bean) {
    if (!_schemas.containsKey(bean.name)) {
      // placeholder breaks cycles between mutually referencing beans
      _schemas[bean.name] = {};
      _schemas[bean.name] = _beanSchema(bean);
    }
    return {'\$ref': '#/components/schemas/${bean.name}'};
  }

  /// Builds the schema of a single [DataField].
  Map<String, dynamic> schemaForField(DataField field) {
    final schema = _fieldSchema(field);
    final meta = field.metaOfType<Meta>();
    if (field.type.isNullable && schema.containsKey('\$ref')) {
      // $ref does not allow sibling keywords in OpenAPI 3.0
      return {
        'nullable': true,
        if (meta?.description case final description?)
          'description': description,
        'allOf': [schema],
      };
    }
    return {
      ...schema,
      if (field.type.isNullable) 'nullable': true,
      if (meta?.description case final description?) 'description': description,
    };
  }

  /// Builds a schema for a plain type, e.g. of a query parameter.
  Map<String, dynamic> schemaForType(TypeCheck type) {
    if (type.isSubtypeOf<String?>()) {
      return {'type': 'string'};
    } else if (type.isSubtypeOf<int?>()) {
      return {'type': 'integer'};
    } else if (type.isSubtypeOf<double?>()) {
      return {'type': 'number'};
    } else if (type.isSubtypeOf<bool?>()) {
      return {'type': 'boolean'};
    } else if (type.isSubtypeOf<DateTime?>()) {
      return {'type': 'string', 'format': 'date-time'};
    } else if (type.isSubtypeOf<Duration?>()) {
      return {'type': 'integer', 'description': 'Duration in milliseconds.'};
    } else if (type.isSubtypeOf<Uint8List?>()) {
      return {'type': 'string', 'format': 'byte'};
    } else if (type.isSubtypeOf<List<String>?>()) {
      return {
        'type': 'array',
        'items': {'type': 'string'},
      };
    } else if (type.isSubtypeOf<List<int>?>()) {
      return {
        'type': 'array',
        'items': {'type': 'integer'},
      };
    } else if (type.isSubtypeOf<List<double>?>()) {
      return {
        'type': 'array',
        'items': {'type': 'number'},
      };
    } else if (type.isSubtypeOf<List<bool>?>()) {
      return {
        'type': 'array',
        'items': {'type': 'boolean'},
      };
    } else {
      return {};
    }
  }

  Map<String, dynamic> _beanSchema(DataBean bean) {
    final meta = bean.metaOfType<Meta>();
    final required = [
      for (final field in bean.fields)
        if (!field.type.isNullable) field.name,
    ];
    return {
      'type': 'object',
      if (meta?.name case final title?) 'title': title,
      if (meta?.description case final description?) 'description': description,
      'properties': {
        for (final field in bean.fields) field.name: schemaForField(field),
      },
      if (required.isNotEmpty) 'required': required,
    };
  }

  Map<String, dynamic> _fieldSchema(DataField field) {
    return switch (field) {
      DataField<dynamic, String?>() => {
        'type': 'string',
        ..._constraintKeywords(field.constraints),
      },
      DataField<dynamic, Enum?>() => {
        'type': 'string',
        ..._constraintKeywords(field.constraints),
      },
      DataField<dynamic, int?>() => {
        'type': 'integer',
        ..._constraintKeywords(field.constraints),
      },
      DataField<dynamic, double?>() => {
        'type': 'number',
        ..._constraintKeywords(field.constraints),
      },
      DataField<dynamic, bool?>() => {'type': 'boolean'},
      DataField<dynamic, DateTime?>() => {
        'type': 'string',
        'format': 'date-time',
      },
      DataField<dynamic, Duration?>() => {
        'type': 'integer',
        'description': 'Duration in milliseconds.',
      },
      DataField<dynamic, Uint8List?>() => {'type': 'string', 'format': 'byte'},
      DataField<dynamic, Geometry?>() => {
        'type': 'string',
        'format': 'byte',
        'description': 'EWKB geometry, base64 encoded.',
      },
      DataField<dynamic, DataObject?>() when field.dataBean != null =>
        referenceBean(field.dataBean!),
      DataField<dynamic, List?>() => {
        'type': 'array',
        'items': _listItemSchema(field),
      },
      DataField<dynamic, Map?>() => {
        'type': 'object',
        'additionalProperties': true,
      },
      _ => {},
    };
  }

  Map<String, dynamic> _listItemSchema(DataField field) {
    if (field.dataBean case final bean?) {
      return referenceBean(bean);
    }

    final elementConstraints = [
      for (final constraint in field.constraints)
        if (constraint is ElementConstraint) constraint.constraint,
    ];

    return switch (field) {
      DataField<dynamic, List<String>?>() => {
        'type': 'string',
        ..._constraintKeywords(elementConstraints),
      },
      DataField<dynamic, List<Enum>?>() => {
        'type': 'string',
        ..._constraintKeywords(elementConstraints),
      },
      DataField<dynamic, List<int>?>() => {
        'type': 'integer',
        ..._constraintKeywords(elementConstraints),
      },
      DataField<dynamic, List<double>?>() => {
        'type': 'number',
        ..._constraintKeywords(elementConstraints),
      },
      DataField<dynamic, List<bool>?>() => {'type': 'boolean'},
      DataField<dynamic, List<DateTime>?>() => {
        'type': 'string',
        'format': 'date-time',
      },
      DataField<dynamic, List<Duration>?>() => {
        'type': 'integer',
        'description': 'Duration in milliseconds.',
      },
      DataField<dynamic, List<Uint8List>?>() => {
        'type': 'string',
        'format': 'byte',
      },
      DataField<dynamic, List<Geometry>?>() => {
        'type': 'string',
        'format': 'byte',
        'description': 'EWKB geometry, base64 encoded.',
      },
      _ => {},
    };
  }

  Map<String, dynamic> _constraintKeywords(
    Iterable<DataFieldConstraint> constraints,
  ) {
    final result = <String, dynamic>{};
    for (final constraint in constraints) {
      result.addAll(switch (constraint) {
        MinLengthConstraint(:final length) => {'minLength': length},
        MaxLengthConstraint(:final length) => {'maxLength': length},
        RangeConstraint(:final min, :final max) => {
          'minimum': min,
          'maximum': max,
        },
        RegExpConstraint(:final expression) => {'pattern': expression},
        EnumConstraint(:final values) => {
          'enum': [
            for (final value in values) const JsonDataCodec().encodeEnum(value),
          ],
        },
        _ => const <String, dynamic>{},
      });
    }
    return result;
  }
}
