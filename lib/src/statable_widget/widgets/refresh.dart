import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import '../loader/loadable.dart';
import '../loader/loadable_data.dart';
import 'provider.dart';
import 'widgets.dart';

///
typedef RefreshPhysicsBuilder = Widget Function(BuildContext context, ScrollPhysics physics);

/// Refresh widget.
class RefreshWidget extends StatefulWidget {
  const RefreshWidget({
    super.key,
    required this.refreshableLoader,
    required WidgetBuilder builder,
    this.scrollController,
    this.refreshController,
    this.header,
    this.footer,
  })  : _builder = builder,
        _physicsBuilder = null;

  const RefreshWidget.builder({
    super.key,
    required this.refreshableLoader,
    required RefreshPhysicsBuilder builder,
    this.scrollController,
    this.refreshController,
    this.header,
    this.footer,
  })  : _builder = null,
        _physicsBuilder = builder;

  final WidgetBuilder? _builder;
  final RefreshPhysicsBuilder? _physicsBuilder;
  final ScrollController? scrollController;
  final EasyRefreshController? refreshController;
  final RefreshMoreLoader refreshableLoader;
  final RefreshHeader? header;
  final RefreshFooter? footer;

  @override
  State<RefreshWidget> createState() => _RefreshWidgetState();
}

class _RefreshWidgetState extends State<RefreshWidget> {
  late EasyRefreshController refreshController;
  late ProcessValue processValue;

  @override
  void initState() {
    processValue = widget.refreshableLoader.processValue;
    refreshController = widget.refreshController ??
        EasyRefreshController(
          controlFinishRefresh: true,
          controlFinishLoad: true,
        );
    processValue.addListener(_listenToProcessChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RefreshWidget oldWidget) {
    final nextRefreshController = widget.refreshController;
    if (nextRefreshController != null && refreshController != nextRefreshController) {
      refreshController = nextRefreshController;
    }

    if (widget.refreshableLoader.processValue != processValue) {
      processValue.removeListener(_listenToProcessChanged);
      processValue = widget.refreshableLoader.processValue;
      processValue.addListener(_listenToProcessChanged);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    processValue.removeListener(_listenToProcessChanged);
    refreshController.dispose();
    super.dispose();
  }

  void _listenToProcessChanged() {
    final process = processValue.value;
    final refreshController = this.refreshController;
    switch (process.status) {
      case LoaderProcessState.none:
        break;
      case LoaderProcessState.start:
        break;
      case LoaderProcessState.success:
        if (process.refresh) {
          refreshController.finishRefresh(IndicatorResult.success);
        } else {
          refreshController.finishLoad(IndicatorResult.success);
        }
        break;
      case LoaderProcessState.noMore:
        if (process.refresh) {
          refreshController.finishRefresh(IndicatorResult.success);
          refreshController.finishLoad(IndicatorResult.noMore);
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
        break;
      case LoaderProcessState.failed:
        if (process.refresh) {
          refreshController.finishRefresh(IndicatorResult.fail);
        } else {
          refreshController.finishLoad(IndicatorResult.fail);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loader = widget.refreshableLoader;
    final builder = widget._builder;
    final provider = StatableProvider.maybeOf(context);
    if (builder != null) {
      return EasyRefresh(
        scrollController: widget.scrollController,
        controller: refreshController,
        onLoad: loader.enablePullLoadMore ? loader.loadMore : null,
        onRefresh: loader.enablePullRefresh ? loader.refresh : null,
        header: (widget.header ?? provider?.header)?.build(context),
        footer: (widget.footer ?? provider?.footer)?.build(context),
        child: builder(context),
      );
    }

    final physicsBuilder = widget._physicsBuilder;
    if (physicsBuilder != null) {
      return EasyRefresh.builder(
        scrollController: widget.scrollController,
        controller: refreshController,
        onLoad: loader.enablePullLoadMore ? loader.loadMore : null,
        onRefresh: loader.enablePullRefresh ? loader.refresh : null,
        header: (widget.header ?? provider?.header)?.build(context),
        footer: (widget.footer ?? provider?.footer)?.build(context),
        childBuilder: (context, physics) {
          return physicsBuilder(context, physics);
        },
      );
    }

    assert(() {
      throw Exception('Scrollable widget builder not found.');
    }());
    return const SizedBox.shrink();
  }
}
