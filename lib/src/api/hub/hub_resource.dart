
import 'package:cl_datahub/api.dart';

abstract class ApiResource<TData extends TransferObject> extends ApiEndpoint {
  final DTOFactory? factory;

  ApiResource(path, this.factory) : super(path);

  Future<dynamic> getMetaData(String name);

  Future<TData> getElement(int id);

  Future<List<TData>> getList(int offset, int limit);
}
