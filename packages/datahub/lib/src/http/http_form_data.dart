class HttpFormData {
  final Map<String, String> data;

  HttpFormData(this.data);

  factory HttpFormData.parse(String body) {
    final fields = body.split('&');
    final data = <String, String>{};
    for (final field in fields) {
      final delimiter = field.indexOf('=');
      if (delimiter > 0) {
        data[Uri.decodeComponent(field.substring(0, delimiter))] =
            Uri.decodeComponent(field.substring(delimiter + 1));
      } else if (delimiter == -1) {
        data[Uri.decodeComponent(field)] = '';
      }
    }
    return HttpFormData(data);
  }

  @override
  String toString() {
    return data.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
