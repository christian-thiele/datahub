import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/icons.dart';

part 'order.g.dart';

enum OrderState() {
  placed,
  packed,
  shipped,
  delivered,
  lost,
}

/// An element with a workflow: placed -> packed -> shipped -> delivered.
@Data()
class const Order({
  @Id() required final String id,
  required final String customer,
  final OrderState state = OrderState.placed,
}) extends $Order;

@Data()
@Meta(name: 'Ship order', icon: Icons.local_shipping)
class const ShipOrder({
  @RelationId<Order>() required final String orderId,
  @MinLengthConstraint(length: 2) required final String carrier,
}) extends $ShipOrder implements WorkflowSignal<Order>;
