class CacheKey {
  final Uri issuer;
  final String alg;
  final String kid;

  CacheKey(this.issuer, this.alg, this.kid);

  @override
  bool operator ==(Object other) {
    if (other is CacheKey) {
      return issuer == other.issuer && alg == other.alg && kid == other.kid;
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([issuer, alg, kid]);

  @override
  String toString() => '$issuer : $kid ($alg)';
}
