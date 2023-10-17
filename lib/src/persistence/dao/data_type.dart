import 'dart:typed_data';

abstract class DataType<T> {
  const DataType();
}

class StringDataType extends DataType<String> {
  final int length;

  const StringDataType({this.length = 255});
}

class IntDataType extends DataType<int> {
  final int length;

  const IntDataType({this.length = 64});
}

class SerialDataType extends DataType<int> {
  final int length;

  const SerialDataType({this.length = 64});
}

class DoubleDataType extends DataType<double> {
  final int length;

  const DoubleDataType({this.length = 64});
}

class BoolDataType extends DataType<bool> {
  const BoolDataType();
}

class ByteDataType extends DataType<Uint8List> {
  const ByteDataType();
}

class DateTimeDataType extends DataType<DateTime> {
  const DateTimeDataType();
}

class JsonListDataType extends DataType<List<dynamic>> {
  const JsonListDataType();
}

class JsonMapDataType extends DataType<Map<String, dynamic>> {
  const JsonMapDataType();
}