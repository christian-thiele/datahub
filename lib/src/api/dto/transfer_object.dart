typedef DTOFactory<T extends TransferObject> = T Function(
    Map<String, dynamic> data);

abstract class TransferObject {
  final Map<String, dynamic> data;

  TransferObject(this.data);

  Map<String, dynamic> toJson() => data;
}
