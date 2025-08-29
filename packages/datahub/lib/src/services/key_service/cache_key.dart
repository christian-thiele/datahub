class CacheKey {
  final Uri jwks;
  final String alg;
  final String kid;

  const CacheKey(this.jwks, this.alg, this.kid);

  @override
  bool operator ==(Object other) {
    if (other is CacheKey) {
      return jwks == other.jwks && alg == other.alg && kid == other.kid;
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([jwks, alg, kid]);

  @override
  String toString() => '$jwks : $kid ($alg)';
}
