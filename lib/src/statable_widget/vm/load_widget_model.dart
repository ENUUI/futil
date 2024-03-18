
import '../loader/loadable.dart';
import '../loader/loader.dart';
import '../loader/loader_data.dart';
import '../loader/page_loader.dart';
import 'base_view_model.dart';

abstract class LoadViewModel<T, L extends RefreshableLoader<T>> extends BaseViewModel {
  L get loader;

  LoaderResult<T> get value;

  LoadingState get state => value.state;

  T? get data => value.data;

  Future<void> load();
}

abstract class LoadingWidgetModel<T> extends LoadViewModel<T, Loader<T>> {
  @override
  late final Loader<T> loader = Loader(
    fetchData,
    notifier: this,
    enableRefresh: enableRefresh,
    onCompletion: _onCompletion,
  );

  bool? get enableRefresh => null;

  void _onCompletion(bool success, T? data, Object? error) {
    if (success) {
      onSuccess(data);
    } else {
      onFailure(error);
    }
  }

  void refresh() => load();

  @override
  Future<void> load() {
    return loader.load();
  }

  Future<T> fetchData();

  @override
  LoaderResult<T> get value => loader.value;

  void onSuccess(T? data) {}

  void onFailure(Object? error) {}
}

abstract class RefreshPaginationWidgetModel<T> extends LoadViewModel<Pageable<T>, PageIndexLoader<T>> {
  @override
  late final PageIndexLoader<T> loader = PageIndexLoader(
    fetch,
    beforeRefresh: beforeFetch,
    onCompletion: _onCompletion,
    notifier: this,
    enableRefresh: enableRefresh,
    enableLoadMore: enableLoadMore,
  );

  bool? get enableRefresh => null;

  bool? get enableLoadMore => null;

  List<T> get allData => loader.allData;

  @override
  LoaderResult<Pageable<T>> get value => loader.value;

  void refresh() => load();

  @override
  Future<void> load() {
    return loader.load(true);
  }

  Future<void> beforeFetch() async {}

  Future<Pageable<T>> fetch(bool refresh, IndexPageReq query);

  void _onCompletion(bool success, Pageable<T>? data, Object? error) {
    if (success) {
      onSuccess(data, allData);
    } else {
      onFailure(error);
    }
  }

  @override
  void dispose() {
    loader.dispose();
    super.dispose();
  }

  void onSuccess(Pageable<T>? data, List<T> allData) {}

  void onFailure(Object? error) {}
}
