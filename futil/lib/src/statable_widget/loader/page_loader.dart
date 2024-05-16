import 'package:futil/src/statable_widget/loader/loadable_data.dart';
import 'loadable.dart';

const int kPageLimit = 20;

/// 分页加载器，继承 [PageLoader] 可以实现分页加载
/// [T] 分页结果元素的数据类型, [P] 分页参数的数据类型
/// eg. [PageByIndexLoader] 页码分页加载器，[PageByKeyLoader] key分页加载器
abstract class PageLoader<T, P> extends RefreshMoreLoader<List<T>> {
  /// 所有数据；不要直接操作该数据，使用[updateResult] 方法更新数据
  List<T> get allData => _allData;
  List<T> _allData = <T>[];

  /// 当前页的参数
  P? _page;

  @override
  Future<void> load() => refresh();

  @override
  Future<void> refresh() => _load(true);

  @override
  Future<void> loadMore() => _load(false);

  Future<void> _load(bool refresh) async {
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
      final next = nextPage(refresh, _page);
      final (data, page) = await fetchData(refresh, next);
      _page = page;

      final bool noMore = noMoreData(refresh, data.length, page);
      updateProcess(LoaderProcess(
        noMore ? LoaderProcessState.noMore : LoaderProcessState.success,
        refresh,
      ));

      // 跟新数据; 刷新时清空数据;
      _allData = <T>[if (!refresh) ..._allData, ...data];
      final nextState = _allData.isEmpty ? LoadingState.empty : LoadingState.ready;
      updateResult(state: nextState, data: _allData);

      onSuccess(data);
    } catch (e) {
      updateResult(state: allData.isEmpty ? LoadingState.error : LoadingState.errorAndNotEmpty, error: e);
      updateProcess(LoaderProcess(LoaderProcessState.failed, refresh));
    }
  }

  /// 简单以长度判断是否有更多，子类可重写
  bool noMoreData(bool refresh, int length, P page) {
    return length == 0;
  }

  /// 分页数据，与分页参数
  Future<(List<T>, P)> fetchData(bool refresh, P p);

  /// 刷新前的操作。每次刷新都会调用
  Future<void> fetchBeforeRefresh() async {}

  P nextPage(bool refresh, P? p);
}
