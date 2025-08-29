import 'resource_transport_exception.dart';

enum ResourceTransportResourceType {
  simple(0x01),
  collection(0x02);

  const ResourceTransportResourceType(this.byte);

  final int byte;

  static ResourceTransportResourceType fromByte(int byte) {
    return ResourceTransportResourceType.values.firstWhere(
        (e) => e.byte == byte,
        orElse: () =>
            throw ResourceTransportException('Invalid operation byte.'));
  }
}

enum ResourceTransportMessageType {
  /// resource: set
  set(0x00),

  /// resource: patch
  patch(0x01),

  /// collection resource: initialize window
  init(0x02),

  /// collection resource: realign window
  align(0x03),

  /// collection resource: add element inside window
  add(0x04),

  /// collection resource: remove element inside window
  remove(0x05),

  /// collection resource: update element
  update(0x06),

  /// resource not available anymore
  delete(0x07),

  /// session expired
  ///
  /// Client should silently reconnect with valid authorization.
  expired(0xFE),

  /// high level request exception
  exception(0xFF);

  const ResourceTransportMessageType(this.byte);

  final int byte;

  static ResourceTransportMessageType fromByte(int byte) {
    return ResourceTransportMessageType.values.firstWhere((e) => e.byte == byte,
        orElse: () =>
            throw ResourceTransportException('Invalid operation byte.'));
  }
}

class ResourceTransportMessage {
  final ResourceTransportResourceType resourceType;
  final ResourceTransportMessageType messageType;
  final List<int> payload;

  ResourceTransportMessage(this.resourceType, this.messageType, this.payload);
}
