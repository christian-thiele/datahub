import 'package:datahub/datahub.dart';

class CollectionObject<T extends TransferObjectBase<Object>>
    extends TransferObjectBase<void> {
  final TransferBean<T> elementBean;

  final int offset;
  final int size;
  final List<T> elements;

  CollectionObject(
    this.elementBean, {
    required this.offset,
    required this.size,
    required this.elements,
  });

  @override
  TransferBean get bean => CollectionObjectTransferBean<T>(elementBean);

  @override
  void getId() => null;

  @override
  Map<String, dynamic> toJson() => {
        'offset': offset,
        'size': size,
        'elements': encodeList<T>(elements, (e) => e.toJson()),
      };
}

class CollectionObjectTransferBean<T extends TransferObjectBase<Object>>
    extends TransferBean<CollectionObject<T>> {
  final TransferBean<T> elementBean;

  const CollectionObjectTransferBean(this.elementBean);

  @override
  Map<String, dynamic> toMap(CollectionObject<T> transferObject) =>
      transferObject.toJson();

  @override
  CollectionObject<T> toObject(Map<String, dynamic> data) =>
      CollectionObject<T>(
        elementBean,
        offset: decodeTyped<int>(data['offset']),
        size: decodeTyped<int>(data['size']),
        elements: decodeList(
          data['elements'],
              (p0) => elementBean.toObject(p0),
        ),
      );
}