import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:datahub_amqp/protocol/amqp_field.dart';
import 'package:datahub_amqp/protocol/amqp_frame.dart';

import 'constants.dart';

abstract class AmqpMethod {
  final int channelId;
  final int classId;
  final int methodId;

  AmqpMethod({
    required this.channelId,
    required this.classId,
    required this.methodId,
  });

  static AmqpMethod fromFrame(MethodFrame frame) {
    final methodFactory = switch ((frame.classId, frame.methodId)) {
      (classConnection, methodConnectionStart) =>
        AmqpMethodConnectionStart.fromArguments,
      (classConnection, methodConnectionStartOk) =>
        AmqpMethodConnectionStartOk.fromArguments,
      (classConnection, methodConnectionTune) =>
        AmqpMethodConnectionTune.fromArguments,
      (classConnection, methodConnectionTuneOk) =>
        AmqpMethodConnectionTuneOk.fromArguments,
      (classConnection, methodConnectionOpen) =>
        AmqpMethodConnectionOpen.fromArguments,
      (classConnection, methodConnectionOpenOk) =>
        AmqpMethodConnectionOpenOk.fromArguments,
      (classConnection, methodConnectionClose) =>
        AmqpMethodConnectionClose.fromArguments,
      (classConnection, methodConnectionCloseOk) =>
        AmqpMethodConnectionCloseOk.fromArguments,
      _ => throw UnimplementedError(),
    };

    return methodFactory(frame.channelId, frame.arguments);
  }

  MethodFrame toFrame() => MethodFrame(
    channelId: channelId,
    classId: classId,
    methodId: methodId,
    arguments: MethodFrame.buildArguments(getArguments()),
  );

  List<AmqpField> getArguments();
}

class AmqpMethodConnectionStart extends AmqpMethod {
  final int versionMajor;
  final int versionMinor;
  final Map<String, dynamic> serverProperties;
  final List<String> mechanisms;
  final List<String> locales;

  AmqpMethodConnectionStart({
    required super.channelId,
    required this.versionMajor,
    required this.versionMinor,
    required this.serverProperties,
    required this.mechanisms,
    required this.locales,
  }) : super(classId: classConnection, methodId: methodConnectionStart);

  factory AmqpMethodConnectionStart.fromArguments(
    int channelId,
    Uint8List data,
  ) {
    final reader = ByteDataReader()..add(data);
    return AmqpMethodConnectionStart(
      channelId: channelId,
      versionMajor: AmqpFieldOctet.readFrom(reader).value,
      versionMinor: AmqpFieldOctet.readFrom(reader).value,
      serverProperties: AmqpFieldFieldTable.readFrom(reader).toMap(),
      mechanisms: AmqpFieldLongString.readFrom(reader).toText().split(' '),
      locales: AmqpFieldLongString.readFrom(reader).toText().split(' '),
    );
  }

  @override
  List<AmqpField> getArguments() => [
    AmqpFieldOctet(versionMajor),
    AmqpFieldOctet(versionMinor),
    AmqpFieldFieldTable(
      serverProperties.map(
        (k, v) => MapEntry(k, AmqpFieldLongString.fromText(v)),
      ),
    ),
    AmqpFieldLongString.fromText(mechanisms.join(' ')),
    AmqpFieldLongString.fromText(locales.join(' ')),
  ];
}

class AmqpMethodConnectionStartOk extends AmqpMethod {
  final Map<String, dynamic> clientProperties;
  final String mechanism;
  final Uint8List response;
  final String locale;

  AmqpMethodConnectionStartOk({
    required super.channelId,
    required this.clientProperties,
    required this.mechanism,
    required this.response,
    required this.locale,
  }) : super(classId: classConnection, methodId: methodConnectionStartOk);

  factory AmqpMethodConnectionStartOk.fromArguments(
    int channelId,
    Uint8List data,
  ) {
    final reader = ByteDataReader()..add(data);
    return AmqpMethodConnectionStartOk(
      channelId: channelId,
      clientProperties: AmqpFieldFieldTable.readFrom(reader).toMap(),
      mechanism: AmqpFieldShortString.readFrom(reader).value,
      response: AmqpFieldLongString.readFrom(reader).value,
      locale: AmqpFieldShortString.readFrom(reader).value,
    );
  }

  @override
  List<AmqpField> getArguments() => [
    AmqpFieldFieldTable.fromValueMap(clientProperties),
    AmqpFieldShortString(mechanism),
    AmqpFieldLongString(response),
    AmqpFieldShortString(locale),
  ];
}

