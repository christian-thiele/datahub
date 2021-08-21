import 'dart:convert';
import 'dart:io';

//TODO fail-fast refactor (?)
class Config {
  final Map<String, dynamic> _defaults;
  final Map<String, dynamic> _values = {};

  Config(this._defaults);

  dynamic operator [](String key) => _values[key] ?? _defaults[key];

  operator []=(String key, dynamic value) => _values[key] = value;

  bool containsKey(String key) =>
      _values.containsKey(key) || _defaults.containsKey(key);

  bool containsNonDefaultKey(String key) => _values.containsKey(key);

  void addAll(Map<String, dynamic> other) => _values.addAll(other);

  void addEntries(Iterable<MapEntry<String, dynamic>> entries) =>
      _values.addEntries(entries);

  String? getString(String key) => this[key]?.toString();

  int getInt(String key) => containsKey(key)
      ? (this[key] is int ? this[key] : int.tryParse(this[key]))
      : null;

  double getDouble(String key) => containsKey(key)
      ? (this[key] is double ? this[key] : double.tryParse(this[key]))
      : null;

  File? getFile(String key) {
    if (containsKey(key)) {
      return File(this[key]);
    } else {
      return null;
    }
  }

  Future loadJsonFile(File f) async {
    loadJson(await f.readAsString());
  }

  void loadJson(String json) {
    addAll(JsonDecoder().convert(json) as Map<String, dynamic>);
  }

  //TODO parse args as config values (not only config file)
  Future loadArgs(List<String> args) async {
    if (args.isNotEmpty) {
      final configFile = File(args.first);
      if (await configFile.exists()) {
        await loadJsonFile(configFile);
      } else {
        print('Could not load config file: ${configFile.absolute.path}'); //TODO logging
      }
    }
  }
}
