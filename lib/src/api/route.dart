import 'package:boost/boost.dart';
import 'package:cl_datahub/api.dart';
import 'package:cl_datahub_common/common.dart';

const _wildcardGroup = '_route_wildcard';
const _prefixGroup = '_prefix';
const _keyGroup = '_key';
const _optionalGroup = '_optional';

// placeholder detector regex
final RegExp _plExp = RegExp(
    '^(?<$_prefixGroup>[\\w\\.-]*){((?<$_keyGroup>[\\w-]+)(?<$_optionalGroup>\\??))}\$');

// route pattern validation regex
final RegExp _vrExp = RegExp(
    '^(\\/([\\w\\\\.-]+|[\\w\\\\.-]*((?<!\\\\){([\\w-]+)\\??})))*(\\/\\*?)?\/?\$');

/// Represents a route pattern against which request paths will be matched.
///
/// [RoutePattern]s are defined using a specific syntax. They can contain
/// placeholders for parts of the route which can be read by the endpoint.
/// Invalid route patterns will throw an [ApiError].
///
/// *Examples:*
/// `/path/to/endpoint`
/// `/users/joe`
///
/// __Placeholders:__
///
/// Placeholders can be used to create a dynamic route pattern. In this example
/// we create the pattern for a user endpoint:
///
/// *Examples:*
/// `/users/{name}`
/// `/users/{name}/pictures`
/// `/texts/article_{article_id}`
///
/// *The placeholder `{name}` will allow anything as long as it is a single
/// path segment.*
/// Placeholder keys can only contain the characters `a-z, 0-9, _, -`. No white
/// space, slashes or other special characters allowed.
///
/// For the route pattern
/// `/users/{name}/pictures`
/// the following path will match:
/// `/users/joe/pictures`
/// and the following will not:
/// `/users/pictures`
/// `/users/two/segments/pictures`
///
/// Multiple Placeholders can be used in a single route and placeholders
/// can also have a prefix:
/// `/category/{category_name}/article_{article_id}`
///
/// Against the example pattern above following routes will match:
/// `/category/fiction/article_2354`
/// `/category/science/article_abc`
/// while the following will not:
/// `/category/article_2354`
/// `/category/science/article_`
///
/// For more flexible matching, placeholders can also be defined as optional
/// by appending a question mark to the name:
///
/// `/articles/{articleId?}`
///
/// __Wildcard-Suffix__
///
/// All of the examples above are closed routes, which means that they have
/// to match in full length with the path to match at all.
///
/// Example route:
/// `/path/{x}/something`
/// This path will match:
/// `/path/to/something`
/// This one will not:
/// `/path/to/something/else`
///
/// If sub-paths are required to match the pattern also, a wildcard suffix can
/// be used. *Wildcard suffix only work at the end of the pattern!*
///
/// Example route:
/// `/path/{x}/something/*`
/// This paths will match:
/// `/path/to/something`
/// `/path/to/something/else`
/// `/path/to/something/else/and/more`
///
/// The segments matched by the wildcard-suffix is also stored in the [Route]
/// object. See [Route.wildcard]
class RoutePattern {
  final String pattern;
  final List<_Segment> _segments;
  final RegExp routeMatchExp;
  final bool isWildcardPattern;

  static final any =
      RoutePattern._('*', [_WildcardSegment()], RegExp(r'.*'), true);

  const RoutePattern._(
      this.pattern, this._segments, this.routeMatchExp, this.isWildcardPattern);

  factory RoutePattern(String pattern) {
    if (!_vrExp.hasMatch(pattern)) {
      throw ApiError('Invalid route pattern: $pattern');
    }

    final patternSegments = pattern.split('/').where((s) => !nullOrEmpty(s));
    final segments = <_Segment>[];
    var hasWildcard = false;
    for (final segment in patternSegments) {
      final plMatch = _plExp.firstMatch(segment);
      if (plMatch != null) {
        segments.add(_PLSegment(
            segment,
            plMatch.namedGroup(_prefixGroup)!,
            plMatch.namedGroup(_keyGroup)!,
            plMatch.namedGroup(_optionalGroup)!.isNotEmpty));
        continue;
      }

      if (segment == '*') {
        segments.add(_WildcardSegment());
        hasWildcard = true;
        break;
      }

      segments.add(_Segment(segment));
    }

    final matchExp = RegExp(
        '^' + segments.map((s) => s.toMatchExp()).join() + '\\/?\$',
        caseSensitive: false);

    return RoutePattern._(pattern, segments, matchExp, hasWildcard);
  }

