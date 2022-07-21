String createReadme(String projectName) => '''# $projectName

This is a [DataHub][1] service.

***TODO:* Add service description here.**

## Configuration
This service requires at least one configuration file.
Provide the configuration file as command line argument.
You can split configuration files (f.e. config / secrets) into multiple files
and provide every separate file as an argument.

You can find the debug configuration file here:
`resources/debug.yaml`

## Run Service in Dart VM
Dart code can be executed without compiling.

#### Requirements
- Dart &#8805; 2.17 ([Setup][2])

#### Get Dependencies

```shell
^ dart pub get
```

#### Run Code Generator

```shell
\$ dart run build_runner build
```

#### Run

```shell
\$ dart run bin/$projectName.dart resources/debug.yaml
```

## Compile and Run
Compiled code runs faster, so this is the preferred method for deployment.
The resulting executable will be named `bin/$projectName.exe`.  
*The file extension is `exe` on linux or mac too, don't worry about it.*

#### Requirements
- Dart &#8805; 2.17 ([Setup][2])

#### Get Dependencies

```shell
\$ dart pub get
```

#### Run Code Generator

```shell
\$ dart run build_runner build
```

#### Compile

```shell
\$ dart compile exe bin/$projectName.dart
```

#### Run

```shell
\$ ./bin/$projectName.exe
```


## Build Debug Docker Image

#### Requirements
- Docker &#8805; 1.8 ([Setup][3])

This image will run the service in the vm. Code generation must be done on the host machine
first. The image will build very fast (no compile time) but the service itself will run a little slower.  
**This is only recommended for development / testing purposes.**

The resulting docker image will use the debug configuration: `resources/debug.yaml`.

#### Get Dependencies

```shell
\$ dart pub get
```

### Build using DataHub CLI

DataHub CLI will run the code generator, build the debug docker image and automatically tag
it as `$projectName:debug`.

#### Build
```shell
\$ datahub build -d
```

### Build using Docker CLI

When building debug images manually, make sure to run code generation first:

#### Run Code Generator
```shell
\$ dart run build_runner build
```

#### Build
```shell
\$ docker build -t $projectName:debug -f Dockerfile.debug .
```

## Build Release Docker Container

#### Requirements
- Docker &#8805; 1.8 ([Setup][3])

The resulting docker image will expect a config file at `/app/config.yaml`.
Best practice is to provide this config file via [bind mount][4] (Docker)
or [ConfigMap][5] / [Secrets][6] (Kubernetes).

### Build using DataHub CLI

DataHub CLI will build the release docker image and automatically and tag
it as `$projectName:latest` and `$projectName:{version}`.

#### Build

```shell
\$ datahub build
```

### Build using Docker CLI

#### Build and Tag
```shell
\$ docker tag $projectName:latest $projectName:{version}
\$ docker build -t $projectName:latest .
```

[1]: (https://datahubproject.net)
[2]: (https://dart.dev/get-dart)
[3]: (https://www.docker.com/get-started/)
[4]: (https://docs.docker.com/storage/bind-mounts/)
[5]: (https://kubernetes.io/docs/concepts/configuration/configmap/)
[6]: (https://kubernetes.io/docs/concepts/configuration/secret/)
''';
