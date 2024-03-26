import 'package:flutter/foundation.dart';
import 'package:futil/src/statable_widget/loader/page_loader.dart';

class PageKey {
  PageKey({this.limit = kPageLimit, this.next});

  final int limit;
  final Object? next;
}

class PageKeyData<T> {
  PageKeyData({
    this.next,
    this.data = const [],
  });

  final Object? next;
  final List<T> data;
}

abstract class PageByKeyLoader<T> extends PageLoader<T, PageKey> {
  int get limit => kPageLimit;

  @protected
  @override
  Future<(List<T>, PageKey?)> fetchData(bool refresh, PageKey? before) {
    final query = nextPageQuery(refresh, before);
    return fetch(refresh, query).then((data) {
      return (data.data, query);
    });
  }

  Future<PageKeyData<T>> fetch(bool refresh, PageKey req);

  PageKey nextPageQuery(bool refresh, PageKey? before) {
    if (refresh) {
      return PageKey(limit: limit);
    }
    return PageKey(limit: limit, next: before?.next);
  }

  @override
  bool noMoreData(bool refresh, int length, PageKey? page) {
    if (!refresh) {
      if (page == null || page.next == null) {
        return true;
      }
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
