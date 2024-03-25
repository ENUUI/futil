import 'package:futil/src/statable_widget/loader/loader_data.dart';
import 'loadable.dart';

abstract class PageLoader<T, P> extends RefreshableLoader<List<T>> {
  PageLoader({
    super.notifier,
    super.enableRefresh,
    super.enableLoadMore,
  });

  /// 所有数据
  List<T> get allData => _allData;
  final List<T> _allData = [];

  /// 当前页的参数
  P? get currentPage => _currentPage;
  P? _currentPage;

  @override
  Future<void> refresh() {
    return load(true);
  }

  @override
  Future<void> loadMore() {
    return load();
  }

  @override
  Future<void> load([bool refresh = false]) async {
    if (loading) return;

    if (allData.isEmpty) {
      if (state.isEmpty || state.isReady) {
        updateResult(state: LoadingState.reloading);
      } else if (state.isInit || state.isError) {
        updateResult(state: LoadingState.loading);
      }
    }
    updateProcess(LoaderProcess(LoaderProcessState.start, refresh));

    try {
      if (refresh) {
        await fetchBeforeRefresh();
      }

      final (data, page) = await fetchData(refresh);
      _currentPage = page;

      if (refresh) {
        _allData.clear();
      }
      allData.addAll(data);

      if (allData.isEmpty) {
        updateResult(state: LoadingState.empty, data: data);
      } else {
        updateResult(state: LoadingState.ready, data: data);
      }

      final bool noMore = !noMoreData(data.length, page);
      updateProcess(LoaderProcess(
        noMore ? LoaderProcessState.noMore : LoaderProcessState.success,
        refresh,
      ));
      onSuccess(data);
    } catch (e) {
      updateResult(
          state: allData.isEmpty
              ? LoadingState.error
              : LoadingState.errorAndNotEmpty,
          error: error);
      updateProcess(LoaderProcess(LoaderProcessState.failed, refresh));
    }
  }

  /// 简单以长度判断是否有更多，子类可重写
  bool noMoreData(int length, P? page) {
    return length == 0;
  }

  /// 分页数据，与分页参数
  Future<(List<T>, P?)> fetchData(bool refresh);

  /// 刷新前的操作。每次刷新都会调用
  Future<void> fetchBeforeRefresh() async {}
}
