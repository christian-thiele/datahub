import 'package:datahub/datahub.dart';

/// Provides an interface for migrating between schema versions.
///
/// A migrator implementation is provided as a parameter to
/// the [DataSchema.migrate] method.
abstract class Migrator {
  Future<void> addLayout(BaseDataBean bean);
  Future<void> removeLayout(String name);

  //TODO maybe accept a function to generate default values for columns?
  Future<void> addField(
      BaseDataBean bean, DataField field, dynamic initialValue);
  Future<void> removeField(BaseDataBean bean, String fieldName);

  @Deprecated('This method assumes that the adapter supports SQL, '
      'as well as the specific dialect you are using. Only use this method '
      'when you know the adapter implementation you are using.')
  Future<void> customSql(String sql) => throw UnimplementedError();

  //TODO more migration functionality
}
