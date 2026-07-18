import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/utils.dart';

typedef ApertureActionHandler<TParameters> =
    Future<String?> Function(String? elementId, TParameters parameters);

class ApertureAction<TParameters extends DataObject> {
  final DataBean<TParameters> bean;
  final ApertureActionHandler<TParameters> handler;

  const ApertureAction({required this.bean, required this.handler});

  ResourceAction buildDescription(Iterable<DataBean> beans) =>
      buildResourceActionDescription(this, beans);

  Future<String?> handle(
    dynamic elementId,
    Map<String, dynamic> parameters,
  ) async {
    return await handler(elementId, bean.fromJson(parameters));
  }
}
