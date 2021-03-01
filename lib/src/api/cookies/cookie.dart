class Cookie {
  final String name;
  final String value;
  final Duration? ttl;
  final bool secure;

  Cookie(this.name, this.value, this.ttl, this.secure);

}