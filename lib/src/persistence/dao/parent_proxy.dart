import '../query/filter.dart';

//TODO this is old, check impl and docs
/// Simplifies querying a data object via foreign key.
///
/// For 1 to 1 relationships a [ParentProxy] can be used to simplify
/// querying the related object. This can also be utilized to query the
/// parent object of a child in 1 to n relationships. See [ParentProxy] for
/// more information.
class ParentProxy<TChild> {
  final Filter _proxyFilter;

  const ParentProxy(
      this._proxyFilter); //TODO link to foregin key, dao could have multiple of same type, add docs about it

  //TODO caching strategy?
  Future<TChild?> query() async {
    return null; //TODO implement
  }
}
