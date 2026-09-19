import 'package:datahub/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'resolve_ticket.g.dart';

@Data()
@Meta(name: 'Resolve ticket', icon: Icons.task_alt)
class ResolveTicket extends $ResolveTicket {
  const ResolveTicket({
    required this.resolution,
    this.closeImmediately = false,
  });

  @Meta(description: 'Shared with the customer.')
  @MinLengthConstraint(length: 10)
  final String resolution;

  @Meta(
    name: 'Close immediately',
    description: 'Skip the customer confirmation and close the ticket.',
  )
  final bool closeImmediately;
}
