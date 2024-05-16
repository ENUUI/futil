import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'loadable.dart';
import 'loadable_data.dart';

/// 单次加载loader
abstract class Loader<T> extends RefreshMoreLoader<T> {
  @protected
  @override
  bool get enablePullLoadMore => false;

  /// 少数情况下，不分页的页面也可能支持下拉刷新
  @override
  bool get enablePullRefresh => false;

  @override
  Future<void> load() => refresh();

  Future<T> fetch();

  @override
  Future<void> refresh() => _load();

  Future<void> _load() async {
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

  @protected
  @override
  Future<void> loadMore() async {
    assert(false, 'loadMore is not supported');
  }
}
