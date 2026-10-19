import 'package:datahub/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'export_invoices.g.dart';

@Data()
@Meta(name: 'Export invoices', icon: Icons.download)
class const ExportInvoices({
  @Meta(name: 'Only overdue', description: 'Leave out all other invoices.')
  final bool onlyOverdue = false,
}) extends $ExportInvoices;
