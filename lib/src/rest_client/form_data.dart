class FormData {
  final Map<String, String> data;

  FormData(this.data);

  @override
  String toString() {
    return data.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
