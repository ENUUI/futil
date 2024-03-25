import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loader/loadable.dart';
import 'loader/loader_data.dart';
import 'refresh/refresh_widget.dart';
import 'refresh/state_switch.dart';
import 'refresh/widgets.dart';

export 'loader/loadable.dart';
export 'loader/loader_data.dart';
export 'loader/loader.dart';
export 'loader/index_page_loader.dart';

export 'refresh/refresh_widget.dart';
export 'refresh/state_switch.dart';
export 'refresh/widgets.dart';

export 'vm/base_view_model.dart';
export 'vm/loadable_view_model.dart';

/// A provider that provides [RefreshHeader], [RefreshFooter] and [StateWidget].
class StatableProvider extends ChangeNotifier {
  static StatableProvider? maybeOf(BuildContext context) {
    try {
      return Provider.of<StatableProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  StatableProvider({
    this.header,
    this.footer,
    this.stateWidget,
  });

  final StateWidget? stateWidget;
  final RefreshHeader? header;
  final RefreshFooter? footer;
}

/// A widget that can be in different states.
class StatableWidget extends StatelessWidget {
  /// Create a [StatableWidget] with [Loadable].
  const StatableWidget({
    super.key,
    required WidgetBuilder builder,
    required this.loader,
    this.stateWidget,
    this.scrollController,
    this.refreshController,
    this.header,
    this.footer,
    this.onStateEvent,
    this.wrapRefresh = false,
  })  : assert((wrapRefresh && loader is RefreshableLoader) || !wrapRefresh),
        _builder = builder,
        _physicsBuilder = null;

  /// Create a [StatableWidget] with [RefreshPhysicsBuilder].
  const StatableWidget.refreshBuild({
    super.key,
    required RefreshPhysicsBuilder builder,
    required RefreshableLoader this.loader,
    this.stateWidget,
    this.scrollController,
    this.refreshController,
    this.header,
    this.footer,
    this.onStateEvent,
  })  : wrapRefresh = true,
        _builder = null,
        _physicsBuilder = builder;

  final bool wrapRefresh; // 是否包裹下拉刷新
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
  bool _wrapPullToRefresh(Loadable loader) {
    if (!wrapRefresh) return false;
    return loader is RefreshableLoader && loader.enableRefresh;
  }

  /// The default [onStateEvent] for [StateSwitchWidget].
  Future<void> _onStateEvent(LoadingState state, Object? extra) async {
    switch (state) {
      case LoadingState.empty:
      case LoadingState.error:
        return loader.refresh();
      case LoadingState.init:
      case LoadingState.loading:
      case LoadingState.reloading:
      case LoadingState.ready:
      case LoadingState.errorAndNotEmpty:
        break;
    }
  }

  /// Build the [RefreshWidget].
  Widget _buildRefresh(BuildContext context, RefreshableLoader loader) {
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
    assert(() {
      if (wrapRefresh && loader is! RefreshableLoader) {
        throw Exception(
          'Can not use RefreshableLoader with RefreshPhysicsBuilder',
        );
      }
      return true;
    }());
    return StateSwitchWidget(
      state: loader.value.state,
      error: loader.value.error,
      stateWidget: stateWidget,
      wrapPullToRefresh: _wrapPullToRefresh(loader),
      header: header,
      onStateEvent: onStateEvent ?? _onStateEvent,
      readyWidgetBuilder: (context) {
        if (wrapRefresh && loader is RefreshableLoader) {
          return _buildRefresh(context, loader as RefreshableLoader);
        } else {
          return _builder?.call(context) ?? const SizedBox.shrink();
        }
      },
    );
  }
}
