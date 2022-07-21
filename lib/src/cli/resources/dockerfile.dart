String createDockerfile(String projectName) =>
    '''# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/$projectName.dart -o bin/$projectName

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch

WORKDIR /app
COPY --from=build /runtime/ /
COPY --from=build /app/bin/$projectName /app/bin/
COPY --from=build /app/resources/ /app/resources

# Start server.
# TODO If your service exposes any ports, you should add those here.

CMD ["./bin/$projectName", "config.yaml"]
''';

String createDebugDockerfile(String projectName) =>
    '''# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline

# Start service.
# TODO If your service exposes any ports, you should add those here.

CMD ["dart", "bin/$projectName.dart", "resources/debug.yaml"]''';
