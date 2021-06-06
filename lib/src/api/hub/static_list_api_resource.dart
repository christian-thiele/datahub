import 'package:cl_datahub/api.dart';
import 'package:cl_datahub_common/common.dart';

import 'api_resource.dart';

class StaticListApiResource<TData> extends ListApiResource<TData, int> {
  final Iterable<TData> data;

  StaticListApiResource(path, DTOFactory<TData> factory, this.data)
      : super(path, factory);

  @override
  Future<TData> getElement(ApiRequest request, int id) async {
    if (data.length > id) {
      return data.elementAt(id);
    }

    throw ApiRequestException.notFound();
  }

  @override
  Future<List<TData>> getList(ApiRequest request, int offset, int limit) async {
    return data.skip(offset).take(limit).toList();
  }

  @override
  Future getMetaData(String name) async {
    if (name == 'count') {
      return data.length;
    }

    throw ApiRequestException.notFound('Meta-Property $name not found.');
  }
}
