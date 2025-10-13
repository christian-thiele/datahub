import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/services/auth_service.dart';

abstract class ApiRepository {
  final String baseUrl;
  late final Lazy<RestClient> _restClient = Lazy(
    () => RestClient.connect(
      Uri.parse(baseUrl),
      timeout: const Duration(seconds: 10),
    ),
  );

  ApiRepository({required this.baseUrl});

  Future<RestClient> getClient() async {
    final client = await _restClient.get();
    client.auth = await AuthService.instance.getValidAccessToken();
    return client;
  }

  Future<void> close() async {
    if (_restClient.isInitialized) {
      final client = await _restClient.get();
      _restClient.invalidate();
      await client.close();
    }
  }
}
