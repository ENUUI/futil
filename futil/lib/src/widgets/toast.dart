import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'space.dart';

typedef ToastWidgetBuilder = Widget Function(BuildContext context, ToastStyles styles);

class ToastProvider extends ChangeNotifierProvider<ToastStyles> {
  ToastProvider({
    super.key,
    required Widget child,
    Color? backgroundColor,
    TextStyle? textStyle,
    required Widget infoIcon,
    required Widget errorIcon,
  }) : super.value(
            child: OKToast(
              movingOnWindowChange: false,
              child: child,
            ),
            value: ToastStyles(
              backgroundColor: backgroundColor,
              textStyle: textStyle,
              infoIcon: infoIcon,
              errorIcon: errorIcon,
            ));

  static ToastStyles _of(BuildContext context) {
    return Provider.of<ToastStyles>(context, listen: false);
  }
}

class ToastStyles extends ChangeNotifier {
  ToastStyles({
    this.backgroundColor,
    this.textStyle,
    required this.infoIcon,
    required this.errorIcon,
  });

  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Widget infoIcon;
  final Widget errorIcon;
}

class Toast {
  Toast._();

  /// Set the ObjectParser for error handling.
  /// if return (msg, true) and msg is not empty, the msg will be shown as toast.
  /// if return (msg, false), the default error parser will be used.
  static (String, bool) Function(Object err)? _objectParser;

  static void setObjectParser((String, bool) Function(Object err) parser) {
    if (_objectParser != null) {
      assert(false, "fallthrough parser already set");
      return;
    }
    _objectParser = parser;
  }

  static void show(String msg, {bool isError = false}) {
    showToastWidget(
      _ToastWidget(text: msg, isError: isError),
      dismissOtherToast: true,
    );
  }

  static (String, bool) _parseError(Object err) {
    if (err is String) {
      return (err, true);
    }
    if (err is Error) {
      return (err.toString(), true);
    }
    if (err is Exception) {
      return (err.toString(), true);
    }
    return ('', false);
  }

  static void showError(Object? err) {
    if (err == null) return;

    if (err is String) {
      show(err, isError: true);
      return;
    }

    String msg = '';
    final (result, ok) = (_objectParser ?? _parseError).call(err);
    if (!ok || result.isEmpty) {
      return;
    }

    show(msg, isError: true);
  }

  static void showWidget(
    BuildContext context, {
    required ToastWidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 2300),
  }) {
    showToastWidget(
      ToastWrap(builder: builder),
      dismissOtherToast: true,
      context: context,
      duration: duration,
    );
  }

  static void dismissAll() {
    dismissAllToast(showAnim: true);
  }
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return ToastWrap(
      builder: (context, styles) {
        return Center(
          child: Container(
            constraints: BoxConstraints(
              minWidth: 154,
              maxWidth: MediaQuery.of(context).size.width - 60,
              minHeight: 87,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            // alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              color: styles.backgroundColor ?? Theme.of(context).colorScheme.onBackground.withOpacity(.95),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isError ? styles.errorIcon : styles.infoIcon,
                const Blank.v(15),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

/// [ToastWrap]
class ToastWrap extends StatelessWidget {
  const ToastWrap({super.key, required this.builder});

  final ToastWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final styles = ToastProvider._of(context);
    final textStyle = styles.textStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white) ??
        const TextStyle(fontSize: 14);

    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Material(
        color: Colors.transparent,
        child: DefaultTextStyle(
          style: textStyle,
          child: builder(context, styles),
        ),
      ),
    );
  }
}
