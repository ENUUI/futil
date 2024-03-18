import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

typedef TextBuilder = Text Function(BuildContext context);

/// Refresh header builder.
class RefreshHeader {
  RefreshHeader({
    required WidgetBuilder processingText,
    required WidgetBuilder successText,
    required WidgetBuilder failureText,
    required WidgetBuilder processingIconBuilder,
    required WidgetBuilder successIconBuilder,
    required WidgetBuilder failureIconBuilder,
  })  : _failureIconBuilder = failureIconBuilder,
        _successIconBuilder = successIconBuilder,
        _processingIconBuilder = processingIconBuilder,
        _failureText = failureText,
        _successText = successText,
        _processingText = processingText;

  final WidgetBuilder _processingText;
  final WidgetBuilder _successText;
  final WidgetBuilder _failureText;
  final WidgetBuilder _processingIconBuilder;
  final WidgetBuilder _successIconBuilder;
  final WidgetBuilder _failureIconBuilder;

  Header build(BuildContext context) {
    return BuilderHeader(
      builder: (BuildContext context, IndicatorState state) {
        return _ClassicIndicator(
          state: state,
          processingText: _processingText,
          successText: _successText,
          failureText: _failureText,
          processingIconBuilder: _processingIconBuilder,
          successIconBuilder: _successIconBuilder,
          failureIconBuilder: _failureIconBuilder,
        );
      },
      triggerOffset: 70.0,
      clamping: false,
      position: IndicatorPosition.above,
    );
  }

  RefreshHeader copyWith({WidgetBuilder? processingText}) {
    return RefreshHeader(
      processingText: processingText ?? _processingText,
      successText: _successText,
      failureText: _failureText,
      processingIconBuilder: _processingIconBuilder,
      successIconBuilder: _successIconBuilder,
      failureIconBuilder: _failureIconBuilder,
    );
  }
}

/// Refresh footer builder.
class RefreshFooter {
  RefreshFooter({
    required WidgetBuilder processingIconBuilder,
  }) : _processingIconBuilder = processingIconBuilder;

  final WidgetBuilder _processingIconBuilder;

  Footer build(BuildContext context) {
    ClassicFooter;
    return BuilderFooter(
      builder: (BuildContext context, IndicatorState state) {
        return _ClassicIndicator(
          state: state,
          processingText: (context) => const Text(''),
          successText: (context) => const Text(''),
          failureText: (context) => const Text(''),
          processingIconBuilder: _processingIconBuilder,
          successIconBuilder: (context) => const SizedBox.shrink(),
          failureIconBuilder: (context) => const SizedBox.shrink(),
          showText: false,
        );
      },
      triggerOffset: 70.0,
      clamping: false,
    );
  }
}

/// Pull icon widget builder.
typedef CIPullIconBuilder = Widget Function(
    BuildContext context, IndicatorState state, double animation);

/// Text widget builder.
typedef CITextBuilder = Widget Function(
    BuildContext context, IndicatorState state, String text);

/// Message widget builder.
typedef CIMessageBuilder = Widget Function(
    BuildContext context, IndicatorState state, String text, DateTime dateTime);

class _ClassicIndicator extends StatefulWidget {
  final IndicatorState state;
  final WidgetBuilder processingText;
  final WidgetBuilder successText;
  final WidgetBuilder failureText;
  final WidgetBuilder processingIconBuilder;
  final WidgetBuilder successIconBuilder;
  final WidgetBuilder failureIconBuilder;
  final bool showText;

  const _ClassicIndicator({
    required this.state,
    required this.processingText,
    required this.successText,
    required this.failureText,
    required this.processingIconBuilder,
    required this.successIconBuilder,
    required this.failureIconBuilder,
    this.showText = true,
  });

  @override
  State<_ClassicIndicator> createState() => _ClassicIndicatorState();
}

class _ClassicIndicatorState extends State<_ClassicIndicator> {
  late GlobalKey _iconAnimatedSwitcherKey;

  MainAxisAlignment get _mainAxisAlignment => MainAxisAlignment.center;

  Axis get _axis => widget.state.axis;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  double get _triggerOffset => widget.state.triggerOffset;

  double get _safeOffset => widget.state.safeOffset;

  IndicatorMode get _mode => widget.state.mode;

  IndicatorResult get _result => widget.state.result;

  bool get _reverse => widget.state.reverse;

  @override
  void initState() {
    super.initState();
    _iconAnimatedSwitcherKey = GlobalKey();
  }

