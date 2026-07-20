import 'package:bloc/bloc.dart';
import 'package:datahub/api.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';

part 'module_state.dart';

class ModuleCubit extends Cubit<ModuleState> {
  final ResourcesRepository _resourceRepository;
  final String moduleId;

  ModuleCubit(this._resourceRepository, {required this.moduleId})
    : super(const ModuleLoading(true)) {
    update();
  }

  void update() async {
    if (state case ModuleLoading(_initial: false)) {
      return;
    }

    emit(ModuleLoading());
    try {
      final modules = await _resourceRepository.getModules();
      final module = modules.firstWhere(
        (m) => m.id == moduleId,
        orElse: () => throw ApiRequestException.notFound('Module not found.'),
      );
      emit(ModuleLoaded(module: module));
    } catch (e) {
      if (e case ApiRequestException(:final message)) {
        emit(ModuleError(message: message));
      } else {
        emit(ModuleError());
      }
    }
  }
}
