import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/icons.dart';

part 'order.g.dart';

enum OrderState { placed, packed, shipped, delivered, lost }

/// An element with a workflow: placed -> packed -> shipped -> delivered.
@Data()
class Order extends $Order {
  @Id()
  final String id;

  final String customer;

  final OrderState state;

  const Order({
    required this.id,
    required this.customer,
    this.state = OrderState.placed,
  });
}

@Data()
@Meta(name: 'Ship order', icon: Icons.local_shipping)
class ShipOrder extends $ShipOrder implements WorkflowSignal<Order> {
  @RelationId<Order>()
  final String orderId;

  @MinLengthConstraint(length: 2)
  final String carrier;

  const ShipOrder({required this.orderId, required this.carrier});
}
