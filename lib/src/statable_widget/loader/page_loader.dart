import 'package:futil/src/statable_widget/loader/loader_data.dart';
import 'loadable.dart';

const int kPageLimit = 20;

abstract class PageLoader<T, P> extends RefreshableLoader<List<T>> {
  /// 所有数据；不要直接操作该数据，使用[updateResult] 方法更新数据
  List<T> get allData => _allData;
  List<T> _allData = <T>[];

  /// 当前页的参数
  P? get currentPage => _currentPage;
  P? _currentPage;

  @override
  Future<void> refresh() {
    return load(true);
  }

  @override
  Future<void> loadMore() {
    return load(false);
  }

  @override
  Future<void> load([bool refresh = true]) async {
    if (value.state.isLoading) return;

    final state = value.state;
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

      final (data, page) = await fetchData(refresh, nextPage(refresh, _currentPage));
      _currentPage = page;

      // 跟新数据; 刷新时清空数据;
      _allData = <T>[if (!refresh) ..._allData, ...data];
      final nextState = _allData.isEmpty ? LoadingState.empty : LoadingState.ready;
      updateResult(state: nextState, data: _allData);

      final bool noMore = noMoreData(refresh, data.length, page);
      updateProcess(LoaderProcess(
        noMore ? LoaderProcessState.noMore : LoaderProcessState.success,
        refresh,
      ));
      onSuccess(data);
    } catch (e) {
      updateResult(state: allData.isEmpty ? LoadingState.error : LoadingState.errorAndNotEmpty, error: e);
      updateProcess(LoaderProcess(LoaderProcessState.failed, refresh));
    }
  }

  /// 简单以长度判断是否有更多，子类可重写
  bool noMoreData(bool refresh, int length, P? page) {
    return length == 0;
  }

  /// 分页数据，与分页参数
  Future<(List<T>, P?)> fetchData(bool refresh, P p);

  /// 刷新前的操作。每次刷新都会调用
  Future<void> fetchBeforeRefresh() async {}

  P nextPage(bool refresh, P? p);
}
