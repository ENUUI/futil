import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'space.dart';

class ToastProvider extends ChangeNotifierProvider<_ToastStyles> {
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
            value: _ToastStyles(
              backgroundColor: backgroundColor,
              textStyle: textStyle,
              infoIcon: infoIcon,
              errorIcon: errorIcon,
            ));

  static _ToastStyles _of(BuildContext context) {
    return Provider.of<_ToastStyles>(context, listen: false);
  }
}

class _ToastStyles extends ChangeNotifier {
  _ToastStyles({
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

  static void show(String msg, {bool isError = false}) {
    showToastWidget(
      _ToastWidget(text: msg, isError: isError),
      dismissOtherToast: true,
    );
  }

  static void showError(Object? err) {
    if (err == null) return;

    if (err is String) {
      show(err, isError: true);
      return;
    }

    final String msg;
    if (err is Error) {
      msg = err.toString();
    } else if (err is Exception) {
      msg = err.toString();
    } else {
      msg = "";
    }
    if (msg.isEmpty) return;

    show(msg, isError: true);
  }
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final styles = ToastProvider._of(context);
    final themeData = Theme.of(context);
    final backgroundColor = styles.backgroundColor ??
        themeData.colorScheme.onBackground.withOpacity(.95);
    final textStyle = styles.textStyle ??
        themeData.textTheme.bodyMedium?.copyWith(color: Colors.white) ??
        const TextStyle(fontSize: 14, color: Colors.white);
    final icon = isError ? styles.errorIcon : styles.infoIcon;
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                minWidth: 154,
                maxWidth: MediaQuery.of(context).size.width - 60,
                minHeight: 87,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              // alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                color: backgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const Blank.v(15),
                  Text(
                    text,
                    style: textStyle,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  )
                ],
              ),
            ),
          )),
    );
  }
}
