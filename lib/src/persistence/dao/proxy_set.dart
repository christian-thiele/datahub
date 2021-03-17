import 'package:cl_datahub/src/persistence/dao/data_layout.dart';

import '../query/filter.dart';

//TODO this is old, check impl and docs
/// Provides an easy way to query related objects.
///
/// For 1 to n relationships a [ProxySet] can be used to simplify
/// querying child objects. For a [ProxySet] to work, the parent DAO has
/// to provide a primary key using the [PrimaryKey] annotation. The child DAO
/// then has to define a foreign key using the [ForeignKey] annotation on a
/// field using the same data type as the primary key on the parent.
class ProxySet<TChild extends DataLayout> {
  final Filter _proxyFilter;

  const ProxySet(
      this._proxyFilter); //TODO link to foregin key, dao could have multiple of same type, add docs about it

  //TODO caching strategy?
  Future<List<TChild>> query({Filter? filter}) async {
    return []; //TODO implement
  }
}
