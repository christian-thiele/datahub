import 'package:datahub/utils.dart';

enum HttpRequestMethod {
  get,
  post,
  put,
  patch,
  delete,
  options,
  head,
  trace;

  static HttpRequestMethod parse(String source) {
    return switch (source.toLowerCase()) {
      'get' => HttpRequestMethod.get,
      'post' => HttpRequestMethod.post,
      'put' => HttpRequestMethod.put,
      'patch' => HttpRequestMethod.patch,
      'delete' => HttpRequestMethod.delete,
      'options' => HttpRequestMethod.options,
      'head' => HttpRequestMethod.head,
      'trace' => HttpRequestMethod.trace,
      _ => throw ApiException('Could not parse method: $source'),
    };
  }
}
