import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator/config/config_generator.dart';
import 'src/generator/transfer_bean/transfer_bean_generator.dart';
import 'src/generator/transfer_bean/transfer_superclass_generator.dart';
import 'src/generator/transfer_bean/copy_with_extension_generator.dart';

Builder configGenerator(BuilderOptions options) =>
    SharedPartBuilder([ConfigGenerator()], 'config');

Builder transferBeanGenerator(BuilderOptions options) =>
    SharedPartBuilder([TransferBeanGenerator()], 'dto');

Builder transferSuperclassGenerator(BuilderOptions options) =>
    SharedPartBuilder([TransferSuperclassGenerator()], 'dts');

Builder copyWithExtensionGenerator(BuilderOptions options) =>
    SharedPartBuilder([CopyWithExtensionGenerator()], 'cwe');
