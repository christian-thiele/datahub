import 'package:cl_datahub/cl_datahub.dart';

//TODO docs
class DataScheme {
  final String name;
  final int version;
  final List<DataLayout> layouts;

  DataScheme(this.name, this.version, this.layouts);
}
