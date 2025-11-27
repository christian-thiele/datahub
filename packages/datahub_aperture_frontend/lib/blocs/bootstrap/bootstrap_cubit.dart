import 'package:datahub/api.dart';
import 'package:datahub_aperture_frontend/repositories/bootstrap_repository/bootstrap_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datahub_aperture/api.dart';

part 'bootstrap_state.dart';

class BootstrapCubit extends Cubit<BootstrapState> {
  final BootstrapRepository _bootstrapRepository;

  BootstrapCubit(this._bootstrapRepository) : super(BootstrapLoading()) {
    _update();
  }

  Future<void> update() async {
    if (state is! BootstrapLoading) {
      await _update();
    }
  }

  Future<void> _update() async {
    emit(BootstrapLoading());
    try {
      final bootstrap = await _bootstrapRepository.fetch();
      emit(BootstrapSuccess(bootstrap: bootstrap));
    } catch (e) {
      switch (e) {
        case ApiRequestException(statusCode: 500):
          emit(BootstrapError(message: 'Fetching bootstrap data failed.'));
        default:
          emit(BootstrapError(message: 'Could not find bootstrap endpoint.'));
      }
    }
  }
}
