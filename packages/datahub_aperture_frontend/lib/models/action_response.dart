import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/file_value.dart';

/// What an action responded with.
sealed class ActionResponse {
  const ActionResponse();
}

/// A message, data or element to redirect to.
class ActionResultResponse extends ActionResponse {
  final ResourceActionResult result;

  const ActionResultResponse(this.result);
}

/// A file for the user to save.
class ActionFileResponse extends ActionResponse {
  final FileValue file;

  const ActionFileResponse(this.file);
}
