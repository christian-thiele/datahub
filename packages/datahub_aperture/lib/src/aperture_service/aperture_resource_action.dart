class ApertureResourceAction {
  final String id;
  final String displayName;
  final int icon;
  final Future<void> Function(dynamic element) callback;

  ApertureResourceAction({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.callback,
  });
}