  /// Encodes url params into a path.
  String encode(Map<String, dynamic> values) {
    //TODO add encode method for values, not just toString
    final stringValues =
        values.map((key, value) => MapEntry(key, value.toString()));
    return _segments.map((s) => s.encode(stringValues)).join();
  }

  /// Decodes a path using the route pattern.
  ///
  /// Path parameters will be stored in the returned [Route] object.
  Route decode(String path) {
    final match = routeMatchExp.firstMatch(path);
    if (match == null) {
      throw ApiException('Could not match pattern.');
    }

    final pathParams = Map.fromEntries(match.groupNames
        .where((e) => e != _wildcardGroup)
        .map((e) =>
            (match.groupNames.contains(e) && match.namedGroup(e) != null)
                ? MapEntry(e, Uri.decodeComponent(match.namedGroup(e)!))
                : null)
        .whereNotNull);

    final wildcard = match.groupNames.contains(_wildcardGroup)
        ? match.namedGroup(_wildcardGroup)
        : null;

    return Route(this, path, pathParams, wildcard);
  }

  bool match(String path) => routeMatchExp.hasMatch(path);

  /// Checks if there is a placeholder param with the given key in the pattern.
  bool containsParam(String key) {
    return _segments
        .any((element) => element is _PLSegment && element.key == key);
  }

  /// Checks whether the placeholder with the given key is optional.
  ///
  /// Throws ApiError when the key is not present in the pattern.
  bool isOptionalParam(String key) {
    final segment = _segments.firstWhere(
            (element) => element is _PLSegment && element.key == key,
            orElse: () => throw ApiError(
                'Placeholder param "$key" not present in pattern: $pattern'))
        as _PLSegment;
    return segment.optional;
  }

  /// Throws [ApiError] if [param] does not exist as route parameter in this
  /// pattern.
  ///
  /// If [isOptional] is non-null, it is also asserted, that the route
  /// parameter is optional or not.
  void assertParam(String param, {bool? isOptional}) {
    if (!containsParam(param) || (isOptional != isOptionalParam(param))) {
      final buffer = StringBuffer('RoutePattern requires ');
      if (isOptional != null) {
        if (!isOptional) {
          buffer.write('non-');
        }
        buffer.write('optional');
      }
      buffer.write(' parameter "$param".');
      throw ApiError(buffer.toString());
    }
  }
}

class _Segment {
  final String source;

  const _Segment(this.source);

  String toMatchExp() => '\\/${_regexEscape(source)}';

  String encode(Map<String, String> params) => '/$source';
}

class _PLSegment extends _Segment {
  final String prefix;
  final String key;
  final bool optional;

  const _PLSegment(String source, this.prefix, this.key, this.optional)
      : super(source);

  @override
  String toMatchExp() {
    final keyRegex = '(?<$key>\\\$?[\\w\\-\\.\\%]+)';
    if (optional) {
      if (prefix.isEmpty) {
        return '(\\/$keyRegex)?';
      } else {
        return '(\\/${_regexEscape(prefix)}$keyRegex)?';
      }
    } else {
      return '\\/${_regexEscape(prefix)}$keyRegex';
    }
  }

  @override
  String encode(Map<String, String> params) {
    if (params.containsKey(key)) {
      return '/$prefix${params[key]}';
    } else if (optional) {
      return '';
    } else {
      throw ApiException('Missing value in url params: $key');
    }
  }
}

class _WildcardSegment extends _Segment {
  const _WildcardSegment() : super('*');

  @override
  String toMatchExp() => '(?<$_wildcardGroup>(\\/(\\\$?[\\w\\.-]*))*)';

  @override
  String encode(Map<String, String> params) => '';
}

String _regexEscape(String source) {
  return source.replaceAll('\\', '\\\\').replaceAll('.', '\\.');
}

/// Represents a path which has been matched with a [RoutePattern].
///
/// Route provides the [RoutePattern] with which the path has been matched
/// and all route parameters defined by the [RoutePattern].
/// If the pattern uses a wildcard suffix, the wildcard-part of the path
/// is stored in [Route.wildcard].
class Route {
  final RoutePattern pattern;
  final String url;
  final Map<String, String> routeParams;
  final String? wildcard;

  Route(this.pattern, this.url, this.routeParams, this.wildcard);

  //TODO doc -> throw behaviour etc
  int? getParamInt(String name) {
    if (routeParams[name] != null) {
      return int.tryParse(routeParams[name]!) ??
          (throw ApiRequestException.badRequest('Invalid route param: $name'));
    }
    return null;
  }

  String? getParam(String name) => routeParams[name];

  @override
  String toString() => url;
}
