/// Optional annotation for config class fields to provide meta information.
class ConfigOption {
  final String? abbr;
  final String? env;
  final dynamic defaultValue;

  const ConfigOption({
    this.abbr,
    this.env,
    this.defaultValue,
  });
}
