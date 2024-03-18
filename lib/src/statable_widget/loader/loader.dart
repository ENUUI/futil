import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'loadable.dart';
import 'loader_data.dart';


class Loader<T> extends RefreshableLoader<T> {
  Loader(
    this._fetch, {
    this.onCompletion,
    super.notifier,
    super.enableRefresh,
  }) : super(enableLoadMore: false);

  final Future<T> Function() _fetch;
  final void Function(bool success, T? data, Object? error)? onCompletion;

  @override
  Future<void> load() async {
    if (loading) return;
    if (state.isInit || state.isError) {
      updateResult(state: LoadingState.loading);
    }
    updateProcess(const LoaderProcess(LoaderProcessState.start, true));
    try {
      final data = await _fetch.call();
      updateResult(data: data, state: LoadingState.ready);
      updateProcess(const LoaderProcess(LoaderProcessState.success, true));
      onSuccess(data);
    } catch (error) {
      updateResult(data: null, state: LoadingState.error, error: error);
      updateProcess(const LoaderProcess(LoaderProcessState.failed, true));
      onFailure(error);
    }
  }

  @override
  Future<void> refresh() {
    return load();
  }

  @override
  Future<void> loadMore() async {}

  @mustCallSuper
  @override
  void onSuccess(T? data) {
    super.onSuccess(data);
    onCompletion?.call(true, data, null);
  }

  @override
  void onFailure(Object? error) {
    super.onFailure(error);
    onCompletion?.call(false, null, error);
  }
}
