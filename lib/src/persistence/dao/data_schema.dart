import 'package:cl_datahub/cl_datahub.dart';

//TODO pretty docs
// - represents group of data layouts with name and version, analog to database schema
// - can contain migrations between versions
class DataSchema {
  final String name;
  final int version;
  final List<DataLayout> layouts;

  DataSchema(this.name, this.version, this.layouts);

  Future<void> migrate(DatabaseConnection connection, int fromVersion) async {
    //TODO migration shit!
    print('Migrating $name from $fromVersion to $version.');
  }
}