class AmqpMethodConnectionTune extends AmqpMethod {
  final int channelMax;
  final int frameMax;
  final int heartbeat;

  AmqpMethodConnectionTune({
    required super.channelId,
    required this.channelMax,
    required this.frameMax,
    required this.heartbeat,
  }) : super(classId: classConnection, methodId: methodConnectionTune);

  factory AmqpMethodConnectionTune.fromArguments(
    int channelId,
    Uint8List data,
  ) {
    final reader = ByteDataReader()..add(data);
    return AmqpMethodConnectionTune(
      channelId: channelId,
      channelMax: AmqpFieldShortUint.readFrom(reader).value,
      frameMax: AmqpFieldLongUint.readFrom(reader).value,
      heartbeat: AmqpFieldShortUint.readFrom(reader).value,
    );
  }

  @override
  List<AmqpField> getArguments() => [
    AmqpFieldShortUint(channelMax),
    AmqpFieldLongUint(frameMax),
    AmqpFieldShortUint(heartbeat),
  ];
}

class AmqpMethodConnectionTuneOk extends AmqpMethod {
  final int channelMax;
  final int frameMax;
  final int heartbeat;

  AmqpMethodConnectionTuneOk({
    required super.channelId,
    required this.channelMax,
    required this.frameMax,
    required this.heartbeat,
  }) : super(classId: classConnection, methodId: methodConnectionTuneOk);

  factory AmqpMethodConnectionTuneOk.fromArguments(
    int channelId,
    Uint8List data,
  ) {
    final reader = ByteDataReader()..add(data);
    return AmqpMethodConnectionTuneOk(
      channelId: channelId,
      channelMax: AmqpFieldShortUint.readFrom(reader).value,
      frameMax: AmqpFieldLongUint.readFrom(reader).value,
      heartbeat: AmqpFieldShortUint.readFrom(reader).value,
    );
  }

  @override
  List<AmqpField> getArguments() => [
    AmqpFieldShortUint(channelMax),
    AmqpFieldLongUint(frameMax),
    AmqpFieldShortUint(heartbeat),
  ];
}

class AmqpMethodConnectionOpen extends AmqpMethod {
  final String virtualHost;

  AmqpMethodConnectionOpen({
    required super.channelId,
    required this.virtualHost,
  }) : super(classId: classConnection, methodId: methodConnectionOpen);

  factory AmqpMethodConnectionOpen.fromArguments(
    int channelId,
    Uint8List data,
  ) {
    final reader = ByteDataReader()..add(data);
    return AmqpMethodConnectionOpen(
      channelId: channelId,
      virtualHost: AmqpFieldShortString.readFrom(reader).value,
    );
  }

  @override
  List<AmqpField> getArguments() => [
    AmqpFieldShortString(virtualHost),
    // reserved-1
    AmqpFieldShortString(''),
    // reserved-2
    AmqpFieldShortString(''),
  ];
}

class AmqpMethodConnectionOpenOk extends AmqpMethod {
  AmqpMethodConnectionOpenOk({required super.channelId})
    : super(classId: classConnection, methodId: methodConnectionOpenOk);

  factory AmqpMethodConnectionOpenOk.fromArguments(
    int channelId,
    Uint8List data,
  ) {
    return AmqpMethodConnectionOpenOk(channelId: channelId);
  }

  @override
  List<AmqpField> getArguments() => [];
}

class AmqpMethodConnectionClose extends AmqpMethod {
  final int replyCode;
  final String replyText;
  final int failingClassId;
  final int failingMethodId;

  AmqpMethodConnectionClose({
    required super.channelId,
    required this.replyCode,
    required this.replyText,
    required this.failingClassId,
    required this.failingMethodId,
  }) : super(classId: classConnection, methodId: methodConnectionClose);

  factory AmqpMethodConnectionClose.fromArguments(
    int channelId,
    Uint8List data,
  ) {
    final reader = ByteDataReader()..add(data);
    return AmqpMethodConnectionClose(
      channelId: channelId,
      replyCode: AmqpFieldShortUint.readFrom(reader).value,
      replyText: AmqpFieldShortString.readFrom(reader).value,
      failingClassId: AmqpFieldShortUint.readFrom(reader).value,
      failingMethodId: AmqpFieldShortUint.readFrom(reader).value,
    );
  }

