class RevisionData<T> {
  final T data;
  final int sysVersion;
  final String sysCreator;
  final DateTime sysCreated;
  final DateTime sysFrom;
  final DateTime? sysTo;
  final bool sysIsDeleted;

  RevisionData({
    required this.data,
    required this.sysVersion,
    required this.sysCreator,
    required this.sysCreated,
    required this.sysFrom,
    required this.sysTo,
    required this.sysIsDeleted,
  });
}
