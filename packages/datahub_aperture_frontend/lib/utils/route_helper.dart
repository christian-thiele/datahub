import 'package:flutter/material.dart';

class RouteHelper extends StatefulWidget {
  static RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();
  final Widget child;
  final VoidCallback? didPopNext;

  const RouteHelper({super.key, required this.child, this.didPopNext});

  @override
  State<RouteHelper> createState() => _RouteHelperState();
}

class _RouteHelperState extends State<RouteHelper> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteHelper.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    RouteHelper.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    widget.didPopNext?.call();
  }
}
