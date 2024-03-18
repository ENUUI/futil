import '../vm/base_view_model.dart';
import 'loader_data.dart';

class ProcessValue extends BaseValueNotifier<LoaderProcess> {
  ProcessValue() : super(const LoaderProcess(LoaderProcessState.none, true));
}

abstract class Loadable<T> {
  Loadable({this.notifier});

  final BaseViewModel? notifier;

  final ProcessValue processValue = ProcessValue();

  T? get data => value.data;

  LoadingState get state => value.state;

  Object? get error => value.error;

  bool get loading => value.state.isLoading;

  Future<void> load();

  void onSuccess(T? data) {}

  void onFailure(Object? error) {}

  void updateResult({T? data, Object? error, LoadingState? state}) {
    final nextValue = _value.copy(data: data, error: error, state: state);
    _value = nextValue;
    notifier?.notifyListeners();
  }

  LoaderResult<T> get value => _value;
  LoaderResult<T> _value = LoaderResult<T>(state: LoadingState.init);

  void dispose() {
    processValue.dispose();
  }

  void updateProcess(LoaderProcess process) {
    processValue.value = process;
  }

  Future<void> refresh();
}

abstract class RefreshableLoader<T> extends Loadable<T> {
  RefreshableLoader({
    super.notifier,
    bool? enableRefresh,
    bool? enableLoadMore,
  })  : _enableRefresh = enableRefresh,
        _enableLoadMore = enableLoadMore;

  bool get enableRefresh => _enableRefresh ?? true;
  final bool? _enableRefresh;

  bool get enableLoadMore => _enableLoadMore ?? true;
  final bool? _enableLoadMore;

  Future<void> loadMore();
}
