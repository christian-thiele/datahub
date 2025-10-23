import 'package:datahub/datahub.dart';

import 'operation_object.dart';

part 'path_item_object.g.dart';

@Data()
class PathItemObject extends $PathItemObject {
  final OperationObject? get;
  final OperationObject? put;
  final OperationObject? post;
  final OperationObject? delete;
  final OperationObject? options;
  final OperationObject? head;
  final OperationObject? patch;

  // TODO implement "parameters"
  //final List<ParameterObject | ReferenceObject> parameters;

  const PathItemObject({
    required this.get,
    required this.put,
    required this.post,
    required this.delete,
    required this.options,
    required this.head,
    required this.patch,
  });
}
