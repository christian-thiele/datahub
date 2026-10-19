import 'package:datahub/datahub.dart';

import 'resource_data.dart';

part 'resource_elements_response.g.dart';

@Data()
class const ResourceElementsResponse({
  required final int? total,
  required final bool hasNextPage,
  required final List<ResourceData> data,
}) extends $ResourceElementsResponse;
