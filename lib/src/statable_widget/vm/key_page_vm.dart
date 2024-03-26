import 'package:futil/src/statable_widget/loader/loader_data.dart';
import 'package:futil/src/statable_widget/loader/page_by_key.dart';

import 'loadable_view_model.dart';

abstract class KeyPageViewModel<T> extends LoadableViewModel<List<T>, PageByKeyLoader<T>> implements _PageDelegate<T> {
  @override
  late final PageByKeyLoader<T> loader = _PageKeyLoader(
    this,
    enableRefresh: enableRefresh,
    enableLoadMore: enableLoadMore,
  );

  @override
  void initialize() {
    super.initialize();
    loader.addListener(() {
      notifyListeners();
    });
  }

  bool get enableRefresh => true;

  bool get enableLoadMore => true;

  @override
  LoaderResult<List<T>> get value => loader.value;

  @override
  Future<void> fetchBeforeRefresh() async {}

  @override
  void onFailure(Object? error) {}

  @override
  void onSuccess(List? data, List allData) {}
}

/// 分页加载器
abstract class _PageDelegate<T> {
  Future<void> fetchBeforeRefresh();

  Future<PageKeyData<T>> fetch(bool refresh, PageKey query);

  void onSuccess(List<T>? data, List<T> allData);

  void onFailure(Object? error);
}

class _PageKeyLoader<T> extends PageByKeyLoader<T> {
  _PageKeyLoader(this._delegate, {this.enableRefresh = true, this.enableLoadMore = true});

  @override
  final bool enableRefresh;
  @override
  final bool enableLoadMore;
  final _PageDelegate<T> _delegate;

  @override
  Future<void> fetchBeforeRefresh() {
    return _delegate.fetchBeforeRefresh();
  }

  @override
  Future<PageKeyData<T>> fetch(bool refresh, PageKey req) {
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
