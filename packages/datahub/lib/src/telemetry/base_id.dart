import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';

abstract class BaseId {
  final Uint8List _id;

  const BaseId(this._id);

  String get hexId => _id.toHexString();

  String get base64Id => base64Encode(_id);

  UnmodifiableListView<int> get bytes =>
      UnmodifiableListView(_id); // _id.asUnmodifiableView();
}
