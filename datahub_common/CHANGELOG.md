## 0.0.1
- intial version

## 0.0.2
- updated boost dependency

## 0.0.3
- ignoreCase option for EnumField

## 0.0.3
- EnumField defaultValue fix

## 0.2.0
- TransferObject (API BREAKING):
  - .create constructor now requires a list of dto fields instead
    of generating it implicitly from the data map.
  - Default constructor now runs set() for all given fields to filter
    out invalid fields and convert field data into its valid type representation.

## 0.2.1
- fixed null value in TransferObject.set()

## 0.2.2
- fixed colored output in docker containers
- added example code