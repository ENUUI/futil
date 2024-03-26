import 'dart:async';

import 'package:flutter/foundation.dart';

import 'page_loader.dart';

class PageIndex {
  PageIndex({required this.limit, required this.page});

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

abstract class PageByIndexLoader<T> extends PageLoader<T, PageIndex> {
  int get limit => kPageLimit;

  int _total = 0;

  @protected
  @override
  Future<(List<T>, PageIndex?)> fetchData(bool refresh, PageIndex? before) async {
    final query = nextPageQuery(refresh, before);
    final data = await fetch(refresh, query);
    _total = data.total;
    return (data.data, query);
  }

  Future<Pageable<T>> fetch(bool refresh, PageIndex req);

  PageIndex nextPageQuery(bool refresh, PageIndex? before) {
    int page;
    if (refresh) {
      page = 1;
    } else {
      page = (before?.page ?? 0) + 1;
    }
    return PageIndex(limit: limit, page: page);
  }

  @override
  bool noMoreData(bool refresh, int length, PageIndex? page) {
    if (_total > 0 && _total <= allData.length) {
      return true;
    }

    if (page != null && length < page.limit) {
      return true;
    }

    if (length < limit) {
      return true;
    }

    return super.noMoreData(refresh, length, page);
  }
}
