import 'package:datahub/utils.dart';

enum ApiRequestMethod {
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
  OPTIONS,
  HEAD,
  TRACE;

  static ApiRequestMethod parse(String source) {
    return switch (source.toLowerCase()) {
      'get' => ApiRequestMethod.GET,
      'post' => ApiRequestMethod.POST,
      'put' => ApiRequestMethod.PUT,
      'patch' => ApiRequestMethod.PATCH,
      'delete' => ApiRequestMethod.DELETE,
      'options' => ApiRequestMethod.OPTIONS,
      'head' => ApiRequestMethod.HEAD,
      'trace' => ApiRequestMethod.TRACE,
      _ => throw ApiException('Could not parse method: $source')
    };
  }
}
