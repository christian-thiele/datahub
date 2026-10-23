import 'dart:convert';

import 'package:datahub_aperture/api.dart';

class const RouteUtils._() {
  static String viewElement(String resourceId, String elementId) {
    return '/resources/${Uri.encodeComponent(resourceId)}/view/${Uri.encodeComponent(elementId)}';
  }

  static String viewResource(String resourceId, {ResourceFilter? filter}) {
    final path = '/resources/${Uri.encodeComponent(resourceId)}';
    if (filter case final filter?) {
      return '$path?filter=${Uri.encodeQueryComponent(jsonEncode(filter.toJson()))}';
    }
    return path;
  }
}
