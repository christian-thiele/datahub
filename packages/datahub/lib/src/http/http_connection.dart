import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:boost/boost.dart';
import 'package:datahub/src/http/socket_adapter.dart';
// ignore: implementation_imports
import 'package:http2/src/connection_preface.dart';

enum HttpVersion { http11, http2 }

class HttpConnection {
  static void detectProtocol(
    io.Socket socket,
    void Function(io.Socket) http1,
    void Function(io.Socket) http2,
    Function onError,
  ) {
    readConnectionPreface(socket)
        .then((value) {
          switch (value.$2) {
            case HttpVersion.http11:
              http1(DetachedSocket(socket, value.$1));
              break;
            case HttpVersion.http2:
              http2(DetachedSocket(socket, value.$1));
              break;
          }
        })
        .catchError(onError);
  }

  static bool startsWithHttp2Preface(List<int> data) {
    return data
        .take(CONNECTION_PREFACE.length)
        .sequenceEquals(CONNECTION_PREFACE);
  }

  static Future<(Stream<Uint8List>, HttpVersion)> readConnectionPreface(
    Stream<Uint8List> socket,
  ) async {
    final controller = StreamController<Uint8List>();
    final buffer = <int>[];
    final completer = Completer<HttpVersion>();

    void onData(Uint8List data) {
      if (!completer.isCompleted) {
        if (data.length >= CONNECTION_PREFACE.length) {
          if (startsWithHttp2Preface(data)) {
            completer.complete(HttpVersion.http2);
          } else {
            completer.complete(HttpVersion.http11);
          }
        } else {
          final rest = CONNECTION_PREFACE.length - buffer.length;
          buffer.addAll(data.take(rest));
          if (buffer.length >= CONNECTION_PREFACE.length) {
            if (startsWithHttp2Preface(buffer)) {
              completer.complete(HttpVersion.http2);
            } else {
              completer.complete(HttpVersion.http11);
            }
          }
        }
      }

      controller.add(data);
    }

    void onError(e, stack) {
      if (completer.isCompleted) {
        controller.addError(e, stack);
      } else {
        completer.completeError(e, stack);
      }
    }

    void onDone() {
      if (completer.isCompleted) {
        controller.close();
      } else {
        completer.completeError(
          Exception('Connection closed before protocol detection.'),
        );
      }
    }

    final subscription = socket.listen(
      onData,
      onError: onError,
      onDone: onDone,
    );

    controller.onListen = () => controller
      ..onPause = subscription.pause
      ..onResume = subscription.resume
      ..onCancel = subscription.cancel;

    return (controller.stream, await completer.future);
  }
}
