import '../loader/loader.dart';
import '../loader/loader_data.dart';
import 'base_view_model.dart';
import 'loadable_view_model.dart';

abstract class RefreshableViewModel<T> extends LoadableViewModel<T, Loader<T>> implements _LoadingVm<T> {
  @override
  late final Loader<T> loader = _Loader(
    notifier: this,
    enableRefresh: enableRefresh,
  );

  bool? get enableRefresh => null;

  void refresh() => load();

  @override
  Future<void> load() {
    return loader.load();
  }

  @override
  Future<T> fetch();

  @override
  LoaderResult<T> get value => loader.value;

  @override
  void onSuccess(T? data) {}

  @override
  void onFailure(Object? error) {}
}

abstract class _LoadingVm<T> extends BaseViewModel {
  Future<T> fetch();

  void onSuccess(T? data) {}

  void onFailure(Object? error) {}
}

class _Loader<T, N extends _LoadingVm<T>> extends Loader<T> {
  _Loader({
    required N super.notifier,
    super.enableRefresh,
  });

  N get _notifier => super.notifier as N;

  @override
  Future<T> fetch() {
    return _notifier.fetch();
  }

  @override
  void onSuccess(T? data) {
    _notifier.onSuccess(data);
  }

  @override
  void onFailure(Object? error) {
    _notifier.onFailure(error);
  }
}
