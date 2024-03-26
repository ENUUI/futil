import '../loader/loadable.dart';
import '../loader/loader_data.dart';
import 'base_view_model.dart';

abstract class LoadableViewModel<T, L extends RefreshableLoader<T>> extends BaseViewModel {
  L get loader;

  LoaderResult<T> get value;

  LoadingState get state => value.state;

  T? get data => value.data;

  Future<void> load();
}
