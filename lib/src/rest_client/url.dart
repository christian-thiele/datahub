import 'package:datahub/utils.dart';

final RegExp _plExp = RegExp('(?<!\\\\)\\{([\\w-]*)}');

String replacePlaceholders(String source, Map<String, dynamic> values) {
  return source.replaceAllMapped(_plExp, (match) {
    final key = match.group(1);
    if (key == null) {
      throw ApiException('Invalid placeholder-key: ${match.group(0)}');
    }

    if (values[key] == null) {
      throw ApiException('Missing value in url params: $key');
    }

    return Uri.encodeComponent(values[key].toString());
  });
}
