## 2.0.0

### Features added:

- Types
    - added accepts() method to TypeCheck
    - added toString() method to TypeCheck

### Obsolete Features removed:

- Structures
    - removed Tuple and Triple
- Collections
    - removed whereIs

## 1.8.10

- Bytes
    - collect

## 1.8.9

- Lazy
    - reinitializeOnValue
    - reinitializeOnError

## 1.8.8

- IterableExtension
    - mapIndexed

## 1.8.7

- Lazy
    - invalidate

## 1.8.6

- Lazy
- Semaphore
    - fixed synchronous deadlock bug

## 1.8.5

- TypeChecker
    - isExact, name
    - fixed equality

## 1.8.4

- TypeChecker
    - const constructor

## 1.8.3

- fixed barrel file

## 1.8.2

- IntListExtension
    - asUint8List
- IntListStreamExtension
    - asUint8List
- apply

## 1.8.1

- TypeCheck
    - added isNullable, isIterable, toNullable, toList, toIterable, isSupertypeOf
- fixed warnings

## 1.8.0

- min Dart version is now 2.17.0
- removed enumName (this is now dart core functionality)
- cleaner findEnum / tryFindEnum implementation

## 1.7.0

- TypeCheck replaces Type extension methods
    - this fixes flutter web compatibility

## 1.6.0

- Version (a semver version util)

## 1.5.2

- CancellationToken
    - cancelOn: fixed "Future already completed" exception when calling cancel() after target Future completed

## 1.5.1

- Config
    - fixed null handling for string arguments

## 1.5.0

- Bytes
    - toHexString

## 1.4.0

- ConfigParser

## 1.3.0

- Tuple.factory
- Triple.factory

## 1.2.0

- Math
    - toRadians
    - toDegrees

## 1.1.0

- Types
    - isSubtypeOf

## 1.0.0

- First Major Release!
- _Breaking API change:_
  Semaphore.debounce() was renamed to Semaphore.throttle to match
  reactive conventions.
  Semaphore.debounce was added with correct debounce functionality.
- fixed bug in Semaphore.debounce()

## 0.0.11-nullsafety

- Math
    - clamp
- Concurrency
    - Semaphore.debounceLatest

## 0.0.10-nullsafety

- Enums
    - enumName

## 0.0.9-nullsafety

- Enums
    - findEnum
    - tryFindEnum

## 0.0.8-nullsafety

- Notifier
    - addOneShot

## 0.0.7-nullsafety

- Concurrency
    - Semaphore

## 0.0.6-nullsafety

- Collections
    - whereIs
    - a, b, c for tuple / triple iterables

## 0.0.5-nullsafety

- Collections
    - firstOrNullWhere

## 0.0.4-nullsafety

- Collections
    - min
    - max
- Math
    - round
- Structures
    - toJson for Tuples / Triples

## 0.0.3-nullsafety

- Concurrency
    - CancellationToken
    - runGuarded
- Notifier
- String Utils
    - nullOrEmpty
    - nullOrWhitespace

## 0.0.2-nullsafety

- IterableExtension
    - distinct
    - groupBy
    - sequenceEquals
    - split

- ListExtension
    - replaceItem
    - sortBy

## 0.0.1-nullsafety

- Initial version