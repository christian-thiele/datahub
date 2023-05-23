import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

class CollectionSize extends TransferObjectBase<void> {
  final int size;

  CollectionSize({
    required this.size,
  });

  @override
  TransferBean get bean => CollectionSizeTransferBean();

  @override
  void getId() => null;

  @override
  Map<String, dynamic> toJson() => {'size': size};
}

class CollectionSizeTransferBean extends TransferBean<CollectionSize> {
  const CollectionSizeTransferBean();

  @override
  Map<String, dynamic> toMap(CollectionSize transferObject) =>
      transferObject.toJson();

  @override
  CollectionSize toObject(Map<String, dynamic> data, {String? name}) =>
      CollectionSize(
          size: decodeTyped<int>(
        data['size'],
        name: name != null ? '$name.size' : 'size',
      ));
}
