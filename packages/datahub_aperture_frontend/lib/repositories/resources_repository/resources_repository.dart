import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:datahub_aperture_frontend/repositories/repository.dart';

abstract interface class ResourcesRepository implements Repository {
  Future<List<ResourceDescription>> getDescriptions(Authentication auth);

  Future<ResourceDescription> getDescription(Authentication auth, String id);

  Future<ResourceElementsResponse> getResourceElements(
    Authentication authentication,
    String resourceId, {
    ResourceFilter? filter,
    int offset = 0,
    int limit = 25,
  });

  Future<ResourceData> getResourceElement(
    Authentication auth,
    String resourceId,
    String elementId, {
    String? revisionId,
  });

  Future<ResourceData> updateElement(
    Authentication auth,
    String resourceId,
    String elementId,
    Map<String, dynamic> changes,
    DateTime? revisionLive,
  );

  Future<ResourceData> createElement(
    Authentication authentication,
    String resourceId,
    Map<String, dynamic> changes,
    DateTime? revisionLive,
  );

  Future<ResourceData?> deleteElement(
    Authentication authentication,
    String resourceId,
    String elementId,
    DateTime? revisionLive,
  );
}
