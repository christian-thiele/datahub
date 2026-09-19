// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_ticket.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResolveTicket with DataObject<ResolveTicket> {
  const $ResolveTicket();
  static const $$codec = JsonDataCodec();
  static final $resolution = DataField<ResolveTicket, String>(
    name: 'resolution',
    valueOf: (p) => p.resolution,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Meta(description: 'Shared with the customer.')],
    constraints: [const MinLengthConstraint<String?>(length: 10)],
  );

  static final $closeImmediately = DataField<ResolveTicket, bool>(
    name: 'closeImmediately',
    valueOf: (p) => p.closeImmediately,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
    meta: [
      const Meta(
        name: 'Close immediately',
        description: 'Skip the customer confirmation and close the ticket.',
      ),
    ],
  );

  static final DataBean<ResolveTicket> bean = DataBean<ResolveTicket>(
    name: 'ResolveTicket',
    fields: List<DataField<ResolveTicket, dynamic>>.unmodifiable([
      $resolution,
      $closeImmediately,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [const Meta(name: 'Resolve ticket', icon: 58950)],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResolveTicket, dynamic>> get $$fields => bean.fields;
  ResolveTicket copyWith({String? resolution, bool? closeImmediately}) {
    final $data = this as ResolveTicket;
    return ResolveTicket(
      resolution: resolution ?? $data.resolution,
      closeImmediately: closeImmediately ?? $data.closeImmediately,
    );
  }

  static ResolveTicket fromValues(Map<String, dynamic> data) {
    return ResolveTicket(
      resolution: data['resolution'],
      closeImmediately: data['closeImmediately'] ?? false,
    );
  }

  static ResolveTicket fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ResolveTicket, data.runtimeType, name);
    }
    return ResolveTicket(
      resolution: $resolution.fromJson(
        data['resolution'],
        name: DataCodec.childName(name, 'resolution'),
      ),
      closeImmediately: $closeImmediately.fromJson(
        data['closeImmediately'],
        name: DataCodec.childName(name, 'closeImmediately'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResolveTicket;
    return {
      'resolution': $resolution.toJson($$data.resolution),
      'closeImmediately': $closeImmediately.toJson($$data.closeImmediately),
    }..removeWhere((k, v) => v == null);
  }
}
