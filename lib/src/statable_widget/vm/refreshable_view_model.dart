import 'package:flutter/foundation.dart';

import '../loader/loader.dart';
import '../loader/loader_data.dart';
import 'base_view_model.dart';
import 'loadable_view_model.dart';

abstract class RefreshableViewModel<T> extends LoadableViewModel<T, Loader<T>> implements _LoadingDelegate<T> {
  @override
  late final Loader<T> loader = _Loader(
    this,
    enableRefresh: enableRefresh,
  );

  @mustCallSuper
  @override
  void initialize() {
    super.initialize();

    loader.addListener(() {
      notifyListeners();
    });
  }

  bool get enableRefresh => true;

  void refresh() => load();

  @override
  Future<void> load() {
    return loader.load();
  }

  @override
  Future<T> fetch();

  @override
  LoaderResult<T> get value => loader.value;

  @override
  void onSuccess(T? data) {}

  @override
  void onFailure(Object? error) {}

  @mustCallSuper
  @override
  void dispose() {
    loader.dispose();
    super.dispose();
  }
}

abstract class _LoadingDelegate<T> extends BaseViewModel {
  Future<T> fetch();

  void onSuccess(T? data) {}

  void onFailure(Object? error) {}
}

class _Loader<T, N extends _LoadingDelegate<T>> extends Loader<T> {
  _Loader(
    this._delegate, {
    this.enableRefresh = true,
  });

  @override
  final bool enableRefresh;

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
