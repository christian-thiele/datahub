import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

import 'docker_container.dart';

class DockerClient {
  late final io.HttpClient client;

  DockerClient() {
    client = io.HttpClient();
    client.connectionFactory = (_, _, _) async {
      final socket = io.Socket.connect(
        io.InternetAddress(
          '/var/run/docker.sock',
          type: io.InternetAddressType.unix,
        ),
        0,
      );
      return io.ConnectionTask.fromSocket(socket, () {});
    };
  }

  Future<List<DockerContainer>> getContainers({bool all = false}) async {
    final response = await request(
      'GET',
      '/containers/json',
      query: {'all': all.toString()},
    );
    return JsonDataCodec().decodeList(response, $DockerContainer.bean.fromJson);
  }

  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> query = const {},
  }) async {
    final req = await client.openUrl(
      method,
      Uri(
        scheme: 'http',
        host: 'localhost',
        path: path,
        queryParameters: query,
      ),
    );
    req.headers.set(io.HttpHeaders.hostHeader, 'docker');
    req.headers.set(io.HttpHeaders.contentTypeHeader, 'application/json');
    if (body != null) {
      req.write(jsonEncode(body));
    }
    final res = await req.close();
    if (res.statusCode != 200) {
      throw Exception('Docker responded with status code ${res.statusCode}.');
    }

    final bytes = await res.collect();
    final text = utf8.decode(bytes);
    return jsonDecode(text);
  }
}
