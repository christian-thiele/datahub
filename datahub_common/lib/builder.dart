import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator/transfer_bean_generator.dart';
import 'src/generator/transfer_superclass_generator.dart';
import 'src/generator/copy_with_extension_generator.dart';

Builder transferBeanGenerator(BuilderOptions options) =>
    SharedPartBuilder([TransferBeanGenerator()], 'dto');

Builder transferSuperclassGenerator(BuilderOptions options) =>
    SharedPartBuilder([TransferSuperclassGenerator()], 'dts');

Builder copyWithExtensionGenerator(BuilderOptions options) =>
    SharedPartBuilder([CopyWithExtensionGenerator()], 'cwe');
