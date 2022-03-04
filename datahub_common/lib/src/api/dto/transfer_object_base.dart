import 'transfer_bean.dart';

/// Interface used internally to detect transfer objects.
///
/// DO NOT implement directly, extend generated _TransferObject instead.
abstract class TransferObjectBase<Id> {
  Id getId();
  dynamic toJson();
  TransferBean get bean;
}
