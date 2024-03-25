import 'dart:async';

import 'package:flutter/foundation.dart';

import 'page_loader.dart';

const int kPageLimit = 20;

abstract class PageableReq {
  int get limit;
}

class IndexPageReq implements PageableReq {
  IndexPageReq({required this.limit, required this.page});

  @override
  final int limit;
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
}

abstract class PaginationLoader<T> extends PageLoader<T, IndexPageReq> {
  PaginationLoader({
    super.notifier,
    super.enableRefresh,
    super.enableLoadMore,
    this.limit = kPageLimit,
  }) : assert(limit > 0);

  final int limit;

  int _total = 0;

  @protected
  @override
  Future<(List<T>, IndexPageReq?)> fetchData(bool refresh) async {
    final query = nextPageQuery(refresh);
    final data = await fetch(refresh, query);
    _total = data.total;
    return (data.data, query);
  }

  Future<Pageable<T>> fetch(bool refresh, IndexPageReq req);

  IndexPageReq nextPageQuery(bool refresh) {
    int page;
    if (refresh) {
      page = 1;
    } else {
      page = (currentPage?.page ?? 0) + 1;
    }
    return IndexPageReq(limit: limit, page: page);
  }

  @override
  bool noMoreData(int length, IndexPageReq? page) {
    if (_total > 0 && _total <= allData.length) {
      return true;
    }

    if (page != null && length < page.limit) {
      return true;
    }

    if (length < limit) {
      return true;
    }

    return super.noMoreData(length, page);
  }
}
