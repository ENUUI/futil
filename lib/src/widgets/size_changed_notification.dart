import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SizedNotification<T> extends LayoutChangedNotification {
  SizedNotification(this.size, this.id, {this.data, this.depthId});

  final Size size;
  final String? id;
  final String? depthId;
  final T? data;

  @override
  String toString() {
    final res = super.toString();
    return '${res}id: $id, size: $size, depthId: $depthId, data: $data';
  }
}

class SizedNotifier<T> extends SingleChildRenderObjectWidget {
  const SizedNotifier({
    super.key,
    super.child,
    this.id,
    this.data,
    this.depthId,
  });
  final String? id;
  final String? depthId;
  final T? data;

  @override
  RenderSizedWithCallback createRenderObject(BuildContext context) {
    return RenderSizedWithCallback(onLayoutChangedCallback: (size) {
      SizedNotification(
        size,
        id,
        data: data,
        depthId: depthId,
      ).dispatch(context);
    });
  }
}

class RenderSizedWithCallback extends RenderProxyBox {
  RenderSizedWithCallback({
    RenderBox? child,
    required this.onLayoutChangedCallback,
  }) : super(child);
  final ValueChanged<Size> onLayoutChangedCallback;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (size != _oldSize) onLayoutChangedCallback(size);
    _oldSize = size;
  }
}
