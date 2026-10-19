import 'package:datahub/http.dart';

import 'api_request.dart';

abstract interface class const RouteMatcher() {
  bool matches(ApiRequest request);

  Map<String, String> getRouteParams(ApiRequest request);
}

class const AllOfRouteMatcher({required final List<RouteMatcher> matchers})
    implements RouteMatcher {
  @override
  bool matches(ApiRequest request) =>
      matchers.every((matcher) => matcher.matches(request));

  @override
  Map<String, String> getRouteParams(ApiRequest request) => {
    for (final matcher in matchers) ...matcher.getRouteParams(request),
  };
}

class const AnyOfRouteMatcher({required final List<RouteMatcher> matchers})
    implements RouteMatcher {
  @override
  bool matches(ApiRequest request) =>
      matchers.any((matcher) => matcher.matches(request));

  @override
  Map<String, String> getRouteParams(ApiRequest request) => {
    for (final matcher in matchers.where((matcher) => matcher.matches(request)))
      ...matcher.getRouteParams(request),
  };
}

class const AnyRouteMatcher() implements RouteMatcher {
  @override
  bool matches(ApiRequest _) => true;

  @override
  Map<String, String> getRouteParams(ApiRequest request) => {};
}

class const MethodRouteMatcher({required final HttpRequestMethod method})
    implements RouteMatcher {
  @override
  bool matches(ApiRequest request) => request.method == method;

  @override
  Map<String, String> getRouteParams(ApiRequest request) => {};
}

class const HeaderRouteMatcher({
  required final String header,
  final String? value,
}) implements RouteMatcher {
  @override
  bool matches(ApiRequest request) {
    if (request.headers[header] case final headerValue?) {
      if (value == null || headerValue.contains(value)) {
        return true;
      }
    }
    return false;
  }

  @override
  Map<String, String> getRouteParams(ApiRequest request) => {};
}
