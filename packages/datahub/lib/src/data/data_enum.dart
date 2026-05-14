/// Interface for Enums used in Data classes providing the ability to define
/// json values for enums other than [name].
abstract interface class DataEnum implements Enum {
  String get jsonValue => name;
}