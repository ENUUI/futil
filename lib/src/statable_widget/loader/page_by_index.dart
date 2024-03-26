import 'dart:async';

import 'package:flutter/foundation.dart';

import 'page_loader.dart';

class PIndex {
  PIndex({required this.limit, required this.page});

  final int limit;
  final int page;
}

class Ipd<T> {
  Ipd({
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

abstract class PageByIndexLoader<T> extends PageLoader<T, PIndex> {
  int get limit => kPageLimit;

  int _total = 0;

  @protected
  @override
  Future<(List<T>, PIndex?)> fetchData(bool refresh, PIndex? before) async {
    final query = nextPageQuery(refresh, before);
    final data = await fetch(refresh, query);
    _total = data.total;
    return (data.data, query);
  }

  Future<Ipd<T>> fetch(bool refresh, PIndex req);

  PIndex nextPageQuery(bool refresh, PIndex? before) {
    int page;
    if (refresh) {
      page = 1;
    } else {
      page = (before?.page ?? 0) + 1;
    }
    return PIndex(limit: limit, page: page);
  }

  @override
  bool noMoreData(bool refresh, int length, PIndex? page) {
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
