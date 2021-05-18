import 'dart:mirrors';
import 'package:boost/boost.dart';
import 'package:cl_datahub/persistence.dart';

/// Abstract class for defining the layout of a data table.
///
/// Supported field types are:
/// String, int, double, bool, DateTime, Uint8List
///
/// //TODO check docs from here on: (old)
/// For 1 to n relationships a [ProxySet] can be used to simplify
/// querying child objects. For a [ProxySet] to work, the parent DAO has
/// to provide a primary key using the [PrimaryKey] annotation. The child DAO
/// then has to define a foreign key using the [ForeignKey] annotation on a
/// field using the same data type as the primary key on the parent.
///
/// For 1 to 1 relationships a [ParentProxy] can be used to simplify
/// querying the related object. This can also be utilized to query the
/// parent object of a child in 1 to n relationships. See [ParentProxy] for
/// more information.
///
/// TODO maybe automate this more conveniently
/// For n to m relationships, use an intermediate DAO that represents the
/// relation between two objects, as one would in a typical relational database
/// environment.
class DataLayout {
  final String name;
  final List<DataField> fields;
  final Type? daoType;

  DataLayout(this.name, this.fields, this.daoType);

  Map<String, dynamic> unmap<TDao>(TDao dao, {bool includePrimaryKey = false}) {
    if (daoType != TDao) {
      throw MirrorException(
          'Could not unmap: Dao type "$TDao" does not match layout.');
    }

    final objectMirror = reflect(dao);

    final map = <String, dynamic>{};
    for (final field in fields) {
      if (field.daoField == null) {
        continue;
      }

      if (!includePrimaryKey && field is PrimaryKey && field.autoIncrement) {
        continue;
      }

      final value = objectMirror.getField(field.daoField!.simpleName).reflectee;
      map[field.name] = value;
    }

    return map;
  }

  TDao map<TDao>(Map<String, dynamic> data) {
    if (daoType != TDao) {
      throw MirrorException(
          'Could not map: Dao type "$TDao" does not match layout.');
    }

    final classMirror = reflectClass(TDao);
    return classMirror
        .newInstance(
            Symbol.empty,
            [],
            Map.fromEntries(fields
                .where((e) => e.daoField != null)
                .map((e) => MapEntry(e.daoField!.simpleName, data[e.name]))))
        .reflectee as TDao;
  }

  dynamic unmapField<TDao>(TDao dao, DataField field) {
    if (field.daoField == null) {
      throw MirrorException('Could not unmap field: No daoField provided.');
    }

    return reflect(dao).getField(field.daoField!.simpleName).reflectee;
  }

  DataField? getPrimaryKeyField() =>
      fields.firstOrNullWhere((f) => f is PrimaryKey);

  dynamic getPrimaryKey<TDao>(TDao entry) {
    if (daoType != TDao) {
      throw MirrorException(
          'Could not map: Dao type "$TDao" does not match layout.');
    }

    final primaryKey = getPrimaryKeyField() ??
        (throw PersistenceException('No primary key found in layout.'));

    return unmapField(entry, primaryKey);
  }
}
