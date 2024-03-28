import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loader/loadable.dart';
import 'loader/loadable_data.dart';
import 'refresh/refresh_widget.dart';
import 'refresh/state_switch.dart';
import 'refresh/widgets.dart';

export 'loader/loadable.dart';
export 'loader/loader.dart';
export 'loader/loadable_data.dart';
export 'loader/page_by_index.dart';
export 'loader/page_by_key.dart';
export 'loader/page_loader.dart';

export 'refresh/refresh_widget.dart';
export 'refresh/state_switch.dart';
export 'refresh/widgets.dart';

export 'vm/base.dart';
export 'vm/index_page.dart';
export 'vm/key_page.dart';

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
/// If loader is [RefreshMoreLoader], it will be wrapped with [RefreshWidget].
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
  })  : _builder = builder,
        _physicsBuilder = null;

  /// Create a [StatableWidget] with [RefreshPhysicsBuilder].
  const StatableWidget.physics({
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
