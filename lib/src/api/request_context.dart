import 'package:datahub/src/api/sessions/session.dart';
import 'package:datahub/src/api/sessions/session_provider.dart';

class RequestContext {
  final SessionProvider? sessionProvider;
  final Session? session;

  RequestContext(this.sessionProvider, this.session);
}