  @override
  List<AmqpField> getArguments() => [
    AmqpFieldShortUint(replyCode),
    AmqpFieldShortString(replyText),
    AmqpFieldShortUint(failingClassId),
    AmqpFieldShortUint(failingMethodId),
  ];
}

class AmqpMethodConnectionCloseOk extends AmqpMethod {
  AmqpMethodConnectionCloseOk({required super.channelId})
    : super(classId: classConnection, methodId: methodConnectionCloseOk);

  factory AmqpMethodConnectionCloseOk.fromArguments(
    int channelId,
    Uint8List data,
  ) {
    return AmqpMethodConnectionCloseOk(channelId: channelId);
  }

  @override
  List<AmqpField> getArguments() => [];
}

class AmqpMethodChannelOpen extends AmqpMethod {
  AmqpMethodChannelOpen({required super.channelId})
    : super(classId: classChannel, methodId: methodChannelOpen);

  factory AmqpMethodChannelOpen.fromArguments(int channelId, Uint8List data) {
    return AmqpMethodChannelOpen(channelId: channelId);
  }

  @override
  List<AmqpField> getArguments() => [AmqpFieldShortString('')];
}

class AmqpMethodChannelOpenOk extends AmqpMethod {
  AmqpMethodChannelOpenOk({required super.channelId})
    : super(classId: classChannel, methodId: methodChannelOpenOk);

  factory AmqpMethodChannelOpenOk.fromArguments(int channelId, Uint8List data) {
    return AmqpMethodChannelOpenOk(channelId: channelId);
  }

  @override
  List<AmqpField> getArguments() => [AmqpFieldShortString('')];
}

class AmqpMethodChannelFlow extends AmqpMethod {
  final bool active;

  AmqpMethodChannelFlow({required super.channelId, required this.active})
    : super(classId: classChannel, methodId: methodChannelFlow);

  factory AmqpMethodChannelFlow.fromArguments(int channelId, Uint8List data) {
    final reader = ByteDataReader()..add(data);
    return AmqpMethodChannelFlow(
      channelId: channelId,
      active: AmqpFieldBit.readFrom(reader).value,
    );
  }

  @override
  List<AmqpField> getArguments() => [AmqpFieldBit(active)];
}

class AmqpMethodChannelFlowOk extends AmqpMethod {
  final bool active;

  AmqpMethodChannelFlowOk({required super.channelId, required this.active})
    : super(classId: classChannel, methodId: methodChannelFlowOk);

  factory AmqpMethodChannelFlowOk.fromArguments(int channelId, Uint8List data) {
    final reader = ByteDataReader()..add(data);
    return AmqpMethodChannelFlowOk(
      channelId: channelId,
      active: AmqpFieldBit.readFrom(reader).value,
    );
  }

  @override
  List<AmqpField> getArguments() => [AmqpFieldBit(active)];
}

class AmqpMethodChannelClose extends AmqpMethod {
  final int replyCode;
  final String replyText;
  final int failingClassId;
  final int failingMethodId;

  AmqpMethodChannelClose({
    required super.channelId,
    required this.replyCode,
    required this.replyText,
    required this.failingClassId,
    required this.failingMethodId,
  }) : super(classId: classChannel, methodId: methodChannelClose);

  factory AmqpMethodChannelClose.fromArguments(int channelId, Uint8List data) {
    final reader = ByteDataReader()..add(data);
    return AmqpMethodChannelClose(
      channelId: channelId,
      replyCode: AmqpFieldShortUint.readFrom(reader).value,
      replyText: AmqpFieldShortString.readFrom(reader).value,
      failingClassId: AmqpFieldShortUint.readFrom(reader).value,
      failingMethodId: AmqpFieldShortUint.readFrom(reader).value,
    );
  }

  @override
  List<AmqpField> getArguments() => [
    AmqpFieldShortUint(replyCode),
    AmqpFieldShortString(replyText),
    AmqpFieldShortUint(failingClassId),
    AmqpFieldShortUint(failingMethodId),
  ];
}

class AmqpMethodChannelCloseOk extends AmqpMethod {
  AmqpMethodChannelCloseOk({required super.channelId})
    : super(classId: classChannel, methodId: methodChannelCloseOk);

  factory AmqpMethodChannelCloseOk.fromArguments(
    int channelId,
    Uint8List data,
  ) {
    return AmqpMethodChannelCloseOk(channelId: channelId);
  }

  @override
  List<AmqpField> getArguments() => [];
}
