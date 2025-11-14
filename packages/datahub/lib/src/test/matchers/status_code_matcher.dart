import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/rest_client.dart';
import 'package:test/expect.dart';

class StatusCodeMatcher extends Matcher {
  final Matcher statusCodeMatcher;

  StatusCodeMatcher(this.statusCodeMatcher);

  @override
  Description describe(Description description) => description
      .add('is response with status code ')
      .addDescriptionOf(statusCodeMatcher);

  @override
  bool matches(dynamic item, Map matchState) {
    return switch (item) {
      RestResponse(:final statusCode) ||
      ApiResponse(:final statusCode) ||
      HttpResponse(:final statusCode) ||
      ApiRequestException(
        :final statusCode,
      ) => statusCodeMatcher.matches(statusCode, matchState),
      _ => false,
    };
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    return switch (item) {
      RestResponse(:final statusCode) ||
      ApiResponse(:final statusCode) ||
      HttpResponse(:final statusCode) ||
      ApiRequestException(
        :final statusCode,
      ) => mismatchDescription.add('has status code <$statusCode>'),
      _ => mismatchDescription.add('is not a response type.'),
    };
  }
}
