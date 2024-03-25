import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'loadable.dart';
import 'loader_data.dart';

abstract class Loader<T> extends RefreshableLoader<T> {
  @protected
  @override
  bool get enableLoadMore => false;

  @override
  Future<void> load() async {
    final state = value.state;
    if (state.isLoading) return;
    if (state.isInit || state.isError) {
      updateResult(state: LoadingState.loading);
    }
    updateProcess(const LoaderProcess(LoaderProcessState.start, true));
    try {
      final data = await fetch();
      updateResult(data: data, state: LoadingState.ready);
      updateProcess(const LoaderProcess(LoaderProcessState.success, true));
      onSuccess(data);
    } catch (error) {
      updateResult(data: null, state: LoadingState.error, error: error);
      updateProcess(const LoaderProcess(LoaderProcessState.failed, true));
      onFailure(error);
    }
  }

  Future<T> fetch();

  @override
  Future<void> refresh() {
    return load();
  }

  @protected
  @override
  Future<void> loadMore() async {
    assert(false, 'loadMore is not supported');
  }
}
