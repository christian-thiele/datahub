import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/utils.dart';

/// Runs an action. [elementId] is null for global actions.
///
/// Returns what the user sees once the action is done: null for a plain
/// confirmation, an [ActionResult] for a message (and data) or a
/// [RedirectActionResult] to open an element instead.
typedef ApertureActionHandler<TParameters> =
    Future<BaseActionResult?> Function(
      String? elementId,
      TParameters parameters,
    );

class ApertureAction<TParameters extends DataObject> {
  final DataBean<TParameters> bean;
  final ApertureActionHandler<TParameters> handler;

  const ApertureAction({required this.bean, required this.handler});

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
sealed class BaseActionResult {
  const BaseActionResult();
}

/// Shows [message] to the user, as a success or a failure, along with
/// structured [data] if given.
///
/// An action that fails because of a bad request should rather throw an
/// [ApiRequestException].
class ActionResult extends BaseActionResult {
  final bool success;
  final String message;

  /// Shown as key-value pairs, nested values as JSON.
  final Map<String, dynamic>? data;

  const ActionResult({this.success = true, required this.message, this.data});
}

/// Opens the element [id] of the resource of [bean], for example one the
/// action created.
class RedirectActionResult extends BaseActionResult {
  final DataBean bean;
  final String id;

  const RedirectActionResult({required this.bean, required this.id});
}
