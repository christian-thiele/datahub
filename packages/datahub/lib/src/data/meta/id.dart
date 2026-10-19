import 'package:meta/meta_meta.dart';

import 'meta_data.dart';

@Target({TargetKind.field})
final class const Id({final bool auto = false}) extends MetaData;
