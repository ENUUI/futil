import 'package:flutter/foundation.dart';

import '../loader/loader_data.dart';
import '../loader/page_by_index.dart';
import 'loadable_view_model.dart';

/// 页码分页加载 viewModel
abstract class IndexPageViewModel<T> extends LoadableViewModel<List<T>, PageByIndexLoader<T>>
    implements _PageDelegate<T> {
  @override
  late final PageByIndexLoader<T> loader = _PageIndexLoader(
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
    return loader.load(true);
  }

  @override
  Future<void> beforeFetch() async {}

  @override
  Future<Ipd<T>> fetch(bool refresh, PIndex query);

  @override
  void dispose() {
    loader.dispose();
    super.dispose();
  }

  @override
  void onSuccess(List<T>? data, List<T> allData) {}

  @override
  void onFailure(Object? error) {}
}

/// 分页加载器
abstract class _PageDelegate<T> {
  Future<void> beforeFetch();

  Future<Ipd<T>> fetch(bool refresh, PIndex query);

  void onSuccess(List<T>? data, List<T> allData);

  void onFailure(Object? error);
}

/// 分页加载器
class _PageIndexLoader<T> extends PageByIndexLoader<T> {
  _PageIndexLoader(
    this._delegate, {
    this.enableRefresh = true,
    this.enableLoadMore = true,
  });

  @override
  final bool enableRefresh;
  @override
  final bool enableLoadMore;
  final _PageDelegate<T> _delegate;

  @override
  Future<void> fetchBeforeRefresh() async {
    await _delegate.beforeFetch();
  }

  @override
  Future<Ipd<T>> fetch(bool refresh, PIndex query) {
    return _delegate.fetch(refresh, query);
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
