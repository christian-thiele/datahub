import 'package:datahub_aperture/datahub_aperture.dart';

abstract interface class ApertureResourceRepository {
  Future<ResourceData> getElement(String id, String? revisionId);

  Future<ResourceElementsResponse> getElements(
    ResourceFilter? filter,
    int offset,
    int limit,
  );
}

abstract interface class ApertureResourceWriteRepository
    implements ApertureResourceRepository {
  Future<ResourceData> createElement(
    Map<String, dynamic> data,
    DateTime? revisionLive,
  );

  Future<ResourceData> updateElement(
    String id,
    Map<String, dynamic> data,
    DateTime? revisionLive,
  );

  Future<ResourceData?> deleteElement(
    String id,
    DateTime? revisionLive,
  );
}
