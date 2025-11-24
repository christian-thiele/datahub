import 'dart:collection';
import 'package:collection/collection.dart';

class BlockingQueueReader {
  final int length;
  final void Function(List<int> elements) onData;

  BlockingQueueReader(this.length, this.onData);
}

class BlockingQueue extends DelegatingQueue<List<int>> {
  final _readQueue = Queue<BlockingQueueReader>();

  BlockingQueue() : super(Queue<List<int>>());

  @override
  void add(List<int> value) {
    super.add(value);
    _notify();
  }

  @override
  void addAll(Iterable<List<int>> iterable) {
    super.addAll(iterable);
    _notify();
  }

  @override
  void addFirst(List<int> value) {
    super.addFirst(value);
    _notify();
  }

  @override
  void addLast(List<int> value) {
    super.addLast(value);
    _notify();
  }

  void _notify() {
    if (_readQueue.firstOrNull case final reader?) {
      if (reader.length <= byteLength) {
        final buffer = <int>[];
        while (buffer.length < reader.length) {

        }
      }
    }
  }

  int get byteLength => fold<int>(0, (a, b) => a + b.length);
}
