/// Interface class for generated Hub client classes.
///
/// This is exclusively used to distinguish HubClients from HubProviders
/// when resolving from IoC.
///
/// When implementing [HubClient], the implementation must also implement
/// the Hub Interface ([T]).
abstract class HubClient<T> {
  HubClient() {
    assert(this is T, 'HubClient<$T> must implement $T.');
  }
}
