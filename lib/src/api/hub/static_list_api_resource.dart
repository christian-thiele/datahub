import 'package:datahub/api.dart';
import 'package:datahub/transfer_object.dart';

class StaticListApiResource<TData> extends ListApiResource<TData, int> {
  final Iterable<TData> data;

  StaticListApiResource(path, TransferBean<TData> bean, this.data)
      : super(path, bean);

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
  Future<int> getSize(ApiRequest request) async => data.length;
}
