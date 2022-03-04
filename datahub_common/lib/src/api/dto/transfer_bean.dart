abstract class TransferBean<T> {
  const TransferBean();
  Map<String, dynamic> toMap(T transferObject);
  T toObject(Map<String, dynamic> data);
}

/// Bean for use with simple Map<String, dynamic> objects.
class MapTransferBean extends TransferBean<Map<String, dynamic>> {
  const MapTransferBean();

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> transferObject) =>
      transferObject;

  @override
  Map<String, dynamic> toObject(Map<String, dynamic> data) => data;
}
