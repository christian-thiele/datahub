import 'package:datahub_aperture/api.dart' as api;

typedef ApertureActionHandler = Future<String?> Function(
    String? elementId, Map<String, dynamic> parameters);

class ApertureAction {
  final api.ResourceAction description;
  final ApertureActionHandler handler;

  const ApertureAction({
    required this.description,
    required this.handler,
  });
}
