import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_action.dart';
import 'package:datahub_aperture/utils.dart';

typedef ApertureDataActionHandler<TParameters> = Future<String?> Function(
    String? elementId, TParameters parameters);

class ApertureDataAction {
  final DataBean bean;
  final ApertureDataActionHandler<DataObject> handler;

  ApertureDataAction({
    required this.bean,
    required this.handler,
  });

  ResourceAction buildDescription(Iterable<DataBean> relatedBeans) {
    final meta = bean.metaOfType<Meta>();

    return ResourceAction(
      id: bean.name,
      displayName: meta?.name ?? niceName(bean.name),
      icon: meta?.icon ?? Icons.data_object,
      parameterFields: [
        for (final field in bean.fields)
          ApertureDataResource.fieldDescription(bean, field, relatedBeans),
      ],
    );
  }

  Future<String?> handle(dynamic elementId,
      Map<String, dynamic> parameters) async {
    return await handler(elementId, bean.fromJson(parameters));
  }
}
