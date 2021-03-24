import 'dart:typed_data';

import 'package:cl_datahub/cl_datahub.dart';

import 'simple_dao.dart';

class InvalidPrimaryDao {
  @PrimaryKeyDaoField()
  final DateTime id;

  final String strField;
  final int intField;
  final double doubleField;

  InvalidPrimaryDao(this.id, this.strField, this.intField, this.doubleField);
}

class MultiplePrimaryDao {
  @PrimaryKeyDaoField()
  final String id;

  @PrimaryKeyDaoField()
  final int otherId;

  final String strField;
  final int intField;
  final double doubleField;

  MultiplePrimaryDao(
      this.id, this.otherId, this.strField, this.intField, this.doubleField);
}

class InvalidForeignDao {
  @PrimaryKeyDaoField()
  final String id;

  @ForeignKeyDaoField(Simple)
  final String invalidForeign;

  final String strField;
  final int intField;
  final double doubleField;
  final Uint8List bytesField;

  InvalidForeignDao(this.id, this.invalidForeign, this.strField, this.intField,
      this.doubleField, this.bytesField);
}

@DaoType(name: 'invalidField')
class InvalidTypeDao {
  @PrimaryKeyDaoField()
  final String id;

  final String strField;
  final int intField;
  final double doubleField;
  final Uint8List bytesField;

  final Future invalidField;

  InvalidTypeDao(this.id, this.strField, this.intField, this.doubleField,
      this.bytesField, this.invalidField);
}
