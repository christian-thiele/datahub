import 'package:datahub/datahub.dart';

String translateName(String name) {
  return toNamingConvention(name, NamingConvention.lowerSnakeCase);
}
