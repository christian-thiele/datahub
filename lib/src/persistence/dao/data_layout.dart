import 'package:cl_datahub/src/persistence/dao/data_field.dart';

/// Abstract class for defining the layout of a data table.
///
/// Supported field types are:
/// String, int, double, bool, DateTime
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

  DataLayout(this.name, this.fields);
}
