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

## 0.5.3
- fixed builders in tests
- config_generator now generates ConfigService directly

## 0.6.0
- AMQP Broker Api & Client generator

## 0.6.1
- initialization log message

## 0.6.2
- added initializing log message to generated amqp services

## 0.6.3
- BrokerAPI
  - RPC error handling
  - multi param endpoints
  - primitive return type fix

## 0.6.4
- BrokerAPI
  - ack for reply queues

## 0.6.5
- BrokerAPI
  - unified Exceptions with rest API (ApiRequestException)

## 0.6.6
- ServiceHost
  - removed BaseService constraint on resolve methods

## 0.6.7
- BrokerAPI
  - fixed exception handling

## 0.6.8
- ServiceHost
  - improved startup error handling

## 0.6.7
- LogMiddleware
  - log status codes >= 500 as error

## 0.7.0
- INTRODUCING: DataBean
  - Breaking Persistence API changes
  - No more mirror dependency! Happy AOT compiling!
- CopyWith builder can be used standalone with @CopyWith() annotation

## 0.7.1
- re-enabled custom selects

## 0.7.2
- fixed generic types in copy_with_generator

## 0.7.3
- added PropertyCompareType.NotEquals

## 0.7.4
- fixed Filter.equals / Filter.notEquals with value null

## 0.7.5
- fixed non-autoIncrement insert

## 0.7.6
- added ignoreMigration to initializeSchema

## 0.7.7
- added support for json field types in persistence

## 0.7.8
- TransferObject toJson / toMap does not include null values in output
- fixed warnings in generated code

## 0.8.0
- ServiceHost
  - Config do-over
  - Environment setting
  - LogLevel setting
  - shutdown on failure fix
- Persistence
  - added PropertyCompareType.In
- ApiService
  - ApiService + ApiBase is now just ApiService
  - in DEV-Environment, ApiEndpoints return debug information on errors

## 0.8.1
- ServiceHost
  - fixed config file loading

## 0.8.2
- ServiceHost
  - fixed config file loading

## 0.8.3
- removed log message for config file loading
- fixed uppercase log and environment values

## 0.8.4
- SchedulerService
  - fixed RepeatSchedule

## 0.8.5
- SchedulerService
  - fixed RepeatSchedule

## 0.9.0
- added JoinedQuerySource
- DatabaseConnection
  - select method accepts broad QuerySource instead of narrow DataBean
- QuerySelect
  - DataField now implements QuerySelect directly (no FieldSelect required)
  - FieldSelect provides alias field
  - WildcardSelect provides bean field to only select bean fields in joins
- ServiceHost
  - static IoT hook released when host lifecycle is over

## 0.9.1
- mainField and otherField on DataBean.join are optional

# 0.10.0
- renamed PropertyCompareType to CompareType
- refactored CompareType values to lower camel case
- added Expression
  - added Expression convenience methods to create Filter objects
  - added Expression convenience methods to create Sort objects
- PropertyCompare has been replaced by CompareFilter
- FieldSort has been replaced by ExpressionSort