class const RevisionData<T>({
  required final T data,
  required final int version,
  required final String creator,
  required final DateTime created,
  required final DateTime from,
  required final DateTime? to,
  required final bool isDeleted,
});
