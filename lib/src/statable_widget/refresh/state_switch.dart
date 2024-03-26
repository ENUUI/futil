import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import '../statable_widget.dart';

typedef StateEventCallback = FutureOr<void> Function(
    LoadingState, Object? extra);

class WidgetState {
  WidgetState._(this.state, this.error, this.onStateEvent);

  final LoadingState state;
  final Object? error;
  final StateEventCallback? onStateEvent;
}

abstract class StateWidget {
  /// called when [state.isReady != LoadingState.ready].
  Widget build(BuildContext context, WidgetState widgetState);
}

class StateSwitchWidget extends StatelessWidget {
  const StateSwitchWidget({
    super.key,
    required this.readyWidgetBuilder,
    this.stateWidget,
    this.state,
    this.error,
    this.onStateEvent,
    this.wrapPullToRefresh = false,
    this.header,
  });

  final bool wrapPullToRefresh;
  final WidgetBuilder readyWidgetBuilder;
  final StateWidget? stateWidget;
  final LoadingState? state;
  final Object? error;
  final StateEventCallback? onStateEvent;
  final RefreshHeader? header;

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    final provider = StatableProvider.maybeOf(context);
    final stateWidget = this.stateWidget ?? provider?.stateWidget;
    if (state != null && !state.isReady && stateWidget != null) {
      final widget = stateWidget.build(
        context,
        WidgetState._(state, error, onStateEvent),
      );
      if (!wrapPullToRefresh) return widget;
      return EasyRefresh(
        header: (header ?? provider?.header)?.build(context),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Center(
                child: widget,
              ),
            )
          ],
        ),
        onRefresh: () async {
          await onStateEvent?.call(state, error);
        },
      );
    }
    return readyWidgetBuilder(context);
  }
}
