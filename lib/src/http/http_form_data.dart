class HttpFormData {
  final Map<String, String> data;

  HttpFormData(this.data);

  @override
  String toString() {
    return data.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