  Widget _buildCurrentText() {
    if (_result == IndicatorResult.noMore) {
      return const Text('');
    }
    switch (_mode) {
      case IndicatorMode.drag:
      case IndicatorMode.armed:
      case IndicatorMode.ready:
      case IndicatorMode.processing:
        return widget.processingText(context);
      case IndicatorMode.processed:
      case IndicatorMode.done:
        if (_result == IndicatorResult.fail) {
          return widget.failureText(context);
        } else {
          return widget.successText(context);
        }
      default:
        return widget.processingText(context);
    }
  }

  /// Build icon.
  Widget _buildIcon() {
    Widget icon;
    ValueKey iconKey;
    if (_result == IndicatorResult.noMore) {
      iconKey = const ValueKey(IndicatorResult.noMore);
      icon = const SizedBox.shrink();
    } else if (_mode == IndicatorMode.processed ||
        _mode == IndicatorMode.done) {
      if (_result == IndicatorResult.fail) {
        iconKey = const ValueKey(IndicatorResult.fail);
        icon = widget.failureIconBuilder(context);
      } else {
        iconKey = const ValueKey(IndicatorResult.success);
        icon = widget.successIconBuilder(context);
      }
    } else {
      iconKey = const ValueKey(IndicatorMode.drag);
      icon = widget.processingIconBuilder(context);
    }
    return AnimatedSwitcher(
      key: _iconAnimatedSwitcherKey,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: iconKey,
        child: icon,
      ),
    );
  }

  Widget _buildVerticalWidget() {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        if (_mainAxisAlignment == MainAxisAlignment.center)
          Positioned(
            left: 0,
            right: 0,
            top: _offset < _actualTriggerOffset
                ? -(_actualTriggerOffset -
                        _offset +
                        (_reverse ? _safeOffset : -_safeOffset)) /
                    2
                : (!_reverse ? _safeOffset : 0),
            bottom: _offset < _actualTriggerOffset
                ? null
                : (_reverse ? _safeOffset : 0),
            height:
                _offset < _actualTriggerOffset ? _actualTriggerOffset : null,
            child: Center(
              child: _buildVerticalBody(),
            ),
          ),
        if (_mainAxisAlignment != MainAxisAlignment.center)
          Positioned(
            left: 0,
            right: 0,
            top: _mainAxisAlignment == MainAxisAlignment.start
                ? (!_reverse ? _safeOffset : 0)
                : null,
            bottom: _mainAxisAlignment == MainAxisAlignment.end
                ? (_reverse ? _safeOffset : 0)
                : null,
            child: _buildVerticalBody(),
          ),
      ],
    );
  }

  Widget _buildVerticalBody() {
    return Container(
      alignment: Alignment.center,
      height: _triggerOffset,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: _buildIcon(),
          ),
          if (widget.showText)
            Container(
              margin: const EdgeInsets.only(left: 5),
              child: _buildCurrentText(),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalWidget() {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        if (_mainAxisAlignment == MainAxisAlignment.center)
          Positioned(
            left: _offset < _actualTriggerOffset
                ? -(_actualTriggerOffset -
                        _offset +
                        (_reverse ? _safeOffset : -_safeOffset)) /
                    2
                : (!_reverse ? _safeOffset : 0),
            right: _offset < _actualTriggerOffset
                ? null
                : (_reverse ? _safeOffset : 0),
            top: 0,
            bottom: 0,
            width: _offset < _actualTriggerOffset ? _actualTriggerOffset : null,
            child: Center(
              child: _buildHorizontalBody(),
            ),
          ),
        if (_mainAxisAlignment != MainAxisAlignment.center)
          Positioned(
            left: _mainAxisAlignment == MainAxisAlignment.start
                ? (!_reverse ? _safeOffset : 0)
                : null,
            right: _mainAxisAlignment == MainAxisAlignment.end
                ? (_reverse ? _safeOffset : 0)
                : null,
            top: 0,
            bottom: 0,
            child: _buildHorizontalBody(),
          ),
      ],
    );
  }

  Widget _buildHorizontalBody() {
    return Container(
      alignment: Alignment.center,
      width: _triggerOffset,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showText)
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              child: RotatedBox(
                quarterTurns: -1,
                child: _buildCurrentText(),
              ),
            ),
          Container(
            alignment: Alignment.center,
            child: _buildIcon(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double offset = _offset;
    if (widget.state.indicator.infiniteOffset != null &&
        widget.state.indicator.position == IndicatorPosition.locator &&
        (_mode != IndicatorMode.inactive ||
            _result == IndicatorResult.noMore)) {
      offset = _actualTriggerOffset;
    }
    return SizedBox(
      width: _axis == Axis.vertical ? double.infinity : offset,
      height: _axis == Axis.horizontal ? double.infinity : offset,
      child: _axis == Axis.vertical
          ? _buildVerticalWidget()
          : _buildHorizontalWidget(),
    );
  }
}
