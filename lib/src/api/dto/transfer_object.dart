typedef DTOFactory<T extends TransferObject> = T Function(Map<String, dynamic> data);

abstract class TransferObject {
  final Map<String, dynamic> _data;

  TransferObject(this._data);

  Map<String, dynamic> toJson() => _data;
}