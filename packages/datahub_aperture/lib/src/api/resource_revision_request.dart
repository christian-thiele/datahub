import 'package:datahub/datahub.dart';

part 'resource_revision_request.g.dart';

@Data()
class const ResourceRevisionRequest({
  required final Map<String, dynamic> fieldData,
  final DateTime? from,
}) extends $ResourceRevisionRequest;
