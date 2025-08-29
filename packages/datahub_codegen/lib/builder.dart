import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/copy_with/copy_with_extension_generator.dart';

import 'src/transfer_bean/transfer_bean_generator.dart';
import 'src/transfer_bean/transfer_superclass_generator.dart';

import 'src/data_bean/data_bean_generator.dart';
import 'src/data_bean/data_superclass_generator.dart';

import 'src/hub/hub_client_generator.dart';
import 'src/hub/hub_provider_generator.dart';

Builder transferBeanGenerator(BuilderOptions options) =>
    SharedPartBuilder([TransferBeanGenerator()], 'dto');

Builder transferSuperclassGenerator(BuilderOptions options) =>
    SharedPartBuilder([TransferSuperclassGenerator()], 'dts');

Builder dataBeanGenerator(BuilderOptions options) =>
    SharedPartBuilder([DataBeanGenerator()], 'dao');

Builder dataSuperclassGenerator(BuilderOptions options) =>
    SharedPartBuilder([DataSuperclassGenerator()], 'das');

Builder copyWithExtensionGenerator(BuilderOptions options) =>
    SharedPartBuilder([CopyWithExtensionGenerator()], 'cwe');

Builder hubClientGenerator(BuilderOptions options) =>
    SharedPartBuilder([HubClientGenerator()], 'hrc');

Builder hubProviderGenerator(BuilderOptions options) =>
    SharedPartBuilder([HubProviderGenerator()], 'hrp');
