import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 可拖拽关闭的 Dialog 容器
class DraggableDialog extends StatefulWidget {
  const DraggableDialog({
    super.key,
    this.backgroundColor,
    required this.child,
    this.offsetTop,
    this.borderRadius = const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
    this.barrierColor = Colors.black54,
    this.top,
    this.bottom,
    this.scrollController,
    this.draggable = true,
    this.removeBottom = true,
  });

  final bool draggable;
  final Color? backgroundColor;
  final Widget child;
  final double? offsetTop;
  final BorderRadius borderRadius;
  final Color barrierColor;
  final ScrollController? scrollController;
  final PreferredSizeWidget? top;
  final Widget? bottom;
  final bool removeBottom;

  @override
  State<DraggableDialog> createState() => _DraggableDialogState();
}

class _DraggableDialogState extends State<DraggableDialog> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late Animation<Decoration> _backgroundAnimation;
  late AnimationController _pageAnimationController;
  late Animation<Offset> _positionAnimation;
  ScrollController? _scrollController;

  Animation<double>? _moveInAnimation;

  bool _isInit = true;
  bool _dragging = false;
  double _topWidgetHeight = 0.0;
  bool _startInsideTop = false;

  Size get _maxSize => MediaQuery.of(context).size;

  double get _offsetTop => widget.offsetTop ?? MediaQuery.of(context).padding.top + 44;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _backgroundAnimation = _backgroundAnimationController.drive(DecorationTween(
      begin: const BoxDecoration(color: Colors.transparent),
      end: BoxDecoration(color: widget.barrierColor),
    ));

    _pageAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _positionAnimation = _pageAnimationController.drive(Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, 1.0),
    ));

    _topWidgetHeight = widget.top?.preferredSize.height ?? 0.0;
  }

  @override
  void didUpdateWidget(covariant DraggableDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _topWidgetHeight = widget.top?.preferredSize.height ?? 0.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      Future.delayed(const Duration(milliseconds: 100)).then((value) {
        if (mounted) _backgroundAnimationController.forward();
      });
    }
    try {
      _moveInAnimation?.removeStatusListener(_listenToAnimation);
      final animation = Provider.of<Animation<double>>(context);
      animation.addStatusListener(_listenToAnimation);
      _moveInAnimation = animation;
    } catch (_) {}
  }

  void _listenToAnimation(AnimationStatus status) {
    if (status == AnimationStatus.reverse) {
      _backgroundAnimationController.value = 0.0;
    }
  }

  void _dragPoint(PointerEvent event) {
    final delta = event.delta;
    double diff = 0.0;
    final orientation = (delta.dx / delta.dy).abs();

    if (!(Platform.isIOS || Platform.isMacOS) && orientation > 0.5) {
      return;
    }

    if (orientation.abs() > 0.5) {
      diff = delta.dx / _maxSize.width;
    } else {
      diff = delta.dy * 2 / _maxSize.height;
    }
    final scrollController = widget.scrollController;
    if (!_startInsideTop &&
        diff > 0 &&
        scrollController != null &&
        scrollController.hasClients &&
        scrollController.offset > 0) {
      return;
    }

    final value = max(min(1.0, _pageAnimationController.value + diff), 0.0);
    if (value == _pageAnimationController.value) return;
    if (!_dragging) {
      setState(() {
        _dragging = true;
      });
    }

    _pageAnimationController.value = value;
    _backgroundAnimationController.value = max(0.0, 1.0 - value * 2);
  }

  void _dragEnd() {
    _startInsideTop = false;

    if (_dragging) {
      setState(() {
        _dragging = false;
      });
    }
    if (_pageAnimationController.value > 0.5) {
      _backgroundAnimationController.value = 0.0;
      _pageAnimationController.forward().whenComplete(() {
        if (mounted) Navigator.maybePop(context);
      });
    } else {
      _pageAnimationController.reverse().whenComplete(() {});
      _backgroundAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _pageAnimationController.dispose();
    _scrollController?.dispose();
    _moveInAnimation?.removeStatusListener(_listenToAnimation);
    super.dispose();
  }

  Color _getBackgroundColor() {
    final themeData = Theme.of(context);
    return widget.backgroundColor ?? themeData.bottomSheetTheme.backgroundColor ?? themeData.colorScheme.background;
  }

  Widget _buildContent() {
    final top = widget.top, bottom = widget.bottom;
    if (top == null && bottom == null) {
      return widget.child;
    }
    final children = <Widget>[];
    if (top != null) {
      children.add(top);
    }
    children.add(Expanded(child: widget.child));
    if (bottom != null) {
      children.add(bottom);
    }
    return Column(children: children);
  }

  @override
  Widget build(BuildContext context) {
    final draggable = widget.draggable;
    Widget content = GestureDetector(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.only(top: _offsetTop),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(color: _getBackgroundColor(), borderRadius: widget.borderRadius),
          child: _buildContent(),
        ));

    if (draggable) {
      content = SlideTransition(
        position: _positionAnimation,
        child: content,
      );
    }

    content = DecoratedBoxTransition(decoration: _backgroundAnimation, child: content);

    if (Platform.isIOS && draggable) {
      content = Listener(
        onPointerDown: (event) {
          final position = event.position;

          _startInsideTop = position.dy <= _offsetTop + _topWidgetHeight;
        },
        onPointerMove: (event) {
          _dragPoint(event);
        },
        onPointerCancel: (_) {
          _dragEnd();
        },
        onPointerUp: (_) {
          _dragEnd();
        },
        child: content,
      );
    }

    return PopScope(
      onPopInvoked: (c) {
        _backgroundAnimationController.value = 0.0;
      },
      child: MediaQuery.removeViewPadding(
        context: context,
        removeTop: true,
        removeRight: true,
        removeBottom: widget.removeBottom,
        removeLeft: true,
        child: Material(
          type: MaterialType.transparency,
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              _backgroundAnimationController.value = 0.0;
              Navigator.maybePop(context);
            },
            child: content,
          ),
        ),
      ),
    );
  }
}
