class HttpResponse {
  final Uri requestUrl;
  final int statusCode;
  final Map<String, List<String>> headers;
  final Stream<List<int>> bodyData;

  HttpResponse(this.requestUrl, this.statusCode, this.headers, this.bodyData);
}
