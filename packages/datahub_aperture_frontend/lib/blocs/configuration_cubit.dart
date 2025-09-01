import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'configuration_state.dart';

class ConfigurationCubit extends Cubit<ConfigurationState> {
  final ResourcesRepository _resourcesRepository;
  final Authentication _authentication;

  ConfigurationCubit(this._resourcesRepository, this._authentication)
    : super(ConfigurationLoading(initial: true)) {
    update();
  }

  Future<void> update() async {
    if (state case ConfigurationLoading(_initial: false)) {
      return;
    }

    try {
      final resources = await _resourcesRepository.getDescriptions(
        _authentication,
      );

      emit(ConfigurationValue(resources: resources));
    } catch (e) {
      emit(ConfigurationError(message: e.toString()));
    }
  }
}
