import 'package:boost/boost.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';

import 's3_service.dart';

/// Service for accessing a MinIO object storage.
///
/// Configuration:
///   - `endpoint` - MinIO API endpoint
///   - `port` - MinIO API port (default 9000)
///   - `accessKey` - MinIO access key
///   - `secretKey` - MinIO secret key
///   - `useSsl` - Use SSL connection (default false)
///   - `region` - Override region cache (Optional)
///   - `sessionToken` - x-amz-security-token (AWS S3 specific) (Optional)
///   - `enableTrace` - Enable tracing (default false)
class MinioService extends S3Service {
  late final Minio _minio;

  @override
  Future<void> initialize() async {
    _minio = Minio(
      endPoint: config<String>('endpoint'),
      port: config<int?>('port') ?? 9000,
      accessKey: config<String>('accessKey'),
      secretKey: config<String>('secretKey'),
      useSSL: config<bool?>('useSsl') ?? false,
      region: config<String?>('region'),
      sessionToken: config<String?>('sessionToken'),
      enableTrace: config<bool?>('enableTrace') ?? false,
    );
  }

  Future<bool> bucketExists(String bucket) async =>
      await _minio.bucketExists(bucket);

  Future<List<Bucket>> listBuckets() async => await _minio.listBuckets();

  Future<void> makeBucket(String bucket, [String? region]) async =>
      await _minio.makeBucket(bucket, region);

  Future<void> removeBucket(String bucket) async =>
      await _minio.removeBucket(bucket);

  Stream<ListObjectsResult> listObjects(String bucket,
          [String? prefix, bool recursive = false]) =>
      _minio.listObjects(bucket, recursive: recursive);

  Future<void> getObject(String bucket, String object) async =>
      await _minio.getObject(bucket, object);

  Future<String> putObject(String bucket, String object, Stream<List<int>> data,
          {int? size,
          int? chunkSize,
          Map<String, String>? metadata,
          void Function(int)? onProgress}) async =>
      await _minio.putObject(
        bucket,
        object,
        data.asUint8List(),
        size: size,
        chunkSize: chunkSize,
        metadata: metadata,
        onProgress: onProgress,
      );

  Future<void> removeObject(String bucket, String object) async =>
      await _minio.removeObject(bucket, object);

  Future<void> removeObjects(String bucket, List<String> objects) async =>
      await _minio.removeObjects(bucket, objects);

  Future<StatObjectResult> statObject(String bucket, String object) async =>
      await _minio.statObject(bucket, object);
}
