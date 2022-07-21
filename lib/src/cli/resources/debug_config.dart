String createDebugConfig(String projectName) => '''datahub:
  environment: DEV
  log: DEBUG
  serviceName: $projectName
''';
