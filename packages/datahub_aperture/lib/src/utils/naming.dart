import 'package:datahub/utils.dart';

String niceName(String name) {
  return splitWords(
    name,
  ).map(firstUpper).map((e) => (e == 'Id') ? 'ID' : e).join(' ');
}
