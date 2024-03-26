import 'package:flutter/foundation.dart';
import 'package:futil/src/statable_widget/loader/page_loader.dart';

class PKey {
  PKey({this.limit = kPageLimit, this.next});

  final int limit;
  final Object? next;
}

class Kpd<T> {
  Kpd({
    this.next,
    this.data = const [],
  });

  final Object? next;
  final List<T> data;
}

abstract class PageByKeyLoader<T> extends PageLoader<T, PKey> {
  int get limit => kPageLimit;

  @protected
  @override
  Future<(List<T>, PKey?)> fetchData(bool refresh, PKey? before) {
    final query = nextPageQuery(refresh, before);
    return fetch(refresh, query).then((data) {
      return (data.data, query);
    });
  }

  Future<Kpd<T>> fetch(bool refresh, PKey req);

  PKey nextPageQuery(bool refresh, PKey? before) {
    if (refresh) {
      return PKey(limit: limit);
    }
    return PKey(limit: limit, next: before?.next);
  }

  @override
  bool noMoreData(bool refresh, int length, PKey? page) {
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
