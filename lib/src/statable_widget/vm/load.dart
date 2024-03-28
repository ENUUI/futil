import 'package:flutter/foundation.dart';

import '../loader/loader.dart';
import 'base.dart';

/// 用于单次加载所有数据
abstract class LoadViewModel<T> extends LoadableViewModel<T, Loader<T>> implements _LoadingDelegate<T> {
  /// 少数情况下，不分页的页面也可能支持下拉刷新
  bool get enablePullRefresh => false;

  @override
  late final Loader<T> loader = _Loader(
    this,
    enablePullRefresh: enablePullRefresh,
  );

  @mustCallSuper
  @override
  void initialize() {
    super.initialize();

    loader.addListener(() {
      notifyListeners();
    });
  }

  @override
  Future<void> load() {
    return loader.load();
  }

  /// 用于实现加载数据的方法
  @override
  Future<T> fetch();

  @override
  void onSuccess(T? data) {}

  @override
  void onFailure(Object? error) {}
}

/// 加载器
abstract class _LoadingDelegate<T> extends BaseViewModel {
  Future<T> fetch();

  void onSuccess(T? data) {}

  void onFailure(Object? error) {}
}

class _Loader<T, N extends _LoadingDelegate<T>> extends Loader<T> {
  _Loader(
    this._delegate, {
    this.enablePullRefresh = true,
  });

  @override
  final bool enablePullRefresh;

  final _LoadingDelegate<T> _delegate;

  @override
  Future<T> fetch() {
    return _delegate.fetch();
  }

  @override
  void onSuccess(T? data) {
    _delegate.onSuccess(data);
  }

  @override
  void onFailure(Object? error) {
    _delegate.onFailure(error);
  }
}
