import 'package:datahub/data.dart';

part 'jwk.g.dart';

/// Json Web Key
///
/// Sources:
/// https://datatracker.ietf.org/doc/html/rfc7517
/// https://datatracker.ietf.org/doc/html/rfc7518
@Data()
class Jwk extends $Jwk {
  /// The "kty" (key type) parameter identifies the cryptographic algorithm
  /// family used with the key, such as "RSA" or "EC".  "kty" values should
  /// either be registered in the IANA "JSON Web Key Types" registry
  /// established by [JWA] or be a value that contains a Collision-
  /// Resistant Name.  The "kty" value is a case-sensitive string.  This
  /// member MUST be present in a JWK.
  @JsonKey('kty')
  final String keyType;

  /// The "use" (public key use) parameter identifies the intended use of
  /// the public key.  The "use" parameter is employed to indicate whether
  /// a public key is used for encrypting data or verifying the signature
  /// on data.
  ///
  ///  "sig" (signature)
  ///  "enc" (encryption)
  @JsonKey('use')
  final String? publicKeyUse;

  /// The "key_ops" (key operations) parameter identifies the operation(s)
  /// for which the key is intended to be used.  The "key_ops" parameter is
  /// intended for use cases in which public, private, or symmetric keys
  /// may be present.
  @JsonKey('key_ops')
  final String? keyOperations;

  /// The "alg" (algorithm) parameter identifies the algorithm intended for
  /// use with the key.  The values used should either be registered in the
  /// IANA "JSON Web Signature and Encryption Algorithms" registry
  /// established by [JWA] or be a value that contains a Collision-
  /// Resistant Name.  The "alg" value is a case-sensitive ASCII string.
  @JsonKey('alg')
  final String? algorithm;

  /// The "kid" (key ID) parameter is used to match a specific key.  This
  /// is used, for instance, to choose among a set of keys within a JWK Set
  /// during key rollover.  The structure of the "kid" value is
  /// unspecified.  When "kid" values are used within a JWK Set, different
  /// keys within the JWK Set SHOULD use distinct "kid" values.  (One
  /// example in which different keys might use the same "kid" value is if
  /// they have different "kty" (key type) values but are considered to be
  /// equivalent alternatives by the application using them.)
  @JsonKey('kid')
  final String? keyId;

  /// The "x5u" (X.509 URL) parameter is a URI [RFC3986] that refers to a
  /// resource for an X.509 public key certificate or certificate chain
  /// [RFC5280].
  @JsonKey('x5u')
  final String? x509Url;

  /// The "x5c" (X.509 certificate chain) parameter contains a chain of one
  /// or more PKIX certificates [RFC5280].  The certificate chain is
  /// represented as a JSON array of certificate value strings.  Each
  /// string in the array is a base64-encoded (Section 4 of [RFC4648] --
  /// not base64url-encoded) DER [ITU.X690.1994] PKIX certificate value.
  @JsonKey('x5c')
  final String? x509CertificateChain;

  /// The "x5t" (X.509 certificate SHA-1 thumbprint) parameter is a
  /// base64url-encoded SHA-1 thumbprint (a.k.a. digest) of the DER
  /// encoding of an X.509 certificate [RFC5280].
  @JsonKey('x5t')
  final String? x509CertificateSha1Thumbprint;

  /// The "x5t#S256" (X.509 certificate SHA-256 thumbprint) parameter is a
  /// base64url-encoded SHA-256 thumbprint (a.k.a. digest) of the DER
  /// encoding of an X.509 certificate [RFC5280].
  @JsonKey('x5t#S256')
  final String? x509CertificateSha256Thumbprint;

  /// For use with elliptic curve keys ("kty": "ec").
  ///
  /// The "crv" (curve) parameter identifies the cryptographic curve used
  /// with the key. Curve values from [DSS] used by this specification are:
  ///   - "P-256"
  ///   - "P-384"
  ///   - "P-521"
  @JsonKey('crv')
  final String? ecCurve;

  /// For use with elliptic curve keys ("kty": "ec").
  ///
  /// The "x" (x coordinate) parameter contains the x coordinate for the
  /// Elliptic Curve point.  It is represented as the base64url encoding of
  /// the octet string representation of the coordinate, as defined in
  /// Section 2.3.5 of SEC1 [SEC1].
  @JsonKey('x')
  final String? ecX;

  /// For use with elliptic curve keys ("kty": "ec").
  ///
  /// The "y" (y coordinate) parameter contains the y coordinate for the
  /// Elliptic Curve point.  It is represented as the base64url encoding of
  /// the octet string representation of the coordinate, as defined in
  /// Section 2.3.5 of SEC1 [SEC1].
  @JsonKey('y')
  final String? ecY;

  /// For use with RSA public keys ("kty": "rsa").
  ///
  /// The "n" (modulus) parameter contains the modulus value for the RSA
  /// public key.  It is represented as a Base64urlUInt-encoded value.
  @JsonKey('n')
  final String? rsaModulus;

  /// For use with RSA public keys ("kty": "rsa").
  ///
  /// The "e" (exponent) parameter contains the exponent value for the RSA
  /// public key.  It is represented as a Base64urlUInt-encoded value.
  @JsonKey('e')
  final String? rsaExponent;

  const Jwk({
    required this.keyType,
    this.publicKeyUse,
    this.keyOperations,
    this.algorithm,
    this.keyId,
    this.x509Url,
    this.x509CertificateChain,
    this.x509CertificateSha1Thumbprint,
    this.x509CertificateSha256Thumbprint,
    this.ecCurve,
    this.ecX,
    this.ecY,
    this.rsaModulus,
    this.rsaExponent,
  });
}
