import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  test('attach / detach', _notifierAttachDetach);
  test('attachOneShot', _notifierOneShot);
}

void _notifierAttachDetach() {
  var exp1 = false;
  var exp2 = false;

  final notifier = Notifier();
  final key1 = notifier.attach(() => exp1 = true);
  final key2 = notifier.attach(() => exp2 = true);

  notifier.notify();
  expect(exp1, isTrue);
  expect(exp2, isTrue);

  exp1 = exp2 = false;
  notifier.detach(key1);

  notifier.notify();
  expect(exp1, isFalse);
  expect(exp2, isTrue);

  exp1 = exp2 = false;
  notifier.detach(key2);

  notifier.notify();
  expect(exp1, isFalse);
  expect(exp2, isFalse);
}

void _notifierOneShot() {
  var exp1 = false;
  var exp2 = false;

  final notifier = Notifier();
  notifier.attach(() => exp1 = true);
  notifier.attachOneShot(() => exp2 = true);

  notifier.notify();
  expect(exp1, isTrue);
  expect(exp2, isTrue);

  exp1 = exp2 = false;
  notifier.notify();

  expect(exp1, isTrue);
  expect(exp2, isFalse);
}
