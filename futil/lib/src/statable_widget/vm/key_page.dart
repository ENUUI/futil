import '../loader/page_by_key.dart';
import 'base.dart';

abstract class KeyPageViewModel<T> extends LoadableViewModel<List<T>, PageByKeyLoader<T>> implements _PageDelegate<T> {
  @override
  late final PageByKeyLoader<T> loader = _PageKeyLoader(
    this,
    enablePullRefresh: enableRefresh,
    enablePullLoadMore: enableLoadMore,
  );

  bool get enableRefresh => true;

  bool get enableLoadMore => true;

  /// 所有数据；不要直接操作该数据，使用 [loader.updateResult] 方法
  List<T> get allData => value.data ?? <T>[];

  @override
  Future<void> load() {
    return loader.load();
  }

  @override
  Future<Kpd<T>> fetch(bool refresh, PKey query);

  @override
  Future<void> beforeFetch() async {}

  @override
  void onFailure(Object? error) {}

  @override
  void onSuccess(List? data, List allData) {}
}

/// 分页加载器
abstract class _PageDelegate<T> {
  Future<void> beforeFetch();

  Future<Kpd<T>> fetch(bool refresh, PKey query);

  void onSuccess(List<T>? data, List<T> allData);

  void onFailure(Object? error);
}

class _PageKeyLoader<T> extends PageByKeyLoader<T> {
  _PageKeyLoader(this._delegate, {this.enablePullRefresh = true, this.enablePullLoadMore = true});

  @override
  final bool enablePullRefresh;
  @override
  final bool enablePullLoadMore;
  final _PageDelegate<T> _delegate;

  @override
  Future<void> fetchBeforeRefresh() {
    return _delegate.beforeFetch();
  }

  @override
  Future<Kpd<T>> fetch(bool refresh, PKey req) {
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
