import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/dto/transfer_object.dart';
import 'package:cl_datahub/src/api/hub/api_resource.dart';

class StaticApiResource<TData extends TransferObject>
    extends ApiResource<TData> {
  final Iterable<TData> data;

  StaticApiResource(path, DTOFactory<TData> factory, this.data)
      : super(path, factory);

  @override
  Future<TData> getElement(int id) async {
    if (data.length > id) {
      return data.elementAt(id);
    }

    throw ApiRequestException.notFound();
  }

  @override
  Future<List<TData>> getList(int offset, int limit) async {
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
