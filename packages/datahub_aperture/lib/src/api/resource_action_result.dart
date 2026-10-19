import 'package:datahub/datahub.dart';

part 'resource_action_result.g.dart';

@Data()
class const ResourceActionResult({
  final bool success = true,

  /// A message displayed to the user.
  final String? message,

  /// Structured data to show along with the [message].
  final Map<String, dynamic>? data,

  /// The element to show instead of a response.
  final ResourceActionRedirect? redirect,
}) extends $ResourceActionResult;

/// An element of a resource an action redirects to.
@Data()
class const ResourceActionRedirect({
  required final String resourceId,
  required final String elementId,
}) extends $ResourceActionRedirect;
