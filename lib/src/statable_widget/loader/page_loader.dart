import 'dart:async';

import 'package:flutter/foundation.dart';

import 'loadable.dart';
import 'loader_data.dart';

const int kPageLimit = 20;

abstract class PageableReq {
  int get limit;

  int get page;
}

class IndexPageReq implements PageableReq {
  IndexPageReq({required this.limit, required this.page});

  @override
  final int limit;
  @override
  final int page;
}

class Pageable<T> {
  Pageable({
    this.total = 0,
    this.page = 0,
    this.limit = 0,
    this.data = const [],
  });

  final int total;
  final int page;
  final int limit;
  final List<T> data;

  factory Pageable.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return Pageable(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      data: (json['data'] as List? ?? []).map((e) => fromJson(e)).toList(),
    );
  }
}

abstract class PageableLoader<T, Page extends PageableReq>
    extends RefreshableLoader<Pageable<T>> {
  PageableLoader({
    super.notifier,
    super.enableRefresh,
    super.enableLoadMore,
  });

  List<T> get allData => _allData;
  final List<T> _allData = [];

  @override
  Future<void> refresh() {
    return load(true);
  }

  @override
  Future<void> loadMore() {
    return load();
  }

  @override
  Future<void> load([bool refresh = false]) async {
    if (loading) return;

    if (allData.isEmpty) {
      if (state.isEmpty || state.isReady) {
        updateResult(state: LoadingState.reloading);
      } else if (state.isInit || state.isError) {
        updateResult(state: LoadingState.loading);
      }
    }

    updateProcess(LoaderProcess(LoaderProcessState.start, refresh));
    try {
      if (refresh) {
        await fetchBeforeRefresh();
      }

      final data = await fetch(refresh, getPageQuery(this.data, refresh));
      final list = data.data;
      final listLen = list.length;
      final dataLimit = data.limit <= 0 ? kPageLimit : data.limit;
      final total = data.total;
      if (refresh) {
        _allData.clear();
      }

      _allData.addAll(list);
      bool noMore = false;
      if (total > 0) {
        noMore = allData.length >= total || listLen < dataLimit;
      } else {
        noMore = listLen < dataLimit;
      }
      if (allData.isEmpty) {
        updateResult(state: LoadingState.empty, data: data);
      } else {
        updateResult(state: LoadingState.ready, data: data);
      }
      updateProcess(LoaderProcess(
          noMore ? LoaderProcessState.noMore : LoaderProcessState.success,
          refresh));
      onSuccess(data);
    } catch (error) {
      updateResult(
          state: allData.isEmpty
              ? LoadingState.error
              : LoadingState.errorAndNotEmpty,
          error: error);
      updateProcess(LoaderProcess(LoaderProcessState.failed, refresh));
      onFailure(error);
    }
  }

  Future<Pageable<T>> fetch(bool refresh, Page query);

  Future<void> fetchBeforeRefresh() async {}

  Page getPageQuery(Pageable<T>? oldData, bool refresh);
}

abstract class PaginationLoader<T> extends PageableLoader<T, IndexPageReq> {
  PaginationLoader({
    super.notifier,
    super.enableRefresh,
    super.enableLoadMore,
  });

  int _page = 1;

  @override
  IndexPageReq getPageQuery(Pageable<T>? oldData, bool refresh) {
    int page;
    if (refresh) {
      page = 1;
    } else {
      page = (oldData?.page ?? _page) + 1;
    }
    return IndexPageReq(limit: kPageLimit, page: page);
  }

  @override
  @mustCallSuper
  void onSuccess(Pageable<T>? data) {
    // 设置当前页码
    _page = data?.page ?? _page + 1;
    super.onSuccess(data);
  }
}

class PageIndexLoader<T> extends PaginationLoader<T> {
  PageIndexLoader(
    this._fetch, {
    this.beforeRefresh,
    this.onCompletion,
    super.notifier,
    super.enableRefresh,
    super.enableLoadMore,
  });

  final Future<void> Function()? beforeRefresh;
  final void Function(bool, Pageable<T>? data, Object? error)? onCompletion;
  final Future<Pageable<T>> Function(bool refresh, IndexPageReq query) _fetch;

  @override
  Future<void> fetchBeforeRefresh() async {
    await beforeRefresh?.call();
  }

  @override
  Future<Pageable<T>> fetch(bool refresh, IndexPageReq query) {
    return _fetch(refresh, query);
  }

  @mustCallSuper
  @override
  void onSuccess(Pageable<T>? data) {
    super.onSuccess(data);
    onCompletion?.call(true, data, null);
  }

  @mustCallSuper
  @override
  void onFailure(Object? error) {
    super.onFailure(error);
    onCompletion?.call(false, null, error);
  }
}
