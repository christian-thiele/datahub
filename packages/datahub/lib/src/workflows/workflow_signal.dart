import 'package:datahub/data.dart';

/// Marks a data object as signal for the workflow of the element type [T].
///
/// Implement it on a signal class to be able to send it: only signals of the
/// right element type are accepted by `Workflow<T>.send`.
///
/// A signal tells a workflow about something that happened outside of it, for
/// example a payment provider calling a webhook. It is handled by an
/// `OnSignal` step and sent with `Workflow.send`.
///
/// Signals are stored until the workflow handled them, so they have to be
/// data objects:
///
/// ```dart
/// @Data()
/// class PaymentSignal extends $PaymentSignal
///     implements WorkflowSignal<Invoice> {
///   const PaymentSignal({required this.invoiceId});
///
///   final String invoiceId;
/// }
/// ```
abstract interface class WorkflowSignal<T extends DataObject> {}
