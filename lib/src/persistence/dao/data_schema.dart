import 'package:cl_datahub/cl_datahub.dart';

//TODO pretty docs
// - represents group of data layouts with name and version, analog to database schema
// - can contain migrations between versions
class DataSchema {
  final String name;
  final int version;
  final List<DataLayout> layouts;

  DataSchema(this.name, this.version, this.layouts);

  //TODO automatic migration
  Future<void> migrate(Migrator migrator, int fromVersion) async {
    resolve<LogService>().warn(
        'Schema "$name" changes from version $fromVersion to $version but no migration is implemented!',
        sender: 'DataHub');
  }
}
