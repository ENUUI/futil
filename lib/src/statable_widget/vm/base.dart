import 'dart:async';

import 'package:flutter/foundation.dart';

import '../loader/loadable.dart';
import '../loader/loadable_data.dart';

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

/// 加载 viewModel, 用于加载数据
/// 挂载 [RefreshMoreLoader], 更多方法请查看 [RefreshMoreLoader]
/// [T] 数据类型, [L] 加载器类型
/// eg.
///    [LoadViewModel] 用于单次加载所有数据
///    [IndexPageViewModel] 用于页码分页加载
///    [KeyPageViewModel] 用于关键字分页加载
abstract class LoadableViewModel<T, L extends RefreshMoreLoader<T>> extends BaseViewModel {
  L get loader;

  LoaderResult<T> get value => loader.value;

  LoadingState get state => value.state;

  T? get data => value.data;

  Future<void> load();

  @mustCallSuper
  @override
  void initialize() {
    super.initialize();
    loader.addListener(() => notifyListeners());
  }

  @mustCallSuper
  @override
  void dispose() {
    loader.dispose();
    super.dispose();
  }
}
