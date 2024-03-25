import 'package:flutter/foundation.dart';

import '../loader/loader_data.dart';
import '../loader/index_page_loader.dart';
import 'loadable_view_model.dart';

/// 页码分页加载 viewModel
abstract class IndexPageViewModel<T> extends LoadableViewModel<List<T>, PaginationLoader<T>>
    implements _PageDelegate<T> {
  @override
  late final PaginationLoader<T> loader = _PageIndexLoader(
    this,
    enableRefresh: enableRefresh,
    enableLoadMore: enableLoadMore,
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

  bool get enableLoadMore => true;

  List<T> get allData => loader.allData;

  /// 当前页参数
  IndexPageReq? get currentPage => loader.currentPage;

  @override
  LoaderResult<List<T>> get value => loader.value;

  void refresh() => load();

  @override
  Future<void> load() {
    return loader.load(true);
  }

  Future<void> beforeFetch() async {}

  @override
  Future<Pageable<T>> fetch(bool refresh, IndexPageReq query);

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
  Future<void> fetchBeforeRefresh();

  Future<Pageable<T>> fetch(bool refresh, IndexPageReq query);

  void onSuccess(List<T>? data, List<T> allData);

  void onFailure(Object? error);
}

/// 分页加载器
class _PageIndexLoader<T> extends PaginationLoader<T> {
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
    await _delegate.fetchBeforeRefresh();
  }

  @override
  Future<Pageable<T>> fetch(bool refresh, IndexPageReq query) {
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
