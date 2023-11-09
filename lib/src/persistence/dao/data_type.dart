import 'dart:typed_data';

abstract class DataType<T> {
  const DataType();
}

class StringDataType extends DataType<String> {
  const StringDataType();
}

class IntDataType extends DataType<int> {
  const IntDataType();
}

class DoubleDataType extends DataType<double> {
  const DoubleDataType();
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

class StringArrayDataType extends DataType<List<String>> {
  const StringArrayDataType();
}

class IntArrayDataType extends DataType<List<int>> {
  const IntArrayDataType();
}

class DoubleArrayDataType extends DataType<List<double>> {
  const DoubleArrayDataType();
}

class BoolArrayDataType extends DataType<List<bool>> {
  const BoolArrayDataType();
}

class JsonListDataType extends DataType<List<dynamic>> {
  const JsonListDataType();
}

class JsonMapDataType extends DataType<Map<String, dynamic>> {
  const JsonMapDataType();
}
