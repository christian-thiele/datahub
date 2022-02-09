## 0.0.1
- Initial version

## 0.0.5
- updated boost dependency

## 0.0.17
- updated datahub_common

## 0.0.18
- ServiceHost

## 0.0.19
- fixed ServiceHost shutdown

## 0.0.20
- SchedulerService
- default services in ServiceHost (SchedulerService as first)

## 0.0.21
- fixed ServiceHost resolving uninitialized services 

## 0.0.22
- added request param in getMetaData in ListHubResource
- added getSize to ListHubResource

## 0.0.23
- fixed meta-data route matching

## 0.0.24
- EnumField defaultValue fix

## 0.0.25
- fixed datahub_common dependency

## 0.1.0
- first alpha release
- ServiceHost failWithServices

## 0.2.0
- TransferObject (API BREAKING):
  - .create constructor now requires a list of dto fields instead
    of generating it implicitly from the data map.
  - Default constructor now runs set() for all given fields to filter
    out invalid fields and convert field data into its valid type representation.
- ApiResponse (API BREAKING):
  - Body data is now provided as Stream<List<int>> instead of Uint8List.
  - added ByteStreamResponse
  - added FileResponse