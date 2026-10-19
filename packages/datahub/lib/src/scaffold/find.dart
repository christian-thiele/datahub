part of 'service_host.dart';

class const Find<T>([final Test<T> test = always]) {
  bool isCandidate(ServiceInstance service) =>
      service is T && test(service as T);

  T find() => Context.ofZone().find(this);

  @override
  String toString() => 'Find<$T>';
}
