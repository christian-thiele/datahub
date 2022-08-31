import 'package:datahub/transfer_object.dart';

/// Base class for all Hub-Resources.
///
/// A hub resource is read-only by default. Other HubResource classes
/// like [MutableHubResource] are modifiable.
class HubResource<T> {
  final String name;
  final TransferBean<T> bean;

  HubResource(this.name, this.bean);
}

class MutableHubResource<T> extends HubResource<T> {
  MutableHubResource(super.name, super.bean);
}
