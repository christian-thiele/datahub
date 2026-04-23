class RevisionData<T> {
  final T data;
  final int version;
  final String creator;
  final DateTime created;
  final DateTime from;
  final DateTime? to;
  final bool isDeleted;

  const RevisionData({
    required this.data,
    required this.version,
    required this.creator,
    required this.created,
    required this.from,
    required this.to,
    required this.isDeleted,
  });
}
