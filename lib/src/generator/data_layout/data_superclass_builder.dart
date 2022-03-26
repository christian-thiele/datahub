import 'package:analyzer/dart/element/element.dart';
import 'package:boost/boost.dart';
import 'package:cl_datahub/persistence.dart';

import 'data_bean_field.dart';

class DataSuperclassBuilder {
  final String layoutClass;
  final List<Tuple<FieldElement, ParameterElement>> daoFields;

  DataSuperclassBuilder(this.layoutClass, this.daoFields);

  Iterable<String> build() sync* {
    final fields = daoFields.map(_toDataBeanField).toList();
    final primaryKeyField =
        fields.firstOrNullWhere((f) => f.dataField is PrimaryKey);
    final primaryKeyClass = primaryKeyField?.field.type.element?.name;

    final baseClass = primaryKeyClass != null
        ? 'PKBaseDao<$layoutClass, $primaryKeyClass>'
        : 'BaseDao<$layoutClass>';

    yield 'abstract class _Dao extends $baseClass {';
    yield '@override _${layoutClass}DataBeanImpl get bean => ${layoutClass}DataBean;';
    if (primaryKeyClass != null) {
      yield* buildGetPrimaryKeyMethod(primaryKeyField!);
    }
    yield '}';
  }

  Iterable<String> buildGetPrimaryKeyMethod(
      DataBeanField primaryKeyField) sync* {
    final primaryKeyClass = primaryKeyField.field.type.element!.name;
    yield '@override $primaryKeyClass getPrimaryKey() => '
        '(this as $layoutClass).${primaryKeyField.field.name};';
  }
}

DataBeanField _toDataBeanField(Tuple<FieldElement, ParameterElement> e) =>
    DataBeanField.fromElements(e.a, e.b);
