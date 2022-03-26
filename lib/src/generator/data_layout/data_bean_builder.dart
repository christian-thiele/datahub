import 'package:analyzer/dart/element/element.dart';
import 'package:boost/boost.dart';
import 'package:cl_datahub/persistence.dart';

import 'data_bean_field.dart';

class DataBeanBuilder {
  final String layoutClass;
  final String layoutName;
  final List<Tuple<FieldElement, ParameterElement>> daoFields;

  DataBeanBuilder(this.layoutClass, this.layoutName, this.daoFields);

  Iterable<String> build() sync* {
    final fields = daoFields.map(_toDataBeanField).toList();

    final primaryKeyField =
        fields.firstOrNullWhere((f) => f.dataField is PrimaryKey);
    final primaryKeyClass = primaryKeyField?.field.type.element?.name;

    final baseClass = primaryKeyClass != null
        ? 'PKDaoDataBean<$layoutClass, $primaryKeyClass>'
        : 'DaoDataBean<$layoutClass>';

    yield 'final ${layoutClass}DataBean = _${layoutClass}DataBeanImpl._();';
    yield 'class _${layoutClass}DataBeanImpl extends $baseClass {';

    yield "@override final layoutName = '$layoutName';";
    if (primaryKeyField != null) {
      yield '@override PrimaryKey get primaryKeyField => ${primaryKeyField.field.name}Field;';
    }

    yield* buildConstConstructor();
    yield* buildFieldsAccessors(fields);
    yield* buildUnmapMethod(fields);
    yield* buildMapMethod(fields);
    yield '}';
  }

  Iterable<String> buildConstConstructor() sync* {
    yield '_${layoutClass}DataBeanImpl._();';
  }

  Iterable<String> buildUnmapMethod(List<DataBeanField> fields) sync* {
    final objectName = 'dao';
    yield '@override Map<String, dynamic> unmap($layoutClass $objectName, '
        '{bool includePrimaryKey = false}) { return {';
    for (final field in fields) {
      if (field.dataField is PrimaryKey) {
        yield 'if (includePrimaryKey)';
      }
      yield "'${field.dataField.name}': $objectName.${field.field.name},";
    }
    yield '}; }';
  }

  Iterable<String> buildMapMethod(List<DataBeanField> fields) sync* {
    final objectName = 'data';
    yield '@override $layoutClass map(Map<String, dynamic> $objectName) {';
    yield 'return $layoutClass(';
    for (final field in fields) {
      final decodingStatement = "$objectName['${field.dataField.name}']";
      if (field.parameter.isNamed) {
        yield '${field.parameter.name}: $decodingStatement,';
      } else {
        yield '$decodingStatement,';
      }
    }
    yield '); }';
  }

  DataBeanField _toDataBeanField(Tuple<FieldElement, ParameterElement> e) =>
      DataBeanField.fromElements(e.a, e.b);

  Iterable<String> buildFieldsAccessors(List<DataBeanField> fields) sync* {
    for (final field in fields) {
      final initializer = _buildInitializer(field);
      yield 'final ${field.field.name}Field = $initializer;';
    }

    yield '@override late final fields = [';
    for (final field in fields) {
      yield '${field.field.name}Field,';
    }
    yield '];';
  }

  String _buildInitializer(DataBeanField beanField) {
    final dataField = beanField.dataField;
    if (dataField is PrimaryKey) {
      return "PrimaryKey(${dataField.type}, '${dataField.name}', "
          'length: ${dataField.length}, autoIncrement: ${dataField.autoIncrement},)';
    } else if (dataField is ForeignKey) {
      if (beanField.foreignFieldAccessor == null) {
        throw Exception(
            'ForeignFieldAccessor == null, this is likely a bug in the data_bean_generator code!');
      }
      return "ForeignKey(${beanField.foreignFieldAccessor}, '${dataField.name}', "
          'nullable: ${dataField.nullable},)';
    } else {
      return "DataField(${dataField.type}, '${dataField.name}', "
          'nullable: ${dataField.nullable}, length: ${dataField.length},)';
    }
  }
}
