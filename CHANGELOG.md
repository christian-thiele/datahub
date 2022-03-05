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

## 0.2.1
- ApiRequest (API BREAKING):
  - Uses Stream<List<int>> for body data.
  - added getByteData()
  - getTextBody and getJsonBody are now async

## 0.2.2
- updated datahub_common dependency (now requires ^0.2.0)

## 0.2.4
- Uint8List support workaround for postgres lib

## 0.2.5
- exported Middleware class

## 0.2.6
- fixed EnumField bug in DTO

## 0.3.0
- ServiceHost:
  - added tryResolve (does not throw if service is not registered, returns null instead)
- refactored SchedulerService to services
- added LogService
- removed old Config class (boost ConfigParser recommended instead)
- added ApiService

## 0.3.0
- added onInitialized to ServiceHost

## 0.4.0
- LogService:
  - fixed "error"-bug when calling method "e"
- ServiceHost:
  - static tryResolve
  - improved critical error log
- added modular ConfigService api
- ApiService:
  - requires ConfigService<ApiConfig>
- added config class builder (GenerateConfig annotation) using ConfigParser from boost
- INTRODUCING: TransferBean (simplifies DTOs)
- added TransferBean builder (builds Beans for DTOs)
- ApiResponse:
  - statusCode is now *named* optional
- JsonResponse:
  - when using a DTO, a bean is required (named optional parameter)

## 0.4.1
- fixed some nullable issues in TransferBeanGenerator

## 0.4.2
- fixed ObjectFieldType nullable bug in TransferBeanGenerator

## 0.4.3
- added copyWith method generator for TransferObjects

## 0.4.4
- fixed stdout flush bug in ConsoleLogBackend

## 0.5.0
- refactored builder to datahub package for appbase compatibility for datahub_common

## 0.5.1
- changed path dependecy to ^1.8.0 for flutter dev_dependency support

## 0.5.2
- config service implementations don't have to implement initialize/shutdown