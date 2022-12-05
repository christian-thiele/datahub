class HubEvent<T> {
  final T data;
  final void Function() ack;
  final void Function(bool requeue) reject;

  HubEvent(
    this.data,
    this.ack,
    this.reject,
  );
}
