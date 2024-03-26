import 'package:flutter/foundation.dart';
import 'package:futil/src/statable_widget/loader/loader_data.dart';
import 'package:futil/src/statable_widget/loader/page_by_key.dart';

import 'loadable_view_model.dart';

abstract class KeyPageViewModel<T> extends LoadableViewModel<List<T>, PageByKeyLoader<T>> implements _PageDelegate<T> {
  @override
  late final PageByKeyLoader<T> loader = _PageKeyLoader(
    this,
    enableRefresh: enableRefresh,
    enableLoadMore: enableLoadMore,
  );

  bool get enableRefresh => true;

  bool get enableLoadMore => true;

  /// 所有数据；不要直接操作该数据，使用 [loader.updateResult] 方法
  List<T> get allData => value.data ?? <T>[];

  @override
  LoaderResult<List<T>> get value => loader.value;

  @mustCallSuper
  @override
  void initialize() {
    super.initialize();
    loader.addListener(() => notifyListeners());
  }

  @override
  Future<void> load() {
    return loader.load();
  }

  @override
  Future<void> beforeFetch() async {}

  @override
  void onFailure(Object? error) {}

  @override
  void onSuccess(List? data, List allData) {}

  @override
  void dispose() {
    loader.dispose();
    super.dispose();
  }
}

/// 分页加载器
abstract class _PageDelegate<T> {
  Future<void> beforeFetch();

  Future<PageKeyData<T>> fetch(bool refresh, PageKey query);

  void onSuccess(List<T>? data, List<T> allData);

  void onFailure(Object? error);
}

class _PageKeyLoader<T> extends PageByKeyLoader<T> {
  _PageKeyLoader(this._delegate, {this.enableRefresh = true, this.enableLoadMore = true});

  @override
  final bool enableRefresh;
  @override
  final bool enableLoadMore;
  final _PageDelegate<T> _delegate;

  @override
  Future<void> fetchBeforeRefresh() {
    return _delegate.beforeFetch();
  }

  @override
  Future<PageKeyData<T>> fetch(bool refresh, PageKey req) {
    return _delegate.fetch(refresh, req);
  }

  @override
  void onSuccess(List<T>? data) {
    super.onSuccess(data);
    _delegate.onSuccess(data, allData);
  }

  @override
  void onFailure(Object? error) {
    super.onFailure(error);
    _delegate.onFailure(error);
  }
}
