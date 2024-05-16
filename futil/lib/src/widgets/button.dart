import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IcButton extends StatelessWidget {
  const IcButton({super.key, required this.icon, this.width, this.height, this.onPressed});

  final Widget icon;
  final double? width;
  final double? height;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onPressed: onPressed,
      child: SizedBox(
        width: width,
        height: height,
        child: Center(child: icon),
      ),
    );
  }
}

class MtButton extends StatelessWidget {
  const MtButton(
      {super.key,
      this.onPressed,
      this.child,
      this.height = 44.0,
      this.borderRadius = const BorderRadius.all(Radius.circular(22))});

  final VoidCallback? onPressed;
  final Widget? child;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.zero,
      height: height,
      minWidth: 0,
      elevation: 1,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      onPressed: () {
        onPressed?.call();
      },
      child: child,
    );
  }
}

class Clickable extends StatelessWidget {
  const Clickable({super.key, this.onPressed, this.child});

  final VoidCallback? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onPressed?.call();
      },
      child: child,
    );
  }
}

class HighlightButton extends StatelessWidget {
  const HighlightButton({super.key, required this.child, required this.onPressed});

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      minSize: 0,
      child: child,
    );
  }
}

class ScaleButton extends StatefulWidget {
  const ScaleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.margin = EdgeInsets.zero,
    this.isDisable = false,
    this.disableOpacity = 1.0,
    this.backgroundColor,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final bool isDisable;
  final double disableOpacity;
  final Color? backgroundColor;

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> with TickerProviderStateMixin {
  static const Duration kFadeInDuration = Duration(milliseconds: 180);
  static const Duration kFadeOutDuration = Duration(milliseconds: 120);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0, end: .85);
  final Tween<double> _scaleTween = Tween<double>(begin: 1.0, end: .95);

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(value: 0.0, duration: kFadeInDuration, vsync: this); //AnimationController
    _opacityAnimation = _controller.drive(CurveTween(curve: Curves.decelerate)).drive(_opacityTween);
    _scaleAnimation = _controller.drive(CurveTween(curve: Curves.decelerate)).drive(_scaleTween);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.stop();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_controller.isAnimating) {
      return;
    }
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _controller.animateTo(1.0, duration: kFadeOutDuration, curve: Curves.easeInOutCubicEmphasized)
        : _controller.animateTo(0.0, duration: kFadeInDuration, curve: Curves.easeOutCubic);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) {
        _animate();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.isDisable;
    final ThemeData themeData = Theme.of(context);
    return Padding(
      padding: widget.margin,
      child: MouseRegion(
        cursor: enabled && kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? _handleTapDown : null,
          onTapUp: enabled ? _handleTapUp : null,
          onTapCancel: enabled ? _handleTapCancel : null,
          onTap: enabled ? widget.onPressed : null,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: DefaultTextStyle(
                style: themeData.textTheme.bodyLarge ??
                    const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlatformButton extends StatelessWidget {
  const PlatformButton({super.key, required this.child, required this.onPressed});
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.iOS:
        return HighlightButton(onPressed: onPressed, child: child);
      default:
        return MaterialButton(onPressed: onPressed, padding: EdgeInsets.zero, child: child);
    }
  }
}
