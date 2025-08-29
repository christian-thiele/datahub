import 'transfer_bean.dart';

/// Interface for transfer objects.
abstract class TransferObjectBase<Id> {
  TransferBean get bean;
  Id getId();
  dynamic toJson() => bean.toMap(this);
}
