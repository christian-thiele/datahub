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