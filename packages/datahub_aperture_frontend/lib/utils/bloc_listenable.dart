import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class BlocListenable implements Listenable {
  final StateStreamableSource bloc;
  final _subscriptions = <VoidCallback, StreamSubscription>{};

  BlocListenable(this.bloc);

  @override
  void addListener(VoidCallback listener) {
    _subscriptions[listener] = bloc.stream.listen((_) => listener());
  }

  @override
  void removeListener(VoidCallback listener) {
    _subscriptions[listener]!.cancel();
  }
}
