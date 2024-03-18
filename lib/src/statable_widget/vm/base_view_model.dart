import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class BaseViewModel extends ChangeNotifier {
  BaseViewModel() {
    initialize();
  }

  bool _disposed = false;

  bool get disposed => _disposed;

  void initialize() {}

  final List<StreamSubscription> _subscriptions = [];

  /// 将无需操作的订阅添加到这里，当ViewModel销毁时，会自动取消订阅
  void subscriptions(List<StreamSubscription> l) {
    assert(!disposed, 'ViewModel is disposed, can not add subscriptions');
    if (disposed) return;

    _subscriptions.addAll(l);
  }

  @override
  void notifyListeners() {
    if (disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final element in _subscriptions) {
      element.cancel();
    }
    super.dispose();
  }
}

class BaseValueNotifier<T> extends BaseViewModel implements ValueListenable<T> {
  BaseValueNotifier(this._value);

  @override
  T get value => _value;
  T _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
