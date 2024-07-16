import 'package:boost/boost.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
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
  final _tracer = resolve<InstrumentationService>().defaultTracer;
  late final Minio _minio;

  MinioService([super.path]);

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

  @override
  Future<bool> bucketExists(String bucket) async {
    return await _tracer.trace(
      'check minio bucket',
      {
        'bucketName': bucket,
        'minioEndpoint': _minio.endPoint,
      },
      () async {
        return await _minio.bucketExists(bucket);
      },
    );
  }

  @override
  Future<List<Bucket>> listBuckets() async {
    return await _tracer.trace('list minio buckets', {
      'minioEndpoint': _minio.endPoint,
    }, () async {
      return await _minio.listBuckets();
    });
  }

  @override
  Future<void> makeBucket(String bucket, [String? region]) async {
    return await _tracer.trace(
      'make minio bucket',
      {
        'bucket': bucket,
        'minioEndpoint': _minio.endPoint,
      },
      () async {
        await _minio.makeBucket(bucket, region);
      },
    );
  }

  @override
  Future<void> removeBucket(String bucket) async {
    await _tracer.trace(
      'remove minio bucket',
      {
        'bucket': bucket,
        'minioEndpoint': _minio.endPoint,
      },
      () async {
        await _minio.removeBucket(bucket);
      },
    );
  }

  @override
  Stream<ListObjectsResult> listObjects(String bucket,
      {String? prefix, bool recursive = false}) async* {
    //TODO implement some way of tracing streams!?
    yield* await _tracer.trace(
      'list minio objects',
      {
        'minioEndpoint': _minio.endPoint,
      },
      () {
        return _minio.listObjects(bucket,
            prefix: prefix ?? '', recursive: recursive);
      },
    );
  }

  @override
  Future<MinioByteStream> getObject(String bucket, String object) async {
    return await _tracer.trace(
      'get minio object',
      {
        'bucket': bucket,
        'minioEndpoint': _minio.endPoint,
      },
      () async {
        return await _minio.getObject(bucket, object);
      },
    );
  }

  @override
  Future<String> putObject(
    String bucket,
    String object,
    Stream<List<int>> data, {
    int? size,
    int? chunkSize,
    Map<String, String>? metadata,
    void Function(int)? onProgress,
  }) async {
    return await _tracer.trace(
      'put minio object',
      {
        'bucket': bucket,
        'minioEndpoint': _minio.endPoint,
      },
      () async {
        return await _minio.putObject(
          bucket,
          object,
          data.asUint8List(),
          size: size,
          chunkSize: chunkSize,
          metadata: metadata,
          onProgress: onProgress,
        );
      },
    );
  }

  @override
  Future<void> removeObject(String bucket, String object) async {
    return await _tracer.trace(
      'remove minio object',
      {
        'bucket': bucket,
        'minioEndpoint': _minio.endPoint,
      },
      () async {
        await _minio.removeObject(bucket, object);
      },
    );
  }

  @override
  Future<void> removeObjects(String bucket, List<String> objects) async {
    return await _tracer.trace(
      'remove minio objects',
      {
        'bucket': bucket,
        'minioEndpoint': _minio.endPoint,
      },
      () async {
        await _minio.removeObjects(bucket, objects);
      },
    );
  }

  @override
  Future<StatObjectResult> statObject(String bucket, String object) async {
    return await _tracer.trace(
      'stat minio object',
      {
        'bucket': bucket,
        'minioEndpoint': _minio.endPoint,
      },
      () async {
        return await _minio.statObject(bucket, object);
      },
    );
  }
}
