import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import '../loader/loadable.dart';
import '../loader/loadable_data.dart';
import 'refresh.dart';
import 'state.dart';
import 'widgets.dart';

/// A widget that can be in different states.
/// If [loader] is type of [RefreshMoreLoader], and [enablePullLoadMore] or [enablePullRefresh] is true, and [state] is ready,
///   the child build by [builder] will be wrapped with [RefreshWidget].
///
/// If [loader] is type of [RefreshMoreLoader], and [enablePullLoadMore] is true, and [state] is not ready,
///   the state child will be wrapped with [RefreshWidget].
class StateRefresh extends StatelessWidget {
  /// Create a [StateRefresh] with [Loadable].
  const StateRefresh({
    super.key,
    required WidgetBuilder builder,
    required this.loader,
    this.stateWidget,
    this.scrollController,
    this.refreshController,
    this.header,
    this.footer,
    this.onStateEvent,
  })  : _builder = builder,
        _physicsBuilder = null;

  /// Create a [StateRefresh] with [RefreshPhysicsBuilder].
  const StateRefresh.physics({
    super.key,
    required RefreshPhysicsBuilder builder,
    required RefreshMoreLoader this.loader,
    this.stateWidget,
    this.scrollController,
    this.refreshController,
    this.header,
    this.footer,
    this.onStateEvent,
  })  : _builder = null,
        _physicsBuilder = builder;

  final StateWidget? stateWidget; // 状态切换
  final WidgetBuilder? _builder;
  final RefreshPhysicsBuilder? _physicsBuilder;
  final ScrollController? scrollController; // 滚动控制器
  final EasyRefreshController? refreshController; // 刷新控制器
  final Loadable loader; // 加载器
  final RefreshHeader? header; // 刷新头部
  final RefreshFooter? footer; // 刷新底部
  final StateEventCallback? onStateEvent; // 状态事件

  /// Whether to wrap the [builder] with [RefreshWidget].
  bool _wrapStatePullToRefresh(Loadable loader) {
    return loader is RefreshMoreLoader && loader.enablePullRefresh;
  }

  bool _wrapContentPullToRefresh(Loadable loader) {
    return loader is RefreshMoreLoader && (loader.enablePullLoadMore || loader.enablePullRefresh);
  }

  /// The default [onStateEvent] for [StateSwitchWidget].
  Future<void> _onStateEvent(LoadingState state, Object? extra) async {
    switch (state) {
      case LoadingState.empty:
      case LoadingState.error:
        return loader.load();
      case LoadingState.init:
      case LoadingState.loading:
      case LoadingState.reloading:
      case LoadingState.ready:
      case LoadingState.errorAndNotEmpty:
        break;
    }
  }

  /// Build the [RefreshWidget].
  Widget _buildRefresh(BuildContext context, RefreshMoreLoader loader) {
    if (_builder != null) {
      return RefreshWidget(
        refreshController: refreshController,
        scrollController: scrollController,
        builder: _builder,
        refreshableLoader: loader,
        header: header,
        footer: footer,
      );
    } else if (_physicsBuilder != null) {
      return RefreshWidget.builder(
        refreshController: refreshController,
        scrollController: scrollController,
        refreshableLoader: loader,
        builder: _physicsBuilder,
        header: header,
        footer: footer,
      );
    }
    assert(() {
      throw Exception('Impossible');
    }());
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return StateSwitchWidget(
      state: loader.value.state,
      error: loader.value.error,
      stateWidget: stateWidget,
      wrapPullToRefresh: _wrapStatePullToRefresh(loader),
      header: header,
      onStateEvent: onStateEvent ?? _onStateEvent,
      readyWidgetBuilder: (context) {
        if (_wrapContentPullToRefresh(loader)) {
          return _buildRefresh(context, loader as RefreshMoreLoader);
        } else {
          return _builder?.call(context) ?? const SizedBox.shrink();
        }
      },
    );
  }
}
