import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/docker/api/docker_create_container_request.dart';
import 'package:datahub/src/test/docker/api/docker_network_create_request.dart';

import 'api/docker_container.dart';

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

  Future<String> createContainer(
    String name,
    DockerCreateContainerRequest create,
  ) async {
    final response = await request(
      'POST',
      '/containers/create',
      body: create.toJson(),
      query: {'name': name},
    );
    return response['Id'] as String;
  }

  Future<void> removeContainer(
    String containerId, {
    bool volumes = false,
    bool force = false,
    bool link = false,
  }) async {
    await request(
      'DELETE',
      '/containers/$containerId',
      query: {
        'v': volumes.toString(),
        'force': force.toString(),
        'link': link.toString(),
      },
    );
  }

  Future<String> createNetwork(DockerNetworkCreateRequest create) async {
    final response = await request(
      'POST',
      '/networks/create',
      body: create.toJson(),
    );
    return response['Id'] as String;
  }

  Future<void> removeNetwork(String networkId) async {
    await request('DELETE', '/networks/$networkId');
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
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Docker responded with status code ${res.statusCode}.');
    }

    final bytes = await res.collect();
    final text = utf8.decode(bytes);
    if (text.isNotEmpty) {
      return jsonDecode(text);
    }
    return null;
  }
}
