import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/utils.dart';

/// Runs an action. [elementId] is null for global actions.
///
/// Returns what the user sees once the action is done: null for a plain
/// confirmation, an [ActionResult] for a message (and data) or a
/// [RedirectActionResult] to open an element instead.
typedef ApertureActionHandler<TParameters> = Future<BaseActionResult?> Function(
  String? elementId,
  TParameters parameters,
);

class const ApertureAction<TParameters extends DataObject>({
  required final DataBean<TParameters> bean,
  required final ApertureActionHandler<TParameters> handler,
}) {
  ResourceAction buildDescription(Iterable<DataBean> beans) =>
      buildResourceActionDescription(this, beans);

  TParameters decodeParameters(dynamic json) {
    final parameters = bean.fromJson(json);
    bean.validateConstraints(parameters);
    return parameters;
  }

  Future<BaseActionResult?> handle(dynamic elementId, TParameters parameters) =>
      handler(elementId, parameters);
}

/// What an [ApertureActionHandler] responds with.
sealed class const BaseActionResult();

/// Shows [message] to the user, as a success or a failure, along with
/// structured [data] if given.
///
/// An action that fails because of a bad request should rather throw an
/// [ApiRequestException].
class const ActionResult({
  final bool success = true,
  required final String message,

  /// Shown as key-value pairs, nested values as JSON.
  final Map<String, dynamic>? data,
}) extends BaseActionResult;

/// Opens the element [id] of the resource of [bean], for example one the
/// action created.
class const RedirectActionResult({
  required final DataBean bean,
  required final String id,
}) extends BaseActionResult;
