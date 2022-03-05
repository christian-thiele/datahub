/// Transfer object class annotation.
///
/// [TransferBeanGenerator] will generate a bean for all classes that are
/// annotated with this.
///
/// Classes annotated with [TransferObject] must be immutable PODO objects
/// that extend [_TransferObject] which is generated individually.
///
/// TransferObjects can have fields of type String, int, double, bool,
/// Uint8List, Map and List or any Enum. Map and List element types are also
/// restricted to those types.
class TransferObject {
  const TransferObject();
}
