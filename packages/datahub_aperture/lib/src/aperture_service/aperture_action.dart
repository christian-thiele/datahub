import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/utils.dart';

typedef ApertureActionHandler<TParameters> =
    Future<String?> Function(String? elementId, TParameters parameters);

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

  Future<String?> handle(dynamic elementId, TParameters parameters) async {
    return await handler(elementId, parameters);
  }
}
