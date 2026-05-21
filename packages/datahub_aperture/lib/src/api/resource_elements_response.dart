import 'package:datahub/datahub.dart';

import 'resource_data.dart';

part 'resource_elements_response.g.dart';

@Data()
class ResourceElementsResponse extends $ResourceElementsResponse {
  final int? total;
  final bool hasNextPage;
  final List<ResourceData> data;

  const ResourceElementsResponse({
    required this.total,
    required this.hasNextPage,
    required this.data,
  });
}
