import 'package:datahub/datahub.dart';
import 'package:minio/models.dart';

abstract class S3Service extends BaseService {
  Future<bool> bucketExists(String bucket);

  Future<List<Bucket>> listBuckets();

  Future<void> makeBucket(String bucket, [String? region]);

  Future<void> removeBucket(String bucket);

  Stream<ListObjectsResult> listObjects(String bucket,
      [String? prefix, bool recursive = false]);

  Future<void> getObject(String bucket, String object);

  Future<String> putObject(String bucket, String object, Stream<List<int>> data,
      {int? size,
      int? chunkSize,
      Map<String, String>? metadata,
      void Function(int)? onProgress});

  Future<void> removeObject(String bucket, String object);

  Future<void> removeObjects(String bucket, List<String> objects);

  Future<StatObjectResult> statObject(String bucket, String object);
}
