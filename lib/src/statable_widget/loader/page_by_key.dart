import 'package:flutter/foundation.dart';
import 'package:futil/src/statable_widget/loader/page_loader.dart';

/// 分页加载参数
class PKey {
  PKey({this.next});

  final Object? next;
}

/// 分页加载结果
class Kpd<T> {
  Kpd({
    this.next,
    this.data = const [],
  });

  final Object? next;
  final List<T> data;
}

///  Key 分页加载器
abstract class PageByKeyLoader<T> extends PageLoader<T, PKey> {
  @protected
  @override
  Future<(List<T>, PKey)> fetchData(bool refresh, PKey p) {
    return fetch(refresh, p).then((data) {
      return (data.data, PKey(next: data.next));
    });
  }

  @override
  PKey nextPage(bool refresh, PKey? p) {
    if (refresh) {
      return PKey(next: null);
    }
    assert(p?.next != null);
    return PKey(next: p?.next);
  }

  Future<Kpd<T>> fetch(bool refresh, PKey req);

  @override
  bool noMoreData(bool refresh, int length, PKey page) {
    if (page.next == null) {
      return true;
    }
    return super.noMoreData(refresh, length, page);
  }
}
