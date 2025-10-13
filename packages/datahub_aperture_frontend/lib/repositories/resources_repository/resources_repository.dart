import 'package:datahub_aperture/datahub_aperture.dart';

abstract interface class ResourcesRepository {
  Future<List<ResourceDescription>> getDescriptions();

  Future<List<ModuleDescription>> getModules();

  Future<ResourceDescription> getDescription(String id);

  Future<ResourceElementsResponse> getResourceElements(
    String resourceId, {
    ResourceFilter? filter,
    int offset = 0,
    int limit = 25,
  });

  Future<ResourceData> getResourceElement(
    String resourceId,
    String elementId, {
    String? revisionId,
  });

  Future<ResourceData> updateElement(
    String resourceId,
    String elementId,
    Map<String, dynamic> changes,
    DateTime? revisionLive,
  );

  Future<ResourceData> createElement(
    String resourceId,
    Map<String, dynamic> changes,
    DateTime? revisionLive,
  );

  Future<ResourceData?> deleteElement(
    String resourceId,
    String elementId,
    DateTime? revisionLive,
  );

  Future<Map<String, dynamic>> startElementAction(
    String resourceId,
    String elementId,
    String actionId,
  );
}
