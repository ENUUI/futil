import '../loader/loader_data.dart';
import '../loader/index_page_loader.dart';
import 'base_view_model.dart';
import 'loadable_view_model.dart';

/// 页码分页加载 viewModel
abstract class IndexPageViewModel<T> extends LoadableViewModel<List<T>, PaginationLoader<T>> implements _PageNotifier<T> {
  @override
  late final PaginationLoader<T> loader = _PageIndexLoader(
    notifier: this,
    enableRefresh: enableRefresh,
    enableLoadMore: enableLoadMore,
  );

  bool? get enableRefresh => null;

  bool? get enableLoadMore => null;

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
abstract class _PageNotifier<T> extends BaseViewModel {
  Future<void> fetchBeforeRefresh();

  Future<Pageable<T>> fetch(bool refresh, IndexPageReq query);

  void onSuccess(List<T>? data, List<T> allData);

  void onFailure(Object? error);
}

/// 分页加载器
class _PageIndexLoader<T, N extends _PageNotifier<T>> extends PaginationLoader<T> {
  _PageIndexLoader({
    required N super.notifier,
    super.enableRefresh,
    super.enableLoadMore,
  });

  N get _notifier => super.notifier! as N;

  @override
  Future<void> fetchBeforeRefresh() async {
    await _notifier.fetchBeforeRefresh();
  }

  @override
  Future<Pageable<T>> fetch(bool refresh, IndexPageReq query) {
    return _notifier.fetch(refresh, query);
  }

  @override
  void onSuccess(List<T>? data) {
    super.onSuccess(data);
    _notifier.onSuccess(data, allData);
  }

  @override
  void onFailure(Object? error) {
    super.onFailure(error);
    _notifier.onFailure(error);
  }
}
