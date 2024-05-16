import '../vm/base.dart';
import 'loadable_data.dart';

class ProcessValue extends BaseValueNotifier<LoaderProcess> {
  ProcessValue() : super(const LoaderProcess(LoaderProcessState.none, true));
}

abstract class Loadable<T> extends BaseViewModel {
  final ProcessValue processValue = ProcessValue();

  LoaderResult<T> get value => _value;
  LoaderResult<T> _value = LoaderResult<T>(state: LoadingState.init);

  /// 加载数据
  /// 如果是分页加载, 等同于刷新
  Future<void> load();

  void onSuccess(T? data) {}

  void onFailure(Object? error) {}

  void updateResult({T? data, Object? error, LoadingState? state}) {
    final nextValue = _value.copy(data: data, error: error, state: state);
    _value = nextValue;
    notifyListeners();
  }

  void updateProcess(LoaderProcess process) {
    processValue.value = process;
  }

  @override
  void dispose() {
    processValue.dispose();
    super.dispose();
  }
}

/// 此抽象类用于实现下拉刷新和上拉加载更多. 仅此累的实现类才能实现下拉刷新和上拉加载更多
abstract class RefreshMoreLoader<T> extends Loadable<T> {
  /// 仅用于判断是否启用下拉刷新
  bool get enablePullRefresh => true;

  /// 仅用于判断是否启用上拉加载更多
  bool get enablePullLoadMore => true;

  /// 此方法调用不受 [enablePullRefresh] 限制
  Future<void> refresh();

  /// 此方法调用不受 [enablePullLoadMore] 限制
  Future<void> loadMore();
}
