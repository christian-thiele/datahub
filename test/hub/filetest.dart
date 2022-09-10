import 'dart:io';
import 'dart:typed_data';

import 'package:datahub/datahub.dart';

void main() async {
  await ServiceHost([
    FileApi.new,
  ]).run();
}

class FileApi extends ApiService {
  FileApi()
      : super(null, [
          IndexEndpoint(),
          FileEndpoint(),
        ]);
}

class IndexEndpoint extends ApiEndpoint {
  IndexEndpoint() : super(RoutePattern('/index.html'));

  @override
  Future get(ApiRequest request) async {
    final response = TextResponse.html(
      '''
      <!DOCTYPE html><html><head><title>Test</title></head><body>
      <p>You called ${request.route.url}</p>
      </body></html>
      ''',
    );

    return PushStreamResponse(
        response,
        Stream.periodic(const Duration(seconds: 3), (i) {
          return TextResponse.html('But wait, there is more! $i');
        }).take(100));
  }
}

class FileEndpoint extends ApiEndpoint {
  FileEndpoint() : super(RoutePattern('/file'));

  @override
  Future get(ApiRequest request) async {
    final file = File('file.jpg');
    return FileResponse(file);
  }

  @override
  Future post(ApiRequest request) async {
    print('received file request');
    final watch = Stopwatch()..start();
    final length = request.headers[HttpHeaders.contentLengthHeader];
    print('length: $length');
    final file = File('file.dat');
    if (await file.exists()) {
      await file.delete();
    }
    await file.create();
    final sink = file.openWrite();

    var x = 0;
    var last = 0;
    await for (final chunk in request.bodyData) {
      x += chunk.length;
      if (x - last > 1024 * 1024) {
        last = x;
        print('${x / 1024 / 1024}MB');
      }
      sink.write(Uint8List.fromList(chunk));
    }
    await sink.close();
    print('upload done.');
    watch.stop();
    print('${watch.elapsed.inSeconds}sec');
    return EmptyResponse(statusCode: 201);
  }
}
