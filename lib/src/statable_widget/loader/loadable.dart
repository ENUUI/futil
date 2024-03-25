import '../vm/base_view_model.dart';
import 'loader_data.dart';

class ProcessValue extends BaseValueNotifier<LoaderProcess> {
  ProcessValue() : super(const LoaderProcess(LoaderProcessState.none, true));
}

abstract class Loadable<T> extends BaseViewModel {
  final ProcessValue processValue = ProcessValue();

  LoaderResult<T> get value => _value;
  LoaderResult<T> _value = LoaderResult<T>(state: LoadingState.init);

  /// 加载数据
  Future<void> load();

  Future<void> refresh() => load();

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

abstract class RefreshableLoader<T> extends Loadable<T> {
  bool get enableRefresh => true;

  bool get enableLoadMore => true;

  Future<void> loadMore();
}
