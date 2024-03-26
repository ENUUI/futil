import 'package:flutter/foundation.dart';
import 'package:futil/src/statable_widget/loader/page_loader.dart';

class PKey {
  PKey({this.next});

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
  @protected
  @override
  Future<(List<T>, PKey?)> fetchData(bool refresh, PKey p) {
    return fetch(refresh, p).then((data) {
      return (data.data, PKey(next: data.next));
    });
  }

  @override
  PKey nextPage(bool refresh, PKey? p) {
    if (refresh) {
      return PKey(next: null);
    }
    return PKey(next: p?.next);
  }

  Future<Kpd<T>> fetch(bool refresh, PKey req);

  @override
  bool noMoreData(bool refresh, int length, PKey? page) {
    if (!refresh) {
      if (page == null || page.next == null) {
        return true;
      }
    }
    return super.noMoreData(refresh, length, page);
  }
}
