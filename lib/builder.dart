import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator/config/config_generator.dart';

import 'src/generator/broker/broker_api_service_generator.dart';
import 'src/generator/broker/broker_api_client_generator.dart';

import 'src/generator/copy_with/copy_with_extension_generator.dart';

import 'src/generator/transfer_bean/transfer_bean_generator.dart';
import 'src/generator/transfer_bean/transfer_superclass_generator.dart';

import 'src/generator/data_layout/data_bean_generator.dart';
import 'src/generator/data_layout/data_superclass_generator.dart';

Builder configGenerator(BuilderOptions options) =>
    SharedPartBuilder([ConfigGenerator()], 'config');

Builder transferBeanGenerator(BuilderOptions options) =>
    SharedPartBuilder([TransferBeanGenerator()], 'dto');

Builder dataBeanGenerator(BuilderOptions options) =>
    SharedPartBuilder([DataBeanGenerator()], 'dao');

Builder dataSuperclassGenerator(BuilderOptions options) =>
    SharedPartBuilder([DataSuperclassGenerator()], 'das');

Builder transferSuperclassGenerator(BuilderOptions options) =>
    SharedPartBuilder([TransferSuperclassGenerator()], 'dts');

Builder copyWithExtensionGenerator(BuilderOptions options) =>
    SharedPartBuilder([CopyWithExtensionGenerator()], 'cwe');

Builder brokerApiServiceGenerator(BuilderOptions options) =>
    SharedPartBuilder([BrokerApiServiceGenerator()], 'bas');

Builder brokerApiClientGenerator(BuilderOptions options) =>
    SharedPartBuilder([BrokerApiClientGenerator()], 'bac');
