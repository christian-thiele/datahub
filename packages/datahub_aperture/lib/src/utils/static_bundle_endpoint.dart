import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:datahub/datahub.dart';

class StaticBundleEndpoint extends ApiEndpoint {
  Uint8List? Function(String) bundle;

  StaticBundleEndpoint({super.matcher, required this.bundle});

  @override
  Future<dynamic> onRequest(ApiRequest request) async {
    if (request.method != HttpRequestMethod.get) {
      throw ApiRequestException.methodNotAllowed();
    }

    if (request.routeParams['*'] case final bundlePath?) {
      return await serveBundleResource(bundlePath);
    } else {
      throw ApiRequestException.notFound();
    }
  }

  Future<ByteStreamResponse> serveBundleResource(String path) async {
    final effectivePath = switch (path) {
      '/' || '' => 'index.html',
      _ when path.startsWith('/') => path.substring(1),
      _ => path,
    };

    if (bundle(effectivePath) case final bytes?) {
      return ByteStreamResponse(
        Stream.value(bytes),
        bytes.length,
        disposition: ContentDisposition.inline,
        contentType:
            Mime.fromExtension(effectivePath.split('.').lastOrNull ?? '') ??
                Mime.octetStream,
      );
    } else {
      final bytes = bundle('index.html')!;
      return ByteStreamResponse(
        Stream.value(bytes),
        bytes.length,
        disposition: ContentDisposition.inline,
        contentType: Mime.html,
      );
    }
  }
}
