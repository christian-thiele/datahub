import 'dart:mirrors';
import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/persistence/dao/data_field.dart';

import 'package:cl_datahub/src/persistence/dao/data_layout.dart';
import 'package:cl_datahub/src/persistence/dao/mirror/dao_field.dart';
import 'package:cl_datahub/src/persistence/dao/mirror/dao_type.dart';

//TODO more docs about this whole thing

/// Creates [DataLayout] objects from dao classes using reflection.
class LayoutMirror {
  static DataLayout reflect(Type daoClass) {
    final mirror = reflectClass(daoClass);
    final layoutName = _reflectLayoutName(mirror);

    //checks and throws if multiple primary keys exist
    _findPrimaryKeyField(mirror);

    final fieldMirrors = mirror.declarations.values
        .whereType<VariableMirror>()
        .where((element) => element.isFinal);

    final fields = fieldMirrors.map((f) => _dataFieldFromField(f)).toList();

    return DataLayout(layoutName, fields);
  }

  static DataField _dataFieldFromField(VariableMirror f) {
    final fieldAnnotation = _getFieldAnnotation(f);

    final fieldType = _reflectFieldType(f);
    final fieldName = _reflectFieldName(f, fieldAnnotation);
    final fieldLength = _reflectFieldLength(f, fieldAnnotation);

    if (_isPrimaryKeyAnnotation(fieldAnnotation)) {
      if (fieldType == FieldType.Int || fieldType == FieldType.String) {
        return PrimaryKeyField(fieldType, fieldName, length: fieldLength);
      } else {
        throw Exception('Invalid field type for primary key field: $fieldType');
      }
    } else if (_isForeignKeyAnnotation(fieldAnnotation)) {
      final foreignPrimary = _getForeignPrimaryKey(fieldAnnotation!);
      final foreignPrimaryType = _reflectFieldType(foreignPrimary);
      if (fieldType != foreignPrimaryType) {
        throw Exception(
            'Foreign key field "$fieldName" does not match type of foreign primary key.');
      }

      //TODO prevent endless loop
      final foreignPrimaryDataField =
          _dataFieldFromField(foreignPrimary) as PrimaryKeyField;

      //TODO nullable property?
      return ForeignKeyField(foreignPrimaryDataField, fieldName);
    } else {
      //TODO nullable property?
      return DataField(fieldType, fieldName, length: fieldLength);
    }
  }

  static InstanceMirror? _getFieldAnnotation(VariableMirror fieldMirror) {
    return fieldMirror.metadata
        .whereType<InstanceMirror>()
        .where((element) =>
            element.type.reflectedType == DaoField ||
            element.type.reflectedType == PrimaryKeyDaoField ||
            element.type.reflectedType == ForeignKeyDaoField)
        .firstOrNull;
  }

  static bool _isPrimaryKeyAnnotation(InstanceMirror? fieldAnnotation) {
    return fieldAnnotation?.type.reflectedType == PrimaryKeyDaoField;
  }

  static bool _isForeignKeyAnnotation(InstanceMirror? fieldAnnotation) {
    return fieldAnnotation?.type.reflectedType == ForeignKeyDaoField;
  }

  static VariableMirror _getForeignPrimaryKey(InstanceMirror fieldAnnotation) {
    if (!_isForeignKeyAnnotation(fieldAnnotation)) {
      //TODO maybe add MirrorException or PersistenceException or something
      throw Exception('not a foreign key');
    }

    final foreignType =
        fieldAnnotation.getField(Symbol('foreignType')).reflectee as Type;
    final foreignMirror = reflectClass(foreignType);
    final foreignPrimaryKeyField = _findPrimaryKeyField(foreignMirror);

    if (foreignPrimaryKeyField == null) {
      throw Exception(
          'DAO "${foreignType.toString()}" does not provide a primary key.');
    } else {
      return foreignPrimaryKeyField;
    }
  }

  static VariableMirror? _findPrimaryKeyField(ClassMirror classMirror) {
    final primaryKeyAnnotations = classMirror.declarations.values
        .whereType<VariableMirror>()
        .where((element) =>
            element.isFinal &&
            element.metadata
                .any((annotation) => _isPrimaryKeyAnnotation(annotation)));

    if (primaryKeyAnnotations.length > 1) {
      throw Exception('DAO has multiple primary key fields!');
    }

    return primaryKeyAnnotations.firstOrNull;
  }

  static FieldType _reflectFieldType(VariableMirror fieldMirror) {
    final fieldType = fieldMirror.type.reflectedType;
    if (fieldType == String) {
      return FieldType.String;
    } else if (fieldType == int) {
      return FieldType.Int;
    } else if (fieldType == double) {
      return FieldType.Double;
    } else if (fieldType == bool) {
      return FieldType.Bool;
    } else if (fieldType == DateTime) {
      return FieldType.DateTime;
    } else {
      //TODO maybe add MirrorException or PersistenceException or something
      throw ApiError.invalidType(fieldType);
    }
  }

  static String _reflectFieldName(
      VariableMirror fieldMirror, InstanceMirror? annotation) {
    if (annotation != null) {
      final nameInstance = annotation.getField(Symbol('name'));
      if (nameInstance.reflectee is String) {
        return nameInstance.reflectee;
      }
    }

    return MirrorSystem.getName(fieldMirror.simpleName);
  }

  static int _reflectFieldLength(
      VariableMirror fieldMirror, InstanceMirror? annotation) {
    if (annotation != null) {
      final nameInstance = annotation.getField(Symbol('length'));
      if (nameInstance.reflectee is int) {
        return nameInstance.reflectee;
      }
    }

    return DataField.getDefaultLength(_reflectFieldType(fieldMirror));
  }

  static String _reflectLayoutName(ClassMirror classMirror) {
    final daoTypeAnnotation = classMirror.metadata
        .whereType<InstanceMirror>()
        .where((element) => element.type.reflectedType == DaoType)
        .firstOrNull;

    if (daoTypeAnnotation != null) {
      final nameInstance = daoTypeAnnotation.getField(Symbol('name'));
      if (nameInstance.reflectee is String) {
        return nameInstance.reflectee;
      }
    }

    return MirrorSystem.getName(classMirror.simpleName);
  }
}
