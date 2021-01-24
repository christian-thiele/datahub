import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/src/api/api_request_exception.dart';

enum ApiRequestMethod {
  GET, POST, PUT, PATCH, DELETE
}

ApiRequestMethod parseMethod(String source) {
  if (source.toLowerCase() == 'get') {
    return ApiRequestMethod.GET;
  }

  if (source.toLowerCase() == 'post') {
    return ApiRequestMethod.POST;
  }

  if (source.toLowerCase() == 'put') {
    return ApiRequestMethod.PUT;
  }

  if (source.toLowerCase() == 'patch') {
    return ApiRequestMethod.PATCH;
  }

  if (source.toLowerCase() == 'delete') {
    return ApiRequestMethod.DELETE;
  }

  throw ApiException('Could not parse method: $source');
}