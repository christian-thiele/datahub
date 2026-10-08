import 'package:datahub/datahub.dart';

part 'resource_action_result.g.dart';

@Data()
class ResourceActionResult extends $ResourceActionResult {
  final bool success;

  /// A message displayed to the user.
  final String? message;

  /// Structured data to show along with the [message].
  final Map<String, dynamic>? data;

  /// The element to show instead of a response.
  final ResourceActionRedirect? redirect;

  const ResourceActionResult({
    this.success = true,
    this.message,
    this.data,
    this.redirect,
  });
}

/// An element of a resource an action redirects to.
@Data()
class ResourceActionRedirect extends $ResourceActionRedirect {
  final String resourceId;
  final String elementId;

  const ResourceActionRedirect({
    required this.resourceId,
    required this.elementId,
  });
}
