import 'dart:convert';
import 'dart:io' as io;

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';


void main() {
  test('test', () async {
    final docker = DockerClient();
    final containers = await docker.getContainers(all: true);
    for (final c in containers) {
      print('${c.names.firstOrNull ?? c.id}: ${c.image}');
    }
  });
}
