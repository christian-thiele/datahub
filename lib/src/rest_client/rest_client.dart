import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';
import 'package:http/http.dart' as http;

import 'form_data.dart';
import 'rest_response.dart';
import 'url.dart';

Future<RestResponse<TResponse>> getObject<TResponse>(
  String endpoint, {
  String? baseUrl,
  Map<String, dynamic>? urlParams,
  Map<String, String?>? query,
  Map<String, String>? headers,
  TransferBean<TResponse>? bean,
}) async {
  return await request<TResponse, TResponse>(
      baseUrl, endpoint, urlParams, ApiRequestMethod.GET,
      headers: headers, bean: bean, query: query);
}

Future<RestResponse<List<TResponse>>> getList<TResponse>(
  String endpoint, {
  String? baseUrl,
  Map<String, dynamic>? urlParams,
  Map<String, String?>? query,
  Map<String, String>? headers,
  TransferBean<TResponse>? bean,
}) async {
  return await request<TResponse, List<TResponse>>(
      baseUrl, endpoint, urlParams, ApiRequestMethod.GET,
      headers: headers, bean: bean, query: query);
}

Future<RestResponse<TResponse>> postObject<TResponse>(
  String endpoint,
  dynamic object, {
  String? baseUrl,
  Map<String, dynamic>? urlParams,
  Map<String, String?>? query,
  Map<String, String>? headers,
  TransferBean<TResponse>? bean,
}) async {
  return await request<TResponse, TResponse>(
    baseUrl,
    endpoint,
    urlParams,
    ApiRequestMethod.POST,
    headers: headers,
    bean: bean,
    body: object,
    query: query,
  );
}

Future<RestResponse<TResponse>> putObject<TResponse>(
  String endpoint,
  dynamic object, {
  String? baseUrl,
  Map<String, dynamic>? urlParams,
  Map<String, String?>? query,
  Map<String, String>? headers,
  TransferBean<TResponse>? bean,
}) async {
  return await request<TResponse, TResponse>(
    baseUrl,
    endpoint,
    urlParams,
    ApiRequestMethod.PUT,
    headers: headers,
    bean: bean,
    body: object,
    query: query,
  );
}

Future<RestResponse<TResponse>> patchObject<TResponse>(
  String endpoint,
  dynamic object, {
  String? baseUrl,
  Map<String, dynamic>? urlParams,
  Map<String, String?>? query,
  Map<String, String>? headers,
  TransferBean<TResponse>? bean,
}) async {
  return await request<TResponse, TResponse>(
    baseUrl,
    endpoint,
    urlParams,
    ApiRequestMethod.PATCH,
    headers: headers,
    bean: bean,
    body: object,
    query: query,
  );
}

Future<RestResponse<TResponse>> rawRequest<TResponse>(
  ApiRequestMethod method,
  String endpoint, {
  String? baseUrl,
  dynamic body,
  Map<String, dynamic>? urlParams,
  Map<String, String?>? query,
  Map<String, String>? headers,
  TransferBean<TResponse>? bean,
}) async {
  return await request<TResponse, TResponse>(
    baseUrl,
    endpoint,
    urlParams,
    method,
    headers: headers,
    bean: bean,
    body: body,
    query: query,
  );
}

Future<RestResponse<void>> delete(
  String endpoint, {
  String? baseUrl,
  Map<String, dynamic>? urlParams,
  Map<String, String?>? query,
  Map<String, String>? headers,
}) async {
  return await request<void, void>(
    baseUrl,
    endpoint,
    urlParams,
    ApiRequestMethod.DELETE,
    headers: headers,
    query: query,
  );
}

Future<RestResponse<TResponse>> request<TData, TResponse>(
  String? baseUrl,
  String suffix,
  Map<String, dynamic>? urlParams,
  ApiRequestMethod method, {
  Map<String, String>? headers,
  Map<String, String?>? query,
  dynamic body,
  TransferBean<TData>? bean,
}) async {
  final urlBuffer = StringBuffer(baseUrl ?? '');
  urlBuffer.write(replacePlaceholders(suffix, urlParams ?? {}));

  if (query?.isNotEmpty ?? false) {
    urlBuffer.write(buildQueryString(query!));
  }

  headers ??= {};

  //TODO better way of object encoding (maybe transfer-encodable interface?)
  dynamic encodedBody;
  if (body is Uint8List) {
    encodedBody = body;
    headers['Content-type'] = 'application/octet-stream;';
  } else if (body is String) {
    encodedBody = body;
  } else if (body is FormData) {
    encodedBody = body.toString();
    headers['Content-type'] = 'application/x-www-form-urlencoded';
  } else if (body != null) {
    encodedBody = jsonEncode(body);
    headers['Content-type'] = 'application/json; charset=UTF-8';
  }

  final response = await _dispatch(
      method, Uri.parse(urlBuffer.toString()), headers, encodedBody);

  return handleResponse<TData, TResponse>(response, bean);
}

RestResponse<TResponse> handleResponse<TData, TResponse>(
  http.Response response,
  TransferBean<TData>? bean,
) {
  try {
    if (response.statusCode < 400) {
      final data = _handleData<TData, TResponse>(response.bodyBytes, bean);
      return RestResponse<TResponse>(response, data);
    } else {
      return RestResponse(response, null);
    }
  } on Exception catch (e) {
    throw ApiException('Could not process response data.', e);
  }
}

TResponse? _handleData<TData, TResponse>(
  Uint8List data,
  TransferBean<TData>? bean,
) {
  final responseType = TypeCheck<TResponse>();
  if (TResponse != TData && (!responseType.isListOf<TData>())) {
    throw ApiError(
        'Invalid data and response type combination: ${TData.toString()}, ${TResponse.toString()}');
  }

  if (data.isEmpty) {
    return null;
  }

  //TODO encoding from response content-type
  final encoding = utf8;

  if (bean != null) {
    final obj = jsonDecode(encoding.decode(data));
    if (obj is Map<String, dynamic>) {
      final decodedData = bean.toObject(obj);
      if (responseType.isList) {
        return [decodedData] as TResponse;
      } else {
        return decodedData as TResponse;
      }
    } else if (obj is List) {
      if (responseType.isList) {
        return obj.map((e) => bean.toObject(e)).toList() as TResponse;
      }
    }

    throw ApiException('Invalid response.');
  } else if (TResponse == String) {
    return encoding.decode(data) as TResponse;
  } else if (TResponse == int) {
    return int.parse(encoding.decode(data)) as TResponse;
  } else if (TResponse == double) {
    return double.parse(encoding.decode(data)) as TResponse;
  } else if (TResponse == Uint8List) {
    return data as TResponse;
  } else if (responseType.isMapOf<String, dynamic>() || responseType.isList) {
    return jsonDecode(encoding.decode(data)) as TResponse;
  } else if (TResponse == Null) {
    return null;
  }

  throw ApiError.invalidType(TResponse);
}

Future<http.Response> _dispatch(
  ApiRequestMethod type,
  Uri url,
  Map<String, String>? headers,
  dynamic body,
) async {
  switch (type) {
    case ApiRequestMethod.GET:
      return await http.get(url, headers: headers);
    case ApiRequestMethod.POST:
      return await http.post(url, headers: headers, body: body);
    case ApiRequestMethod.PUT:
      return await http.put(url, headers: headers, body: body);
    case ApiRequestMethod.PATCH:
      return await http.patch(url, headers: headers, body: body);
    case ApiRequestMethod.DELETE:
      return await http.delete(url, headers: headers);
    default:
      throw ApiError('Invalid request type: $type');
  }
}
