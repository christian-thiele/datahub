import 'package:cl_datahub/cl_datahub.dart';

/// Provides an interface for migrating between schema versions.
///
/// A migrator implementation is provided as a parameter to
/// the [DataSchema.migrate] method.
abstract class Migrator {
  Future<void> addLayout(DataLayout layout);
  Future<void> removeLayout(String name);

  //TODO maybe accept a function to generate default values for columns?
  Future<void> addField(
      DataLayout layout, DataField field, dynamic initialValue);
  Future<void> removeField(DataLayout layout, String fieldName);

  //TODO more migration functionality
}
