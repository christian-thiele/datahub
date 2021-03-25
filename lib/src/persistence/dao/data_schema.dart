import 'package:cl_datahub/cl_datahub.dart';

//TODO docs
class DataSchema {
  final String name;
  final int version;
  final List<DataLayout> layouts;

  DataSchema(this.name, this.version, this.layouts);

  Future<void> migrate(DatabaseConnection connection, int fromVersion) async {
    //TODO migration shit!
  }
}
