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
  int get limit => kPageLimit;

  int _total = 0;

  @protected
  @override
  Future<(List<T>, IndexPageReq?)> fetchData(bool refresh, IndexPageReq? before) async {
    final query = nextPageQuery(refresh, before);
    final data = await fetch(refresh, query);
    _total = data.total;
    return (data.data, query);
  }

  Future<Pageable<T>> fetch(bool refresh, IndexPageReq req);

  IndexPageReq nextPageQuery(bool refresh, IndexPageReq? before) {
    int page;
    if (refresh) {
      page = 1;
    } else {
      page = (before?.page ?? 0) + 1;
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
