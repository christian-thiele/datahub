import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/config/generator/config_generator.dart';

Builder configGenerator(BuilderOptions options) =>
    SharedPartBuilder([ConfigGenerator()], 'config');
