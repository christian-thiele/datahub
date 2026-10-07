// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Order with DataObject<Order> {
  const $Order();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Order, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id()],
  );

  static final $customer = DataField<Order, String>(
    name: 'customer',
    valueOf: (p) => p.customer,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $state = DataField<Order, OrderState>(
    name: 'state',
    valueOf: (p) => p.state,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? OrderState.placed),
      OrderState.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: OrderState.values)],
  );

  static final DataBean<Order> bean = DataBean<Order>(
    name: 'Order',
    fields: List<DataField<Order, dynamic>>.unmodifiable([
      $id,
      $customer,
      $state,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Order, dynamic>> get $$fields => bean.fields;
  Order copyWith({String? id, String? customer, OrderState? state}) {
    final $data = this as Order;
    return Order(
      id: id ?? $data.id,
      customer: customer ?? $data.customer,
      state: state ?? $data.state,
    );
  }

  static Order fromValues(Map<String, dynamic> data) {
    return Order(
      id: data['id'],
      customer: data['customer'],
      state: data['state'] ?? OrderState.placed,
    );
  }

  static Order fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Order, data.runtimeType, name);
    }
    return Order(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      customer: $customer.fromJson(
        data['customer'],
        name: DataCodec.childName(name, 'customer'),
      ),
      state: $state.fromJson(
        data['state'],
        name: DataCodec.childName(name, 'state'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Order;
    return {
      'id': $id.toJson($$data.id),
      'customer': $customer.toJson($$data.customer),
      'state': $state.toJson($$data.state),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $ShipOrder with DataObject<ShipOrder> {
  const $ShipOrder();
  static const $$codec = JsonDataCodec();
  static final $orderId = DataField<ShipOrder, String>(
    name: 'orderId',
    valueOf: (p) => p.orderId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const RelationId<Order>()],
  );

  static final $carrier = DataField<ShipOrder, String>(
    name: 'carrier',
    valueOf: (p) => p.carrier,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [const MinLengthConstraint<String?>(length: 2)],
  );

  static final DataBean<ShipOrder> bean = DataBean<ShipOrder>(
    name: 'ShipOrder',
    fields: List<DataField<ShipOrder, dynamic>>.unmodifiable([
      $orderId,
      $carrier,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [const Meta(name: 'Ship order', icon: 58278)],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ShipOrder, dynamic>> get $$fields => bean.fields;
  ShipOrder copyWith({String? orderId, String? carrier}) {
    final $data = this as ShipOrder;
    return ShipOrder(
      orderId: orderId ?? $data.orderId,
      carrier: carrier ?? $data.carrier,
    );
  }

  static ShipOrder fromValues(Map<String, dynamic> data) {
    return ShipOrder(orderId: data['orderId'], carrier: data['carrier']);
  }

  static ShipOrder fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ShipOrder, data.runtimeType, name);
    }
    return ShipOrder(
      orderId: $orderId.fromJson(
        data['orderId'],
        name: DataCodec.childName(name, 'orderId'),
      ),
      carrier: $carrier.fromJson(
        data['carrier'],
        name: DataCodec.childName(name, 'carrier'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ShipOrder;
    return {
      'orderId': $orderId.toJson($$data.orderId),
      'carrier': $carrier.toJson($$data.carrier),
    }..removeWhere((k, v) => v == null);
  }
}
