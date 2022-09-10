enum ResourceTransportMessageType {
  set,
  patch,
  delete,
}

class ResourceTransportMessage {
  final ResourceTransportMessageType type;
  final List<int> payload;

  ResourceTransportMessage(this.type, this.payload);
}