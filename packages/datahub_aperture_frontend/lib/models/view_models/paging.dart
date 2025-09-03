class Paging {
  final int offset;
  final int length;
  final int pageSize;
  final int? total;
  final bool hasMore;

  const Paging({
    required this.offset,
    required this.length,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });

  const Paging.empty(int offset, int pageSize)
    : this(
        offset: offset,
        pageSize: pageSize,
        length: 0,
        total: null,
        hasMore: false,
      );

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(offset);
    buffer.write(' - ');
    buffer.write(offset + length);
    buffer.write(' / ');
    if (total != null) {
      buffer.write(total);
    } else {
      if (hasMore) {
        buffer.write('...');
      } else {
        buffer.write(offset + length);
      }
    }
    return buffer.toString();
  }
}
