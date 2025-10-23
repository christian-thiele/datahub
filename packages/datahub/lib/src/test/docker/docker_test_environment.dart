class DockerTestService {
  final String name;
  final String image;
  final Map<String, String> env;

  DockerTestService(this.name, this.image, {this.env = const {}});
}

class DockerTestEnvironment {
  final List<DockerTestService> services;

  DockerTestEnvironment({required this.services});

  Future<void> up() async {
    
  }

}