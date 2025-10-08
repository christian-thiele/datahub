import 'package:datahub/http.dart';
import 'api_request.dart';

abstract interface class RouteMatcher {
  const RouteMatcher();

  bool matches(ApiRequest request);

  Map<String, String> getRouteParams(ApiRequest request);
}

class AllOfRouteMatcher implements RouteMatcher {
  final List<RouteMatcher> matchers;

  const AllOfRouteMatcher({required this.matchers});

  @override
  bool matches(ApiRequest request) =>
      matchers.every((matcher) => matcher.matches(request));

  @override
  Map<String, String> getRouteParams(ApiRequest request) => {
    for (final matcher in matchers) ...matcher.getRouteParams(request),
  };
}

class AnyOfRouteMatcher implements RouteMatcher {
  final List<RouteMatcher> matchers;

  const AnyOfRouteMatcher({required this.matchers});

  @override
  bool matches(ApiRequest request) =>
      matchers.any((matcher) => matcher.matches(request));

  @override
  Map<String, String> getRouteParams(ApiRequest request) => {
    for (final matcher in matchers.where((matcher) => matcher.matches(request)))
      ...matcher.getRouteParams(request),
  };
}

class AnyRouteMatcher implements RouteMatcher {
  const AnyRouteMatcher();

  @override
  bool matches(ApiRequest _) => true;

  @override
  Map<String, String> getRouteParams(ApiRequest request) => {};
}

class MethodRouteMatcher implements RouteMatcher {
  final HttpRequestMethod method;

  const MethodRouteMatcher({required this.method});

  @override
  bool matches(ApiRequest request) => request.method == method;

  @override
  Map<String, String> getRouteParams(ApiRequest request) => {};
}
