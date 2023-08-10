import 'dart:async';

import 'package:datahub/collection.dart';
import 'package:datahub/transfer_object.dart';

class CollectionWindowStateStreamTransformer<
        Item extends TransferObjectBase<Id>, Id>
    extends StreamTransformerBase<CollectionWindowEvent<Item, Id>,
        CollectionWindowState<Item, Id>> {
  @override
  Stream<CollectionWindowState<Item, Id>> bind(
          Stream<CollectionWindowEvent<Item, Id>> stream) =>
      Stream.eventTransformed(
        stream,
        _CollectionWindowStateStreamSink<Item, Id>.new,
      );
}

class _CollectionWindowStateStreamSink<Item extends TransferObjectBase<Id>, Id>
    implements EventSink<CollectionWindowEvent<Item, Id>> {
  final EventSink<CollectionWindowState<Item, Id>> _out;
  CollectionWindowState<Item, Id>? _current;

  _CollectionWindowStateStreamSink(this._out);

  @override
  void add(CollectionWindowEvent<Item, Id> event) {
    if (event is CollectionInitEvent<Item, Id>) {
      _out.add(_current = CollectionWindowState<Item, Id>(
          event.collectionLength, event.windowOffset, event.data));
    } else if (_current != null) {
      _out.add(_current = _current!.mutate(event));
    } else {
      throw Exception('Expecting CollectionInitEvent as first stream event.');
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _out.addError(error, stackTrace);

  @override
  void close() => _out.close();
}
