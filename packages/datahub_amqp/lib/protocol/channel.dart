part of 'connection.dart';

class Channel {
  final int id;
  final _inController = StreamController<AmqpFrame>.broadcast();
  final _outController = StreamController<AmqpFrame>();

  Channel(this.id);

  Stream<AmqpFrame> get _outStream => _outController.stream;

  bool get isOpen => !_outController.isClosed;

  void add(AmqpFrame frame) => _inController.add(frame);

  Future<void> _open() async {
    final reader = StreamReader(_inController.stream);
    _outController.add(AmqpMethodChannelOpen(channelId: id).toFrame());
    final openOk = await reader.next as AmqpMethodChannelOpenOk;
  }

  Future<void> close() async {
    final listener = _waitForMethod<AmqpMethodChannelCloseOk>();
    _outController.add(
      AmqpMethodConnectionClose(
        channelId: id,
        replyCode: 0,
        replyText: '',
        failingClassId: 0,
        failingMethodId: 0,
      ).toFrame(),
    );
    await listener;
    _outController.close();
    _inController.close();
  }

  Future<void> setFlow(bool active) async {
    final listener = _waitForMethod<AmqpMethodChannelFlowOk>();

    _outController.add(
      AmqpMethodChannelFlow(channelId: id, active: active).toFrame(),
    );

    final result = await listener;
    if (result.active != active) {
      // TODO send error and close
    }
  }

  Future<T> _waitForMethod<T extends AmqpMethod>([
    bool Function(T)? test,
  ]) async {
    final methodStream = _inController.stream
        .whereType<MethodFrame>()
        .map(AmqpMethod.fromFrame)
        .whereType<T>();

    return await (test != null
        ? methodStream.where(test).first
        : methodStream.first);
  }
}
