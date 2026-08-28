import 'package:boost/boost.dart';

import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';

import 'api_request.dart';
import 'route_matcher.dart';

const _wildcardGroup = '_route_wildcard';
const _prefixGroup = '_prefix';
const _keyGroup = '_key';
const _optionalGroup = '_optional';

const _specialChars = [
  '-',
  '.',
  '_',
  '~',
  '!',
  '\$',
  '&',
  "'",
  '(',
  ')',
  '+',
  ',',
  ';',
  '=',
  ':',
  '@',
  '%',
];

const _segmentChars =
    "[\\w\\-\\.\\_\\~\\!\\\$\\&\\'\\(\\)\\+\\,\\;\\=\\:\\@\\%]";

// placeholder detector regex
final RegExp _plExp = RegExp(
  '^(?<$_prefixGroup>$_segmentChars*){((?<$_keyGroup>[\\w-]+)(?<$_optionalGroup>\\??))}\$',
);

// route pattern validation regex
final RegExp _vrExp = RegExp(
  '^(\\/($_segmentChars+|$_segmentChars*((?<!\\\\){([\\w-]+)\\??})))*(\\/\\*?)?/?\$',
);

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
class RoutePattern implements RouteMatcher {
  final String pattern;
  final List<_Segment> _segments;
  final String routeMatchExp;
  final bool isWildcardPattern;

  static const any = RoutePattern._('*', [_WildcardSegment()], r'.*', true);

  const RoutePattern._(
    this.pattern,
    this._segments,
    this.routeMatchExp,
    this.isWildcardPattern,
  );

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
        segments.add(
          _PLSegment(
            segment,
            plMatch.namedGroup(_prefixGroup)!,
            plMatch.namedGroup(_keyGroup)!,
            plMatch.namedGroup(_optionalGroup)!.isNotEmpty,
          ),
        );
        continue;
      }

      if (segment == '*') {
        segments.add(_WildcardSegment());
        hasWildcard = true;
        break;
      }

      segments.add(_Segment(segment));
    }

    final matchExp = '^${segments.map((s) => s.toMatchExp()).join()}\\/?\$';

    return RoutePattern._(pattern, segments, matchExp, hasWildcard);
  }

  /// Encodes url params into a path.
  String encode(Map<String, dynamic> values) {
    final codec = const JsonDataCodec();
    final stringValues = values.map(
      (key, value) =>
          MapEntry(key, Uri.encodeComponent(codec.decodeString(value))),
    );
    return _segments.map((s) => s.encode(stringValues)).join();
  }

  /// Decodes a path using the route pattern.
  ///
  /// Path parameters will be stored in the returned [Route] object.
  RoutePatternMatch? tryMatch(String path) {
    final match = RegExp(routeMatchExp, caseSensitive: false).firstMatch(path);
    if (match == null) {
      return null;
    }

    final pathParams = Map.fromEntries(
      match.groupNames
          .where((e) => e != _wildcardGroup)
          .map(
            (e) => (match.groupNames.contains(e) && match.namedGroup(e) != null)
                ? MapEntry(e, Uri.decodeComponent(match.namedGroup(e)!))
                : null,
          )
          .nonNulls,
    );

    final wildcard = match.groupNames.contains(_wildcardGroup)
        ? match.namedGroup(_wildcardGroup)
        : null;

    return RoutePatternMatch(this, path, pathParams, wildcard);
  }

  /// Placeholder parameters of this pattern, in order of appearance.
  List<({String key, bool optional, String prefix})> get placeholders => [
    for (final segment in _segments)
      if (segment is _PLSegment)
        (key: segment.key, optional: segment.optional, prefix: segment.prefix),
  ];

  /// Converts this route pattern into OpenAPI-style path strings.
  ///
  /// Optional placeholders produce multiple variants (with and without the
  /// segment), since OpenAPI path parameters are always required. A trailing
  /// wildcard is omitted (see [isWildcardPattern]).
  List<String> get openApiPaths {
    var variants = [<String>[]];
    for (final segment in _segments) {
      switch (segment) {
        case _WildcardSegment():
          continue;
        case _PLSegment():
          final part = '${segment.prefix}{${segment.key}}';
          variants = [
            for (final variant in variants) ...[
              if (segment.optional) variant,
              [...variant, part],
            ],
          ];
        case _Segment():
          variants = [
            for (final variant in variants) [...variant, segment.source],
          ];
      }
    }
    return [for (final variant in variants) '/${variant.join('/')}'];
  }

  /// Checks if there is a placeholder param with the given key in the pattern.
  bool containsParam(String key) {
    return _segments.any(
      (element) => element is _PLSegment && element.key == key,
    );
  }

  /// Checks whether the placeholder with the given key is optional.
  ///
  /// Throws ApiError when the key is not present in the pattern.
  bool isOptionalParam(String key) {
    final segment =
        _segments.firstWhere(
              (element) => element is _PLSegment && element.key == key,
              orElse: () => throw ApiError(
                'Placeholder param "$key" not present in pattern: $pattern',
              ),
            )
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

  @override
  bool matches(ApiRequest request) => tryMatch(request.uri.path) != null;

  @override
  Map<String, String> getRouteParams(ApiRequest request) {
    if (tryMatch(request.uri.path) case final match?) {
      return {
        ...match.routeParams,
        '#pattern': pattern,
        if (match.wildcard case final wildcard?) '*': wildcard,
      };
    } else {
      return {};
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

  const _PLSegment(super.source, this.prefix, this.key, this.optional);

  @override
  String toMatchExp() {
    final keyRegex = '(?<$key>$_segmentChars+)';
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
  String toMatchExp() => '(?<$_wildcardGroup>(\\/($_segmentChars*))*)';

  @override
  String encode(Map<String, String> params) => '';
}

String _regexEscape(String source) {
  return _specialChars.fold(source, (s, c) => s.replaceAll(c, '\\$c'));
}

/// Represents a path which has been matched with a [RoutePattern].
///
/// Route provides the [RoutePattern] with which the path has been matched
/// and all route parameters defined by the [RoutePattern].
/// If the pattern uses a wildcard suffix, the wildcard-part of the path
/// is stored in [Route.wildcard].
class RoutePatternMatch {
  final RoutePattern pattern;
  final String path;
  final Map<String, String> routeParams;
  final String? wildcard;

  const RoutePatternMatch(
    this.pattern,
    this.path,
    this.routeParams,
    this.wildcard,
  );

  /// Returns the named route parameter.
  ///
  /// Throws [ApiRequestException.badRequest] if value does not exist or could
  /// not be parsed.
  /// If a null return value is preferred instead, simply set a nullable
  /// type for [T] and no exception will be thrown.
  ///
  /// Valid types for [T] (nullable, as well as non-nullable)
  /// are [String], [int], [double], [bool], [DateTime], [Duration] or [Uint8List].
  T getParam<T>(String name) {
    try {
      final codec = const JsonDataCodec();
      return codec.decodeTyped<T>(routeParams[name]);
    } on CodecException catch (_) {
      throw ApiRequestException.badRequest(
        'Missing or malformed route parameter: $name',
      );
    }
  }

  @override
  String toString() => path;
}
