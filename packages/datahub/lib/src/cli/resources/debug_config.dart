String createDebugConfig(String projectName) =>
    '''datahub:
  environment: dev
  log: debug
  serviceName: $projectName
''';
