## 0.16.0
- Added HttpClient / HttpServer as multi-version HTTP implementations
- ApiService
  - added HTTP/2 support (using HttpServer)
  - added protocol negotiation
- ByteStreamResponse / FileResponse
  - Content-Disposition is transmitted regardless of availability of filename
- RestClient
  - added HTTP/2 support (using HttpClient)
  - header values are now List<String> instead of String
  - URL-parms are now encoded using RoutePattern
  - added HttpAuth, BearerAuth, BasicAuth
- Persistence
  - added any, first, count as extensions to DatabaseContext
  - added any, first, count, mutate operations to CRUDRepository
  - added context parameter to all CRUDRepository methods to allow compositing
- Broker
  - added EventHubs
  - Utils
    - added MIME type / extension mapper
  - added Collection Library

## 0.15.2
- ApiService
  - fixed internal error when handling request not matching base path

## 0.15.1
- DatabaseContext.query
  - inner and outer joins supported with nullable / non-null return types

## 0.15.0
- DataBean
  - reduced complexity on abstract classes
  - changed type constraints on DatabaseContext methods
- DatabaseContext.query
  - can now return DAOs from joins (no longer constrained to DataBean as source)

## 0.14.9
- added Duration to transfer codec (represented as milliseconds)

## 0.14.8
- DataHub CLI
  - fixed build-args feature

## 0.14.7
- DataHub CLI
  - fixed build-args feature

## 0.14.6
- DataHub CLI
  - added build-args support

## 0.14.5
- ApiRequest
  - added getBody for transfer objects as request body

## 0.14.4
- fixed Repository transaction return value

## 0.14.3
- fixed SQL building for postgres (name escape bugs)

## 0.14.2
- fixed rest_client with Map<String, dynamic> / List

## 0.14.1
- fixed Repository (missing initializeSchema)

## 0.14.0
- updated boost dependency
- added rest_client library

## 0.13.2
- use "Authorization" header instead of "session-token"

## 0.13.1
- moved decodeTyped to utils library
- added List<String>, List<int>, List<double> to decodeTyped
- ConfigService.fetch / BaseService.config now accepts nullable types

## 0.13.0
- Transaction Support
  - added DatabaseContext
  - database migrations run in transactions
- added Repository and CRUDRepository

## 0.12.4
- added force flag to datahub create (CLI)

## 0.12.3
- fixed dart pub get call in CLI

## 0.12.2
- added DataHub CLI

## 0.12.1
- fixed dependencies

## 0.12.0
- Started datahub package
- All code generation is now in datahub_codegen